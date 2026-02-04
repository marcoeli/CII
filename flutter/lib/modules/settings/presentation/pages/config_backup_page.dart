import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/services/config_backup_service.dart';

import 'package:cii/core/providers/global_providers.dart';

/// Página de Backup e Restore de Configurações
class ConfigBackupPage extends ConsumerStatefulWidget {
  const ConfigBackupPage({super.key});

  @override
  ConsumerState<ConfigBackupPage> createState() => _ConfigBackupPageState();
}

class _ConfigBackupPageState extends ConsumerState<ConfigBackupPage> {
  bool _isExporting = false;
  final bool _isImporting = false;
  String? _lastBackupPath;
  ImportResult? _lastImportResult;

  Future<void> _exportConfig() async {
    setState(() => _isExporting = true);

    try {
      final backupService = ConfigBackupService(ref.read(databaseProvider));
      final filePath = await backupService.exportToFile();

      setState(() {
        _lastBackupPath = filePath;
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Backup criado: ${filePath.split('/').last}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Compartilhar',
              textColor: Colors.white,
              onPressed: () => _shareConfig(),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareConfig() async {
    setState(() => _isExporting = true);

    try {
      final backupService = ConfigBackupService(ref.read(databaseProvider));
      await backupService.shareConfig();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importConfig() async {
    // TODO: Implement file picker when package is available
    // Para agora, mostrar mensagem
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Importação será implementada em breve'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    /* ORIGINAL CODE - uncomment when file_picker is available
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    setState(() => _isImporting = true);

    try {
      final backupService = ConfigBackupService(ref.read(databaseProvider));
      final importResult = await backupService.importFromFile(filePath);

      setState(() {
        _lastImportResult = importResult;
        _isImporting = false;
      });

      if (mounted) {
        if (importResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${importResult.summary}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${importResult.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isImporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao importar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup e Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text('Gerenciar Configurações', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Exporte suas configurações para backup ou importe de um arquivo anterior.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 32),

          // Export Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upload, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Exportar Configurações',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cria um arquivo JSON com todas as configurações, dispositivos e preferências.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportConfig,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isExporting ? 'Exportando...' : 'Salvar Backup',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isExporting ? null : _shareConfig,
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                        ),
                      ),
                    ],
                  ),
                  if (_lastBackupPath != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Último backup: ${_lastBackupPath!.split('/').last}',
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Import Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.download, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Importar Configurações',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Restaura configurações de um backup anterior. Os dados existentes serão mesclados.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isImporting ? null : _importConfig,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open),
                      label: Text(
                        _isImporting ? 'Importando...' : 'Selecionar Arquivo',
                      ),
                    ),
                  ),
                  if (_lastImportResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (_lastImportResult!.success
                                    ? Colors.green
                                    : Colors.red)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              (_lastImportResult!.success
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lastImportResult!.success
                                ? Icons.check_circle
                                : Icons.error,
                            color: _lastImportResult!.success
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lastImportResult!.summary,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info Section
          Card(
            color: theme.colorScheme.surfaceContainerLow,

            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text('Informações', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    icon: Icons.devices,
                    text: 'Dispositivos lógicos e físicos',
                  ),
                  _InfoItem(
                    icon: Icons.settings,
                    text: 'Configurações de dispositivos',
                  ),
                  _InfoItem(
                    icon: Icons.person,
                    text: 'Nomes e salas personalizadas',
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Credenciais MQTT NÃO são exportadas por segurança',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
