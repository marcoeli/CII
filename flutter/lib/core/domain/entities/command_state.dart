/// Status de um comando enviado para um dispositivo
enum CommandStatus {
  /// Aguardando envio
  idle,

  /// Comando enviado, aguardando confirmação
  pending,

  /// Comando confirmado com sucesso
  confirmed,

  /// Timeout - sem resposta do dispositivo
  timeout,

  /// Comando falhou
  failed;

  /// Retorna true se o comando está em estado final (não pode mudar mais)
  bool get isFinal => this == confirmed || this == timeout || this == failed;

  /// Retorna true se o comando está em execução
  bool get isExecuting => this == pending;

  /// Retorna true se houve erro
  bool get isError => this == timeout || this == failed;
}

/// Estado de um comando enviado para dispositivo
class CommandState {
  /// ID único do comando (gerado)
  final String commandId;

  /// Tipo do comando (ex: "turn_on", "turn_off", "set_level")
  final String commandType;

  /// ID do dispositivo alvo
  final String deviceId;

  /// Status atual do comando
  final CommandStatus status;

  /// Timestamp de quando o comando foi enviado
  final DateTime sentAt;

  /// Timestamp de quando o comando foi confirmado (null se ainda não confirmado)
  final DateTime? confirmedAt;

  /// Mensagem de erro (se houver)
  final String? errorMessage;

  /// Payload do comando (para retry)
  final Map<String, dynamic>? payload;

  /// Número de tentativas de retry já feitas
  final int retryCount;

  const CommandState({
    required this.commandId,
    required this.commandType,
    required this.deviceId,
    required this.status,
    required this.sentAt,
    this.confirmedAt,
    this.errorMessage,
    this.payload,
    this.retryCount = 0,
  });

  /// Duração desde o envio
  Duration get duration => DateTime.now().difference(sentAt);

  /// Duração até confirmação (ou null se não confirmado)
  Duration? get confirmationDuration =>
      confirmedAt?.difference(sentAt);

  /// Retorna true se o comando expirou (>= timeout especificado)
  bool isTimedOut(Duration timeout) {
    return status == CommandStatus.pending && duration >= timeout;
  }

  /// Cria uma cópia com campos atualizados
  CommandState copyWith({
    CommandStatus? status,
    DateTime? confirmedAt,
    String? errorMessage,
    int? retryCount,
  }) {
    return CommandState(
      commandId: commandId,
      commandType: commandType,
      deviceId: deviceId,
      status: status ?? this.status,
      sentAt: sentAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      payload: payload,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  String toString() {
    return 'CommandState(id: $commandId, type: $commandType, '
        'device: $deviceId, status: $status, duration: ${duration.inSeconds}s)';
  }
}




