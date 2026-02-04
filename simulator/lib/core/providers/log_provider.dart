import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_model.dart';

class LogState {
  final List<LogMessage> logs;
  final bool isPaused;
  final String filter;
  final bool showGlobal;

  LogState({
    required this.logs,
    this.isPaused = false,
    this.filter = '',
    this.showGlobal = false,
  });

  LogState copyWith({
    List<LogMessage>? logs,
    bool? isPaused,
    String? filter,
    bool? showGlobal,
  }) {
    return LogState(
      logs: logs ?? this.logs,
      isPaused: isPaused ?? this.isPaused,
      filter: filter ?? this.filter,
      showGlobal: showGlobal ?? this.showGlobal,
    );
  }
}

class LogNotifier extends Notifier<LogState> {
  static const int maxLogs = 2000;

  @override
  LogState build() {
    return LogState(logs: []);
  }

  void addLog(LogMessage newLog) {
    if (state.isPaused) return;

    final logs = List<LogMessage>.from(state.logs);

    // Debounce: check if same topic and payload as the last message
    if (logs.isNotEmpty) {
      final lastLog = logs.first;
      if (lastLog.nodeId == newLog.nodeId &&
          lastLog.topic == newLog.topic &&
          lastLog.payload == newLog.payload &&
          lastLog.message == newLog.message &&
          lastLog.type == newLog.type) {
        // Substituir o primeiro log por uma nova instância com timestamp atualizado e contador incrementado
        logs[0] = LogMessage(
          timestamp: newLog.timestamp,
          nodeId: lastLog.nodeId,
          message: lastLog.message,
          topic: lastLog.topic,
          payload: lastLog.payload,
          source: lastLog.source,
          type: lastLog.type,
          isError: lastLog.isError,
          isOutgoing: lastLog.isOutgoing,
          count: lastLog.count + 1,
        );
        state = state.copyWith(logs: logs);
        return;
      }
    }

    logs.insert(0, newLog);
    if (logs.length > maxLogs) {
      logs.removeLast();
    }
    state = state.copyWith(logs: logs);
  }

  void setPaused(bool paused) {
    state = state.copyWith(isPaused: paused);
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void setShowGlobal(bool show) {
    state = state.copyWith(showGlobal: show);
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  String exportLogsAsJson() {
    final list = state.logs.map((l) {
      dynamic content = l.payload ?? l.message;

      // Tenta decodificar o payload se parecer JSON, para evitar double-encoding no export
      if (l.payload != null &&
          (l.payload!.trim().startsWith('{') ||
              l.payload!.trim().startsWith('['))) {
        try {
          content = jsonDecode(l.payload!);
        } catch (_) {
          // Mantém como string se falhar
        }
      }

      return {
        'ts': l.timestamp.toIso8601String(),
        'type': l.type.name.toUpperCase(),
        'node': l.nodeId,
        'topic': l.topic,
        'payload': content,
      };
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  List<LogMessage> getFilteredLogs(String? selectedNodeId) {
    Iterable<LogMessage> result = state.logs;

    // 1. Filtragem por Escopo (Nó Selecionado vs Global)
    if (!state.showGlobal && selectedNodeId != null) {
      result = result.where((l) => l.nodeId == selectedNodeId);
    }

    // 2. Filtragem por Texto
    if (state.filter.isNotEmpty) {
      final query = state.filter.toLowerCase();
      result = result.where((l) {
        return l.message.toLowerCase().contains(query) ||
            (l.topic?.toLowerCase().contains(query) ?? false) ||
            (l.payload?.toLowerCase().contains(query) ?? false) ||
            l.nodeId.toLowerCase().contains(query);
      });
    }

    return result.toList();
  }
}

final logProvider = NotifierProvider<LogNotifier, LogState>(LogNotifier.new);
