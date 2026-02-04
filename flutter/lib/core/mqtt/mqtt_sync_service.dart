import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'mqtt_client_service.dart';
import '../utils/json_schema_validator.dart';
import 'message_deduplicator.dart';
import 'timestamp_validator.dart';
import '../utils/resource_data_sanitizer.dart';

class MqttSyncService {
  final MqttClientService _client;
  final AppDatabase _db;
  final _log = Logger('MqttSyncService');
  final _logsController = StreamController<String>.broadcast();
  Stream<String> get logs => _logsController.stream;

  // Componentes V2.4
  final _deduplicator = MessageDeduplicator();
  final _validator = TimestampValidator();

  // Contexto ativo para sincronização
  int? _activeHomeInternalId;
  String? _activeTenantId;
  String? _activeHomeId;

  // Monitor de Conexão
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _subscription;

  MqttSyncService(this._client, this._db) {
    _log.info('Initialized with AppDatabase HashCode: ${_db.hashCode}');
    _monitorConnection();
  }

  void _monitorConnection() {
    _connectionSubscription = _client.connectionStateStream.listen((state) {
      if (state == MqttConnectionState.connected &&
          _activeHomeInternalId != null) {
        _log.info('MQTT Reconnected: Restarting Sync for active context');
        _setupUpdatesSubscription();
      }
    });
  }

  /// Inicia a sincronização para um contexto específico
  void startSync(int homeInternalId, String tenantId, String homeId) {
    _activeHomeInternalId = homeInternalId;
    _activeTenantId = tenantId;
    _activeHomeId = homeId;

    // Limpa cache de desduplicação ao trocar de contexto
    _deduplicator.clear();

    _log.info(
      'Starting sync for Home context: $_activeTenantId/$_activeHomeId ($homeInternalId)',
    );

    // Subscribe to Home Topic
    _client.subscribe('home/$_activeTenantId/$_activeHomeId/#');

    // Aggressive cleanup on start
    _db.devicesDao.deleteEmptyStubs(homeInternalId).then((_) {
      _log.info('🧹 Cleaned up orphans for home $homeInternalId on sync start');
    });

    _setupUpdatesSubscription();
  }

