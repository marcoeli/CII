import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/utils/datetime_utils.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/events/presentation/providers/events_providers.dart';
import 'package:cii/modules/home/presentation/providers/home_providers.dart';
import 'dart:convert';
import 'package:cii/core/database/app_database.dart';

class EventsTabContent extends ConsumerWidget {
  const EventsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Histórico de eventos (para aba "Eventos")
    final eventsAsync = ref.watch(eventsWithResourcesStreamProvider);
    // 2. Alertas ativos (para aba "Alertas")
    final activeAlertsAsync = ref.watch(activeAlertingResourcesProvider);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Alertas', icon: Icon(Icons.warning_amber_rounded)),
              Tab(text: 'Eventos', icon: Icon(Icons.history)),
              Tab(text: 'Presença', icon: Icon(Icons.sensors)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1. Alertas Tab (Mostra estados ATIVOS de recursos)
                activeAlertsAsync.when(
                  data: (resources) => _buildActiveAlertsList(
                    resources,
                    emptyMessage: 'Nenhum alerta ativo.',
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                ),

                // 2. Eventos Tab (Histórico Completo)
                eventsAsync.when(
                  data: (events) =>
                      _buildEventList(events, emptyMessage: 'Histórico vazio.'),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                ),

                // 3. Presença Tab (Resumo de Status + Histórico)
                Column(
                  children: [
                    // Resumo de Sensores (Live Status)
                    ref
                        .watch(occupancyResourcesProvider)
                        .when(
                          data: (resources) {
                            if (resources.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              height: 100,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: resources.length,
                                itemBuilder: (context, index) {
                                  final res = resources[index];
                                  return _OccupancyStatusCard(resource: res);
                                },
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                    const Divider(height: 1),
                    Expanded(
                      child: eventsAsync.when(
                        data: (events) {
                          final presence = events.where((row) {
                            final db = ref.watch(databaseProvider);
                            final event = row.readTable(db.eventsV24);
                            final kind = event.kind.toLowerCase();
                            return kind == 'presence' ||
                                kind == 'doorbell' ||
                                kind.contains('presence') ||
                                kind.contains('doorbell');
                          }).toList();
                          return _buildEventList(
                            presence,
                            emptyMessage: 'Nenhuma detecção recente.',
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Erro: $e')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói lista de alertas baseada no estado vivo dos recursos
  Widget _buildActiveAlertsList(
    List<dynamic> rows, {
    required String emptyMessage,
  }) {
    if (rows.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return _ActiveAlertCard(row: row);
      },
    );
  }

  Widget _buildEventList(List<dynamic> rows, {required String emptyMessage}) {
    if (rows.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return _EventCardV24(row: row);
      },
    );
  }
}

class _ActiveAlertCard extends ConsumerWidget {
  final dynamic row; // TypedResult de drift

  const _ActiveAlertCard({required this.row});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extraímos os dados da linha (HomeId, Resource, ResourceData)
    // Em V2.4 ResourceData contém o campo alert
    final db = ref.watch(databaseProvider);
    final resource = row.readTable(db.resourcesV24);
    final data = row.readTableOrNull(db.resourceData);

    String alertMessage = 'Alerta Desconhecido';
    String details = '';

    if (data != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(data.dataJson);
        final rawAlert = (json['alert']?.toString() ?? 'NORMAL').toUpperCase();

        switch (rawAlert) {
          case 'CRITICAL':
            alertMessage = 'Crítico';
            break;
          case 'WARN':
            alertMessage = 'Aviso';
            break;
          default:
            alertMessage = 'Normal';
        }

        // Remove alert field for cleaner details
        final cleanData = Map.from(json)
          ..remove('alert')
          ..remove('ts');
        details = cleanData.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
      } catch (_) {}
    }

    Color cardColor;
    IconData icon;

    if (alertMessage == 'Crítico') {
      cardColor = Colors.red.shade900.withValues(alpha: 0.8);

      icon = Icons.error;
    } else if (alertMessage == 'Aviso') {
      cardColor = Colors.orange.shade800.withValues(alpha: 0.8);

      icon = Icons.warning_amber_rounded;
    } else {
      cardColor = Colors.blue.shade900.withValues(alpha: 0.8);

      icon = Icons.info_outline;
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          '${resource.label}: $alertMessage',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          details,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}

class _EventCardV24 extends ConsumerWidget {
  final dynamic row;

  const _EventCardV24({required this.row});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final event = row.readTable(db.eventsV24);
    final resource = row.readTableOrNull(db.resourcesV24);

    final severity = event.severity.toUpperCase();

    Color color;
    IconData icon;

    switch (severity) {
      case 'CRITICAL':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'WARNING':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'SUCCESS':
      case 'RESOLVED':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    String label = resource?.label ?? event.kind.toUpperCase();
    String alertFriendly = '';

    switch (event.severity.toLowerCase()) {
      case 'critical':
        alertFriendly = 'Falha Crítica';
        break;
      case 'warning':
        alertFriendly = 'Aviso';
        break;
      default:
        alertFriendly = 'Info';
    }

    String payloadDetails = '';
    if (event.payloadJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(event.payloadJson!);
        final cleanData = Map.from(json)
          ..remove('alert')
          ..remove('ts');
        if (cleanData.isNotEmpty) {
          payloadDetails = cleanData.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ');
        } else {
          final rawAlert = json['alert']?.toString();
          payloadDetails = rawAlert == 'CRITICAL'
              ? 'Nível Crítico Detectado'
              : (rawAlert == 'WARN' ? 'Aviso Detectado' : 'Normalizado');
        }
      } catch (_) {
        payloadDetails = event.payloadJson!;
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),

          child: Icon(icon, color: color),
        ),
        title: Text(
          '$label: $alertFriendly',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payloadDetails.isEmpty ? 'Evento Registrado' : payloadDetails),
            const SizedBox(height: 4),
            Text(
              DateTimeUtils.formatRelative(event.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _OccupancyStatusCard extends ConsumerWidget {
  final ResourceEntity resource;

  const _OccupancyStatusCard({required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos o estado vivo deste recurso
    final home = ref.watch(selectedHomeProvider);
    if (home == null) return const SizedBox.shrink();

    final stateAsync = ref.watch(
      resourceStateByTechnicalIdProvider((home.id, resource.resourceId)),
    );

    return stateAsync.when(
      data: (state) {
        bool isActive = false;
        if (state != null) {
          try {
            final map = jsonDecode(state.stateJson);
            // Suporta detected (v2.4), motion ou occupancy (legado/hibrido)
            isActive =
                map['detected'] == true ||
                map['motion'] == true ||
                map['occupancy'] == true;
          } catch (_) {}
        }

        final color = isActive ? Colors.orange : Colors.grey.shade400;
        final icon = resource.kind == 'doorbell'
            ? (isActive ? Icons.notifications_active : Icons.notifications)
            : (isActive ? Icons.motion_photos_on : Icons.sensors);

        return Container(
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),

            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                resource.label ?? resource.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.orange.shade900
                      : Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
