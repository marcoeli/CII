import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'package:cii/core/domain/entities/command_state.dart';

/// Notifier para rastrear comandos pendentes
class PendingCommandNotifier extends Notifier<Map<String, CommandState>> {
  final _log = Logger('PendingCommandNotifier');
  final _uuid = const Uuid();

  /// Duração padrão de timeout (5 segundos)
  static const Duration defaultTimeout = Duration(seconds: 5);

  /// Timers ativos para cada comando
  final Map<String, Timer> _timeoutTimers = {};

  @override
  Map<String, CommandState> build() {
    return {};
  }

  /// Envia um comando e começa a rastrear seu estado
  String sendCommand({
    required String deviceId,
    required String commandType,
    Map<String, dynamic>? payload,
    Duration? timeout,
  }) {
    final commandId = _uuid.v4();
    final timeoutDuration = timeout ?? defaultTimeout;

    final commandState = CommandState(
      commandId: commandId,
      commandType: commandType,
      deviceId: deviceId,
      status: CommandStatus.pending,
      sentAt: DateTime.now(),
      payload: payload,
    );

    // Adicionar ao estado
    state = {...state, commandId: commandState};

    _log.info('📤 Command sent: $commandId ($commandType) to $deviceId');

    // Iniciar timer de timeout
    _startTimeoutTimer(commandId, timeoutDuration);

    return commandId;
  }

  /// Confirma que um comando foi executado com sucesso
  void confirmCommand(String commandId) {
    final command = state[commandId];
    if (command == null) {
      _log.warning(
        '⚠️  Tentativa de confirmar comando inexistente: $commandId',
      );
      return;
    }

    if (command.status.isFinal) {
      _log.warning('⚠️  Comando já finalizado: $commandId');
      return;
    }

    _cancelTimeoutTimer(commandId);

    final updatedCommand = command.copyWith(
      status: CommandStatus.confirmed,
      confirmedAt: DateTime.now(),
    );

    state = {...state, commandId: updatedCommand};

    _log.info(
      '✅ Command confirmed: $commandId in ${updatedCommand.confirmationDuration?.inMilliseconds}ms',
    );

    _scheduleRemoval(commandId, const Duration(seconds: 3));
  }

  /// Marca comando como timeout
  void _timeoutCommand(String commandId) {
    final command = state[commandId];
    if (command == null || command.status.isFinal) return;

    final updatedCommand = command.copyWith(
      status: CommandStatus.timeout,
      errorMessage:
          'Timeout: dispositivo não respondeu em ${command.duration.inSeconds}s',
    );

    state = {...state, commandId: updatedCommand};

    _log.warning(
      '⏱️  Command timeout: $commandId after ${command.duration.inSeconds}s',
    );
  }

  /// Marca comando como falho
  void failCommand(String commandId, String errorMessage) {
    final command = state[commandId];
    if (command == null || command.status.isFinal) return;

    _cancelTimeoutTimer(commandId);

    final updatedCommand = command.copyWith(
      status: CommandStatus.failed,
      errorMessage: errorMessage,
    );

    state = {...state, commandId: updatedCommand};

    _log.severe('❌ Command failed: $commandId - $errorMessage');
  }

  /// Retry de um comando falhado
  String? retryCommand(String commandId) {
    final command = state[commandId];
    if (command == null) {
      _log.warning('⚠️  Comando não encontrado para retry: $commandId');
      return null;
    }

    if (!command.status.isError) {
      _log.warning(
        '⚠️  Apenas comandos com erro podem ser retried: $commandId',
      );
      return null;
    }

    if (command.retryCount >= 3) {
      _log.warning('⚠️  Máximo de retries atingido para: $commandId');
      return null;
    }

    _log.info(
      '🔄 Retrying command: $commandId (attempt ${command.retryCount + 1})',
    );

    state = Map.from(state)..remove(commandId);

    final newCommandId = _uuid.v4();
    final newCommand = CommandState(
      commandId: newCommandId,
      commandType: command.commandType,
      deviceId: command.deviceId,
      status: CommandStatus.pending,
      sentAt: DateTime.now(),
      payload: command.payload,
      retryCount: command.retryCount + 1,
    );

    state = {...state, newCommandId: newCommand};

    _startTimeoutTimer(newCommandId, defaultTimeout);

    return newCommandId;
  }

  /// Remove um comando do estado
  void removeCommand(String commandId) {
    _cancelTimeoutTimer(commandId);
    state = Map.from(state)..remove(commandId);
    _log.fine('🗑️  Command removed: $commandId');
  }

  /// Limpa todos os comandos
  void clearAll() {
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();
    state = {};
    _log.info('🗑️  All commands cleared');
  }

  void _startTimeoutTimer(String commandId, Duration timeout) {
    _timeoutTimers[commandId] = Timer(timeout, () {
      _timeoutCommand(commandId);
      _timeoutTimers.remove(commandId);
    });
  }

  void _cancelTimeoutTimer(String commandId) {
    _timeoutTimers[commandId]?.cancel();
    _timeoutTimers.remove(commandId);
  }

  void _scheduleRemoval(String commandId, Duration delay) {
    Timer(delay, () {
      if (state.containsKey(commandId)) {
        removeCommand(commandId);
      }
    });
  }
}

/// Provider global para comandos pendentes
final pendingCommandProvider =
    NotifierProvider<PendingCommandNotifier, Map<String, CommandState>>(
      PendingCommandNotifier.new,
    );

/// Provider para verificar se um dispositivo tem comandos pendentes
final deviceHasPendingCommandsProvider = Provider.family<bool, String>((
  ref,
  deviceId,
) {
  final commands = ref.watch(pendingCommandProvider);
  return commands.values.any(
    (cmd) => cmd.deviceId == deviceId && cmd.status == CommandStatus.pending,
  );
});

/// Provider para obter comandos pendentes de um dispositivo
final devicePendingCommandsProvider =
    Provider.family<List<CommandState>, String>((ref, deviceId) {
      final commands = ref.watch(pendingCommandProvider);
      return commands.values
          .where(
            (cmd) =>
                cmd.deviceId == deviceId && cmd.status == CommandStatus.pending,
          )
          .toList();
    });




