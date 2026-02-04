import 'package:flutter/material.dart';
import 'package:cii/core/database/app_database.dart';

class DeviceCustomizationDialog extends StatefulWidget {
  final DeviceEntity device;

  const DeviceCustomizationDialog({super.key, required this.device});

  @override
  State<DeviceCustomizationDialog> createState() =>
      _DeviceCustomizationDialogState();
}

class _DeviceCustomizationDialogState extends State<DeviceCustomizationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _roomController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.deviceId);
    _roomController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit_note, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Personalizar Dispositivo'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ID Técnico: ${widget.device.deviceId}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Identificador',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
      ],
    );
  }
}

/// Helper function to show the dialog
Future<void> showDeviceCustomizationDialog(
  BuildContext context,
  DeviceEntity device,
) {
  return showDialog(
    context: context,
    builder: (context) => DeviceCustomizationDialog(device: device),
  );
}
