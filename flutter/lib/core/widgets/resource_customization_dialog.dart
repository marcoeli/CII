import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';

/// Diálogo para personalização de recursos (V2.4 Meta)
/// Permite editar Label, Room e Ícone, publicando no Broker MQTT.
/// Diálogo para personalização de recursos (V2.4 Meta)
/// Permite editar Label, Room e Ícone, publicando no Broker MQTT.
class ResourceCustomizationDialog extends ConsumerStatefulWidget {
  final ResourceEntity resource;

  const ResourceCustomizationDialog({super.key, required this.resource});

  @override
  ConsumerState<ResourceCustomizationDialog> createState() =>
      _ResourceCustomizationDialogState();
}

class _ResourceCustomizationDialogState
    extends ConsumerState<ResourceCustomizationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _roomController;
  String? _selectedIcon;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'water_level', 'icon': Icons.water},
    {'name': 'pump', 'icon': Icons.settings_input_component},
    {'name': 'cistern', 'icon': Icons.waves},
    {'name': 'tank', 'icon': Icons.opacity},
    {'name': 'climate', 'icon': Icons.thermostat},
    {'name': 'gas', 'icon': Icons.air},
    {'name': 'presence', 'icon': Icons.person_pin_circle},
    {'name': 'doorbell', 'icon': Icons.notifications},
    {'name': 'light', 'icon': Icons.lightbulb},
    {'name': 'power', 'icon': Icons.power},
  ];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.resource.label ?? widget.resource.resourceId,
    );
    _roomController = TextEditingController(text: widget.resource.room ?? '');
    // TODO: Recuperar ícone atual dos metadados se houver
  }

  @override
  void dispose() {
    _labelController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Personalizar Recurso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID: ${widget.resource.resourceId}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Nome (Label)',
                  hintText: 'Ex: Cisterna Principal',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Cômodo (Room)',
                  hintText: 'Ex: Área de Serviço',
                  prefixIcon: Icon(Icons.room_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Escolha um ícone:'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final item = _availableIcons[index];
                    final isSelected = _selectedIcon == item['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = item['name'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final repository = ref.read(mqttRepositoryProvider);

      // Publica no Broker MQTT (Verdade Assíncrona)
      await repository.updateResourceMeta(
        resourceId: widget.resource.resourceId,
        label: _labelController.text,
        room: _roomController.text,
        // icon: _selectedIcon, // Adicionar suporte a ícone no repository se necessário
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação enviada! Aguardando confirmação...'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }
}

/// Helper para exibir o diálogo
Future<void> showResourceCustomizationDialog(
  BuildContext context,
  ResourceEntity resource,
) {
  return showDialog(
    context: context,
    builder: (context) => ResourceCustomizationDialog(resource: resource),
  );
}
