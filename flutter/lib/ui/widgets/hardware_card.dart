import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
// import 'package:cii/core/providers/global_providers.dart'; // Unused
// import 'package:cii/core/utils/text_sanitizer.dart'; // Unused

/// Card que representa um Dispositivo Físico (Hardware)
/// e lista seus recursos lógicos (Sensores, Atuadores)
import 'package:cii/core/database/daos/devices_dao.dart'; // Para DeviceWithHardware
import 'package:cii/modules/devices/presentation/providers/devices_providers.dart'; // Para deviceRepositoryProvider

/// Card que representa um Dispositivo Físico (Hardware)
/// e lista seus recursos lógicos (Sensores, Atuadores)
class HardwareCard extends ConsumerStatefulWidget {
  final DeviceWithHardware physicalDevice;
  final List<ResourceEntity> logicalDevices;

  const HardwareCard({
    super.key,
    required this.physicalDevice,
    required this.logicalDevices,
  });

  @override
  ConsumerState<HardwareCard> createState() => _HardwareCardState();
}

class _HardwareCardState extends ConsumerState<HardwareCard> {
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.physicalDevice.role,
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Em V2.4, localization vem do label/room do resource.
    // Como acordado, room reflete o local do dispositivo.
    final commonLocation =
        widget.logicalDevices.firstOrNull?.room ?? 'Sem Local';

    final vendor = widget.physicalDevice.vendor ?? 'Unknown Vendor';
    final model = widget.physicalDevice.model ?? 'Generic';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Cabeçalho do Hardware
          ListTile(
            leading: Icon(
              Icons.router,
              color: widget.physicalDevice.status == 'ONLINE'
                  ? Colors.green
                  : Colors.grey,
              size: 32,
            ),
            title: Text(
              widget.physicalDevice.deviceId, // Owner Device ID
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$vendor | $model | ${widget.physicalDevice.firmwareVersion ?? "v?"}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'IP: ${widget.physicalDevice.ipAddress ?? "-"} | Local: $commonLocation',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.blue,
              ), // Info/Edit
              onPressed: () => _showEditDeviceDialog(context),
              tooltip: 'Detalhes do Dispositivo',
            ),
          ),

          const Divider(),

          // Lista de Recursos
          ...widget.logicalDevices.map((resource) {
            // Tentar extrair ícone do metadataJson se existir
            IconData icon = _getIconForKind(resource.kind);
            // TODO: Parse metadataJson para 'icon' personalizado

            return ListTile(
              leading: Icon(icon, size: 20),
              title: Text(resource.label ?? resource.resourceId),
              subtitle: Text(resource.room ?? "Sem Sala"), // Mostrar Room
              trailing: IconButton(
                icon: const Icon(Icons.settings, size: 20),
                onPressed: () => _showEditResourceDialog(context, resource),
                tooltip: 'Configurações do Recurso',
              ),
            );
          }),

          if (widget.logicalDevices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nenhum recurso associado.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForKind(String kind) {
    if (kind == 'pump') return Icons.power;
    if (kind == 'level') return Icons.water;
    if (kind == 'climate') return Icons.thermostat;
    if (kind == 'gas') return Icons.gas_meter;
    return Icons.device_unknown;
  }

  void _showEditDeviceDialog(BuildContext context) {
    final vendor = widget.physicalDevice.vendor ?? 'Unknown';
    final model = widget.physicalDevice.model ?? 'Generic';
    final firmware = widget.physicalDevice.firmwareVersion ?? 'v?';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes do Hardware'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField(
                context,
                'Device ID',
                widget.physicalDevice.deviceId,
              ),
              _buildReadOnlyField(context, 'Vendor', vendor),
              _buildReadOnlyField(context, 'Model', model),
              _buildReadOnlyField(context, 'Firmware', firmware),
              _buildReadOnlyField(
                context,
                'IP Address',
                widget.physicalDevice.ipAddress ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              const Text(
                'Gerenciamento de Firmware (OTA) e Logs disponível via Orquestrador.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    String initialValue,
    void Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),

          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          prefixIcon: Icon(
            Icons.edit,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  void _showEditResourceDialog(BuildContext context, ResourceEntity resource) {
    String newLabel = resource.label ?? '';
    String newRoom = resource.room ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configurações do Recurso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReadOnlyField(
                  context,
                  'Resource ID',
                  resource.resourceId,
                ),
                const SizedBox(height: 16),

                // Edição Local
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.1),

                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.perm_device_information,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Edição Local: Ajuste nomes e salas apenas para visualização neste App.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildEditableField(
                  context,
                  'Label (Nome Amigável)',
                  newLabel,
                  (val) => newLabel = val,
                ),
                _buildEditableField(
                  context,
                  'Sala (Room)',
                  newRoom,
                  (val) => newRoom = val,
                ),

                const SizedBox(height: 16),
                // Exemplo de botão futuro para Configuração Física
                if (resource.kind == 'level')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.settings_input_component),
                      label: const Text('Configurar Tanque'),
                      onPressed: () {
                        if (mounted) {
                          Navigator.pop(context); // Fecha dialog anterior
                        }
                        _showTankConfigDialog(context, resource);
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(deviceRepositoryProvider)
                      .updateResourceLocalMeta(
                        resource.resourceId,
                        label: newLabel.isNotEmpty ? newLabel : null,
                        room: newRoom.isNotEmpty ? newRoom : null,
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: $e')),
                    );
                  }
                }
              },
              child: const Text('Salvar Localmente'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerLow.withValues(alpha: 0.3),

          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        readOnly: true,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  void _showTankConfigDialog(BuildContext context, ResourceEntity resource) {
    // Placeholder para futura implementação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuração de Tanque em desenvolvimento...'),
      ),
    );
  }
}