  void _setupUpdatesSubscription() {
    _subscription?.cancel();

    if (_client.updates == null) {
      _log.warning(
        'Client updates stream is not available yet (not connected). Sync pending...',
      );
      return;
    }

    _subscription = _client.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) async {
        if (_activeHomeInternalId == null) {
          return;
        }
        for (final msg in messages) {
          final topic = msg.topic;
          final publishMessage = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            publishMessage.payload.message,
          );
          final isRetained = publishMessage.header?.retain ?? false;

          _logsController.add(
            '[RECV] $topic: $payload (Retained: $isRetained)',
          );
          await _handleMessage(
            topic,
            payload,
            _activeHomeInternalId!,
            isRetained: isRetained,
          );
        }
      },
      onDone: () {
        _log.info('Sync subscription stream closed');
      },
    );
    _log.info('✓ Sync subscription active');
  }

  // ... (imports remain)

  // ... (fields remain)

  // Lifecycle
  Future<void> stopSync() async {
    _log.info('Stopping sync');
    if (_activeTenantId != null && _activeHomeId != null) {
      _client.unsubscribe('home/$_activeTenantId/$_activeHomeId/#');
    }
    _activeHomeInternalId = null;
    _activeTenantId = null;
    _activeHomeId = null;
    await _subscription?.cancel();
    _subscription = null;
    _deduplicator.clear();
  }

  Future<void> dispose() async {
    await stopSync();
    await _connectionSubscription?.cancel();
    await _logsController.close();
  }

  Future<void> _handleMessage(
    String topic,
    String payload,
    int homeInternalId, {
    bool isRetained = false,
  }) async {
    try {
      if (_deduplicator.isDuplicate(topic, payload)) return;

      final parts = topic.split('/');
      // Expected: home/{tenant}/{home}/...
      if (parts.length < 5 || parts[0] != 'home') return;

      // 1. Validate Context (Critical Safety 1)
      if (parts[1] != _activeTenantId || parts[2] != _activeHomeId) {
        return;
      }

      final subArea = parts[3];

      // 2. Routing with Structure Validation (Critical Safety 2)
      if (subArea == 'device' && parts.last == 'status' && parts.length >= 6) {
        // home/t/h/device/{id}/status
        await _handleDeviceStatus(parts, payload, homeInternalId);
      } else if (subArea == 'meta' && parts.contains('resource')) {
        await _handleResourceMeta(parts, payload, homeInternalId);
      } else if (subArea == 'r' && parts.length >= 6) {
        // home/t/h/r/{id}/{leaf}
        final leaf = parts.last;
        if (leaf == 'result') {
          await _handleCommandResult(parts, payload, homeInternalId);
        } else {
          await _handleResourceOperational(
            parts,
            payload,
            homeInternalId,
            isRetained: isRetained,
          );
        }
      } else if (subArea == 'event' && parts.length >= 7) {
        // home/t/h/event/{domain}/{kind}/{id}
        await _handleEvent(parts, payload, homeInternalId);
      }
    } catch (e, s) {
      _log.severe(
        'Unexpected error in sync handler for topic $topic: $e',
        e,
        s,
      );
    }
  }

  Future<void> _handleDeviceStatus(
    List<String> parts,
    String payload,
    int homeId,
  ) async {
    final deviceTechnicalId = parts[4];

    try {
      if (payload.trim().isEmpty) {
        _log.warning('Empty heartbeat payload received for $deviceTechnicalId');
        return;
      }

      final data = jsonDecode(payload);
      final hw = data['hw'] is Map ? data['hw'] as Map : null;

      _log.info(
        '🔵 HEARTBEAT: deviceId=$deviceTechnicalId, homeId=$homeId, role=${data['role']}',
      );

      // 1. Upsert Device (Unified V2.4 logic)
      await _db.devicesDao.upsertDevice(
        DevicesV24Companion(
          homeId: Value(homeId),
          deviceId: Value(deviceTechnicalId),
          role: Value(data['role'] ?? 'UNKNOWN'),
          status: Value(data['state'] ?? data['status'] ?? 'ONLINE'),
          lastSeen: Value(DateTime.now()),
          firmwareVersion: Value(data['fw']?.toString()),
          contractVersion: Value(data['contract']?.toString()),
          uptime: Value(data['uptime'] is int ? data['uptime'] : null),
          hardwareRevision: Value(hw?['rev']?.toString()),
          vendor: Value(hw?['vendor']?.toString()),
          model: Value(hw?['model']?.toString()),
          rssi: Value(data['rssi'] is int ? data['rssi'] : null),
          ipAddress: Value(data['ip']?.toString()),
        ),
      );

      // 2. Parse Capabilities (Topology Sync)
      // "capabilities": [ { "type": "WATER_LEVEL", "resources": [ { "id": "...", ... } ] } ]
      if (data['capabilities'] is List) {
        final device = await _db.devicesDao.getByDeviceId(deviceTechnicalId);
        if (device != null) {
          for (final cap in data['capabilities']) {
            if (cap['resources'] is List) {
              for (final res in cap['resources']) {
                final resourceId = res['id'];
                if (resourceId != null) {
                  // Upsert resource link
                  await _db.resourcesDao.upsertResourceTopology(
                    homeId,
                    device.id,
                    resourceId,
                    res['label'] ?? resourceId,
                    res['kind'] ?? 'unknown',
                    jsonEncode(
                      res,
                    ), // Save minimal meta from status as fallback
                  );
                }
              }
            }
          }
        }
      }

      // 3. Cleanup: Remove empty "orphan" stubs after sync
      await _db.devicesDao.deleteEmptyStubs(homeId);

      _log.info('✅ Device status and topology synced: $deviceTechnicalId');
    } catch (e, s) {
      // Fix 7: Stacktrace
      _log.severe(
        '❌ HEARTBEAT UPSERT FAILED: deviceId=$deviceTechnicalId, error=$e',
        e,
        s,
      );
    }
  }

  Future<void> _handleResourceMeta(
    List<String> parts,
    String payload,
    int homeId,
  ) async {
    try {
      final resourceId = parts.last;
      final data = jsonDecode(payload);

      String? deviceTechnicalId = data['owner_device_id'] as String?;
      deviceTechnicalId ??= data['device_id'] as String?;

      int? dbDeviceId;

      if (deviceTechnicalId == null) {
        // Fallback 1: Try to find existing resource to get its deviceId
        final existingResource = await _db.resourcesDao
            .getResourceByTechnicalId(homeId, resourceId);
        if (existingResource != null) {
          dbDeviceId = existingResource.deviceId;
          _log.info(
            'Meta for $resourceId: using existing device link (id=$dbDeviceId)',
          );
        } else {
          // Fallback 2: Use orphan device for this home
          final orphanDeviceId = 'orphan-resources-$homeId';
          final device = await _ensureDeviceStub(orphanDeviceId, homeId);
          if (device == null) {
            _log.severe(
              'Meta for $resourceId: could not create orphan device stub.',
            );
            return;
          }
          dbDeviceId = device.id;
          _log.info(
            'Meta for $resourceId: assigned to orphan device (id=$dbDeviceId)',
          );
        }
      } else {
        final device = await _ensureDeviceStub(deviceTechnicalId, homeId);
        if (device == null) return;
        dbDeviceId = device.id;
      }

      final normalizedKind = ResourceDataSanitizer.normalizeKind(
        (data['kind'] as String? ?? 'unknown').split('.').first,
      );

      await _db.resourcesDao.upsertResourceMeta(
        homeId,
        dbDeviceId,
        resourceId,
        data['label'] ?? resourceId,
        normalizedKind,
        payload,
      );
    } catch (e, s) {
      _log.warning('Failed to sync resource meta for ${parts.last}: $e', e, s);
    }
  }

  Future<void> _handleResourceOperational(
    List<String> parts,
    String payload,
    int homeId, {
    bool isRetained = false,
  }) async {
    try {
      final resourceId = parts[4];
      final leaf = parts.last;
      final data = jsonDecode(payload);

      // 2. Validação de Timestamp (V2.4)
      DateTime? validTimestamp;

      if (data is Map<String, dynamic> && data.containsKey('ts')) {
        final ts = data['ts'];
        if (ts is int) {
          // Strict Timestamp validation (V2.4 Directive)
          // Reject anything pre-2020 (invalid epoch/uptime).
          if (ts < 1577836800) {
            _log.warning(
              'Discarding invalid timestamp message for $resourceId (TS: $ts)',
            );
            return;
          }

          // Standard Epoch Validation
          if (_validator.isFuture(ts) ||
              _validator.isStale(ts, maxAgeSeconds: 86400 * 7)) {
            _log.warning(
              'Discarding invalid timestamp message for $resourceId (TS: $ts)',
            );
            return;
          }
          validTimestamp = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
        }
      }

      var resource = await _db.resourcesDao.getResourceByTechnicalId(
        homeId,
        resourceId,
      );

      if (resource == null) {
        resource = await _ensureResourceStub(resourceId, homeId);
        if (resource == null) return;
      }

      if (!JsonSchemaValidator.validate(
        resource.domain,
        resource.kind,
        payload,
      )) {
        // Validation warning only for now
      }

      final opTimestamp = validTimestamp ?? DateTime.now();

      if (leaf == 'state' || leaf == 'data') {
        final normalizedBody = ResourceDataSanitizer.sanitize(data);
        final normalizedPayload = normalizedBody.payloadJson;

        if (leaf == 'state') {
          await _db.resourcesDao.upsertState(resource.id, normalizedPayload);

          // ✅ AUTO-CONFIRM: Verdade Assíncrona V2.4
          final pending = await _db.pendingCommandsDao.getPendingCommands();
          final myCommand = pending
              .where((c) => c.resourceId == resourceId)
              .toList();
          if (myCommand.isNotEmpty) {
            _log.info(
              'Auto-confirming command ${myCommand.first.correlationId} due to state update',
            );
            await _db.pendingCommandsDao.updateStatus(
              myCommand.first.correlationId,
              'success',
              completedAt: DateTime.now(),
            );
          }
        } else {
          await _db.resourcesDao.upsertData(resource.id, normalizedPayload);
        }

        // 1. Presence Logic (V2.4 Unified)
        final isPresenceActive =
            normalizedBody.data['detected'] == true ||
            normalizedBody.data['motion'] == true ||
            normalizedBody.data['occupancy'] == true;

        if (isPresenceActive && resource.kind == 'presence') {
          await _generatePresenceEvent(
            resource,
            normalizedBody.data,
            normalizedPayload,
            homeId,
            opTimestamp,
          );
        }

        // 2. Alert/Event Generation (V2.4 Unified)
        if (normalizedBody.alert != 'NORMAL') {
          final lastEvent = await _db.eventsV24Dao.getLastEvent(resource.id);
          bool shouldInsert = true;

          // Throttling: Só gera novo evento se o alerta mudou ou passou tempo
          if (lastEvent != null) {
            try {
              final lastJson = jsonDecode(lastEvent.payloadJson ?? '{}');
              if (lastJson['alert'] == normalizedBody.alert) {
                final diff = opTimestamp.difference(lastEvent.timestamp);
                if (diff.inMinutes < 5) shouldInsert = false;
              }
            } catch (_) {}
          }

          if (shouldInsert) {
            await _db.eventsV24Dao.insertEvent(
              EventsV24Companion.insert(
                homeId: homeId,
                resourceId: Value(resource.id),
                domain: resource.domain,
                kind: resource.kind,
                severity: Value(normalizedBody.severity ?? 'info'),
                payloadJson: Value(normalizedPayload),
                timestamp: opTimestamp,
              ),
            );
            _log.info(
              '🚨 Event Generated [${normalizedBody.severity}]: ${resource.id}',
            );
          }
        }

        if (resource.domain == 'water' && resource.kind == 'level') {
          await _db
              .into(_db.waterLevelHistory)
              .insert(
                WaterLevelHistoryCompanion(
                  resourceId: Value(resource.id),
                  percent: Value((data['percent'] as num?)?.toDouble() ?? 0.0),
                  liters: Value((data['liters'] as num?)?.toDouble() ?? 0.0),
                  // Fix 5: Use payload timestamp
                  timestamp: Value(opTimestamp),
                ),
              );
        }
      } else if (leaf == 'config') {
        await _db.resourcesDao.upsertConfig(resource.id, payload);
      }
    } catch (e, s) {
      _log.warning(
        'Failed to sync resource operational data for ${parts[4]}: $e',
        e,
        s,
      );
    }
  }

  Future<void> _handleEvent(
    List<String> parts,
    String payload,
    int homeId,
  ) async {
    try {
      // home/{t}/{h}/event/{domain}/{kind}/{resource_id}
      if (parts.length < 7) return;
      final domain = parts[4];
      final kind = parts[5];
      final resId = parts[6];

      final resource = await _db.resourcesDao.getResourceByTechnicalId(
        homeId,
        resId,
      );

      final data = jsonDecode(payload);
      final severity = data['severity']?.toString().toLowerCase() ?? 'info';

      // Fix 8: Removed dynamic casts by using correct generated types
      // (Assuming EventsV24Dao has insertEvent method accepting Companion)
      await _db.eventsV24Dao.insertEvent(
        EventsV24Companion.insert(
          homeId: homeId,
          resourceId: Value(resource?.id),
          domain: domain,
          kind: kind,
          severity: Value(severity),
          payloadJson: Value(payload),
          timestamp: DateTime.now(),
        ),
      );
    } catch (e, s) {
      _log.warning('Failed to sync event', e, s);
    }
  }

  Future<void> _generatePresenceEvent(
    ResourceEntity resource,
    Map<String, dynamic> data,
    String payload,
    int homeId,
    DateTime opTimestamp,
  ) async {
    final lastEvent = await _db.eventsV24Dao.getLastEvent(resource.id);
    bool shouldInsert = true;
    if (lastEvent != null) {
      final diff = opTimestamp.difference(lastEvent.timestamp);
      if (diff.inSeconds < 30) shouldInsert = false; // Throttling
    }

    if (shouldInsert) {
      await _db.eventsV24Dao.insertEvent(
        EventsV24Companion.insert(
          homeId: homeId,
          resourceId: Value(resource.id),
          domain: resource.domain,
          kind: resource.kind,
          severity: const Value('info'),
          payloadJson: Value(payload),
          timestamp: opTimestamp,
        ),
      );
      _log.info('🚶 Presence detection event generated for ${resource.id}');
    }
  }

  Future<void> _handleCommandResult(
    List<String> parts,
    String payload,
    int homeId,
  ) async {
    try {
      if (parts.length < 6) return;
      final resourceId = parts[4];

      final resource = await _db.resourcesDao.getResourceByTechnicalId(
        homeId,
        resourceId,
      );

      if (resource == null) return;

      final data = jsonDecode(payload);
      final status = data['status']?.toString().toUpperCase() ?? 'UNKNOWN';
      final correlationId = data['correlation_id'] as String?;

      await _db.commandResultsDao.insertResult(
        CommandResultsCompanion.insert(
          resourceId: resource.id,
          command: data['command'] ?? 'UNKNOWN',
          status: status == 'OK' ? 'success' : 'error',
          resultJson: Value(payload),
          timestamp: DateTime.now(),
        ),
      );

      if (correlationId != null) {
        final pendingStatus = status == 'OK' ? 'success' : 'failed';
        await _db.pendingCommandsDao.updateStatus(
          correlationId,
          pendingStatus,
          completedAt: DateTime.now(),
        );
      }
    } catch (e, s) {
      _log.warning('Failed to sync command result', e, s);
    }
  }

  // --- Helpers ---

  Future<DeviceEntity?> _ensureDeviceStub(
    String deviceTechnicalId,
    int homeId,
  ) async {
    try {
      // 1. Tenta buscar existente
      var device = await _db.devicesDao.getByDeviceId(deviceTechnicalId);
      if (device != null) {
        _log.info(
          '🟢 STUB FOUND: deviceId=$deviceTechnicalId (id=${device.id})',
        );
        return device;
      }

      // 2. Não existe? Cria Stub (Placeholder) para manter integridade referencial
      _log.info(
        '🟡 CREATING STUB: deviceId=$deviceTechnicalId, homeId=$homeId, role=UNKNOWN',
      );

      await _db.devicesDao.upsertDevice(
        DevicesV24Companion.insert(
          homeId: homeId,
          deviceId: deviceTechnicalId,
          role: 'UNKNOWN', // String direto em .insert()
          status: const Value('UNKNOWN'),
          lastSeen: Value(DateTime.now()),
        ),
      );

      // 3. Busca novamente para retornar a entidade completa (com ID gerado)
      final created = await _db.devicesDao.getByDeviceId(deviceTechnicalId);
      _log.info('✅ STUB CREATED: id=${created?.id}');
      return created;
    } catch (e, s) {
      _log.warning(
        'Race condition in stub creation for $deviceTechnicalId',
        e,
        s,
      );
      return null;
    }
  }

  Future<ResourceEntity?> _ensureResourceStub(
    String resourceTechnicalId,
    int homeId,
  ) async {
    try {
      var resource = await _db.resourcesDao.getResourceByTechnicalId(
        homeId,
        resourceTechnicalId,
      );
      if (resource != null) return resource;

      // Fix 9: Orphan Scope by Home
      final orphanDeviceId = 'orphan-resources-$homeId';
      var orphanDevice = await _ensureDeviceStub(orphanDeviceId, homeId);

      if (orphanDevice == null) return null;

      await _db.resourcesDao.upsertResourceTopology(
        homeId,
        orphanDevice.id,
        resourceTechnicalId,
        resourceTechnicalId,
        'unknown',
        '{}',
      );

      return await _db.resourcesDao.getResourceByTechnicalId(
        homeId,
        resourceTechnicalId,
      );
    } catch (e, s) {
      _log.warning(
        'Failed to create resource stub for $resourceTechnicalId',
        e,
        s,
      );
      return null;
    }
  }
}
