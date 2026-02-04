import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/devices/presentation/providers/devices_providers.dart';
import 'package:cii/ui/widgets/hardware_card.dart';
import 'package:cii/core/database/daos/devices_dao.dart'; // ✅ Import DeviceWithHardware
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Página de Gerenciamento de Dispositivos (V2.4)
/// - Lista devices com seus resources
/// - Permite soft delete (device.deleteDevice)
/// - Devices deletados reaparecem se voltarem a dar sinal de vida (status update)
class DevicesManagementPage extends ConsumerWidget {
  const DevicesManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ V2.4: Watch devices + resources
    final devicesAsync = ref.watch(allPhysicalDevicesProvider);
    final resourcesAsync = ref.watch(resourcesByHomeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Dispositivos'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Buscar Dispositivos',
            onPressed: () async {
              try {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reinicializando descoberta (Reset)...'),
                    ),
                  );
                }

                // 0. Get current home
                final home = ref.read(selectedHomeProvider);
                if (home == null) return;

                // 1. Soft Reset: Mark all as inactive/offline
                final repository = ref.read(deviceRepositoryProvider);
                await repository.markAllOffline(home.id);

                // 2. Trigger retained messages to re-populate active devices
                await ref.read(mqttRepositoryProvider).refreshDevices();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: devicesAsync.when(
        data: (List<DeviceWithHardware> devices) {
          return resourcesAsync.when(
            data: (resources) {
              if (devices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices_other, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum dispositivo encontrado',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Dispositivos aparecerão ao conectarem',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // ✅ Agrupar resources por device
              final devicesWithResources = devices.map((deviceWithHw) {
                final deviceResources = resources
                    .where(
                      (r) => r.deviceId == deviceWithHw.device.id,
                    ) // ✅ INT == INT
                    .toList();
                return (device: deviceWithHw, resources: deviceResources);
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Hardware Físico',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...devicesWithResources.map((dwr) {
                    // ✅ Soft delete: swipe para deletar
                    return Dismissible(
                      key: Key(dwr.device.deviceId),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              'Remover',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar Remoção'),
                            content: Text(
                              'Remover dispositivo ${dwr.device.deviceId}?\n\n'
                              'Se o device voltar a dar sinal de vida, '
                              'ele reaparecerá automaticamente.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Remover'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        final repository = ref.read(deviceRepositoryProvider);
                        await repository.deleteDevice(dwr.device.deviceId);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Device ${dwr.device.deviceId} removido',
                              ),
                              action: SnackBarAction(
                                label: 'Desfazer',
                                onPressed: () {
                                  // Refresh para restaurar via retained messages
                                  ref
                                      .read(mqttRepositoryProvider)
                                      .refreshDevices();
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: HardwareCard(
                        physicalDevice: dwr.device,
                        logicalDevices: dwr.resources, // ✅ REAL DATA!
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Erro ao carregar resources: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar devices: $err')),
      ),
      // ✅ Botão de limpar todos (mantido de PhysicalDevicesPage)
      floatingActionButton: devicesAsync.maybeWhen(
        data: (devices) => devices.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Limpar Todos'),
                      content: const Text(
                        'Remover TODOS os dispositivos?\n\n'
                        'Dispositivos que voltarem a dar sinal de vida '
                        'reaparecerão automaticamente.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final repository = ref.read(deviceRepositoryProvider);
                    await repository.wipeAllDevices(); // ✅ FIX: FK-safe delete
                  }
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Limpar Todos'),
                backgroundColor: Colors.red,
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}
