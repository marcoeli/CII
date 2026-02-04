import 'dart:convert';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import '../../domain/entities/pump.dart';
import '../../domain/repositories/i_pump_repository.dart';

class PumpRepositoryImpl implements IPumpRepository {
  final AppDatabase _db;
  final MqttRepository _mqtt;
  final int _homeId;

  PumpRepositoryImpl(this._db, this._mqtt, this._homeId);

  @override
  Stream<Pump?> watchPump(String id) {
    return _db.resourcesDao.watchStateByTechnicalId(_homeId, id).map((
      resource,
    ) {
      if (resource == null) return null;
      try {
        final json = jsonDecode(resource.stateJson) as Map<String, dynamic>;
        return Pump.fromJson(json, id, timestamp: resource.updatedAt);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<bool> sendCommand(String id, bool turnOn, {bool force = false}) {
    return _mqtt.sendPumpCommand(id, turnOn, force: force);
  }

  @override
  Future<bool> setMode(String id, String mode) {
    return _mqtt.setPumpMode(id, mode);
  }
}
