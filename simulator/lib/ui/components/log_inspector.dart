import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/log_model.dart';
import '../../core/providers/log_provider.dart';

class LogInspector extends ConsumerWidget {
  final String? selectedNodeId;
  const LogInspector({super.key, this.selectedNodeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = ref.watch(logProvider);
    final filteredLogs = ref
        .watch(logProvider.notifier)
        .getFilteredLogs(selectedNodeId);

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        children: [
          _buildToolbar(context, ref, logState),
          const Divider(height: 1, color: Colors.white24),
          _buildTableHeader(),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.separated(
              itemCount: filteredLogs.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                return _buildLogRow(context, filteredLogs[index], logState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, LogState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text(
            'LOG INSPECTOR',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          // Checkbox Show Global
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: state.showGlobal,
                  onChanged: (val) => ref
                      .read(logProvider.notifier)
                      .setShowGlobal(val ?? false),
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.blue
                        : Colors.transparent,
                  ),
                ),
              ),
              const Text(
                'GLOBAL',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: SizedBox(
                height: 32,
                child: TextField(
                  onChanged: (val) {
                    ref.read(logProvider.notifier).setFilter(val);
                    ref.read(logProvider.notifier).setPaused(false);
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Filtrar...',
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      fontSize: 11,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: Colors.white.withAlpha(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 14,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: state.isPaused ? Icons.play_arrow : Icons.pause,
            color: state.isPaused ? Colors.green : Colors.orange,
            tooltip: state.isPaused ? 'Resumir' : 'Pausar',
            onPressed: () =>
                ref.read(logProvider.notifier).setPaused(!state.isPaused),
          ),
          _IconButton(
            icon: Icons.delete_outline,
            color: Colors.redAccent,
            tooltip: 'Limpar',
            onPressed: () => ref.read(logProvider.notifier).clearLogs(),
          ),
          _IconButton(
            icon: Icons.copy_all_outlined,
            color: Colors.blueAccent,
            tooltip: 'Copiar Log (JSON)',
            onPressed: () {
              final json = ref.read(logProvider.notifier).exportLogsAsJson();
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Log completo copiado como JSON!'),
                  backgroundColor: Colors.blueAccent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white.withAlpha(5),
      child: const Row(
        children: [
          SizedBox(width: 80, child: Text('TIME', style: _headerStyle)),
          SizedBox(width: 30, child: Text('T', style: _headerStyle)),
          SizedBox(width: 60, child: Text('FONTE', style: _headerStyle)),
          SizedBox(
            width: 140,
            child: Text('TÓPICO (ENCURTADO)', style: _headerStyle),
          ),
          Expanded(child: Text('PAYLOAD / DETALHES', style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _buildLogRow(BuildContext context, LogMessage log, LogState state) {
    return InkWell(
      onTap: () {
        if (log.payload != null) {
          _showPayloadDetail(context, log);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                log.formattedTime,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(width: 30, child: _buildTypeDot(log)),
            SizedBox(
              width: 60,
              child: Text(
                _getLabel(log.type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 140,
              child: Tooltip(
                message: log.topic ?? '',
                child: Text(
                  _truncateTopic(log.topic ?? '-'),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.payload ?? log.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (log.count > 1)
                        Text(
                          ' (x${log.count})',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_getLogSubText(log)} ${state.showGlobal ? ' | Node: ${log.nodeId}' : ''}',
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDot(LogMessage log) {
    Color color;
    switch (log.type) {
      case LogType.cmd:
        color = Colors.blue;
        break;
      case LogType.ack:
        color = Colors.green;
        break;
      case LogType.tel:
        color = Colors.white;
        break;
      case LogType.err:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(LogType type) {
    switch (type) {
      case LogType.cmd:
        return 'CMD';
      case LogType.ack:
        return 'ACK';
      case LogType.tel:
        return 'TEL';
      case LogType.err:
        return 'ERR';
      default:
        return 'LOG';
    }
  }

  String _getLogSubText(LogMessage log) {
    if (log.type == LogType.cmd) return '(Enviado pelo Simulador)';
    if (log.type == LogType.ack) return '(Confirmado)';
    if (log.type == LogType.tel) return '(Telemetria Cíclica)';
    if (log.type == LogType.err) return 'Falha na operação';
    return '';
  }

  String _truncateTopic(String topic) {
    if (topic.length <= 30) return topic;
    final parts = topic.split('/');
    if (parts.length > 3) {
      return '.../${parts.sublist(parts.length - 2).join('/')}';
    }
    return '${topic.substring(0, 30)}...';
  }

  void _showPayloadDetail(BuildContext context, LogMessage log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'DETALHES DO LOG',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailField('Timestamp:', log.formattedTime),
                _buildDetailField('Tipo:', _getLabel(log.type)),
                _buildDetailField('Source Node:', log.nodeId),
                _buildDetailField('Tópico MQTT:', log.topic ?? '-'),
                const SizedBox(height: 16),
                const Text(
                  'Payload / Mensagem:',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 4),
                _buildFormattedPayload(log.payload ?? log.message),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: log.payload ?? log.message),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payload copiado!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16, color: Colors.blueAccent),
            label: const Text(
              'COPIAR PAYLOAD',
              style: TextStyle(color: Colors.blueAccent, fontSize: 11),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              final fullJson = {
                'ts': log.timestamp.toIso8601String(),
                'type': log.type.name.toUpperCase(),
                'node': log.nodeId,
                'topic': log.topic,
                'payload':
                    (log.payload != null &&
                        (log.payload!.trim().startsWith('{') ||
                            log.payload!.trim().startsWith('[')))
                    ? jsonDecode(log.payload!)
                    : (log.payload ?? log.message),
              };
              Clipboard.setData(
                ClipboardData(
                  text: const JsonEncoder.withIndent('  ').convert(fullJson),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Log completo copiado como JSON!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.code, size: 16, color: Colors.orangeAccent),
            label: const Text(
              'COPIAR LOG COMPLETO',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'FECHAR',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedPayload(String content) {
    String formatted = content;
    try {
      // Tenta formatar se for JSON
      if (content.trim().startsWith('{') || content.trim().startsWith('[')) {
        final decoded = jsonDecode(content);
        formatted = const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {
      // Não é JSON ou falhou, mantém original
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        formatted,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Colors.white38,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color.withAlpha(200), size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 18,
    );
  }
}
