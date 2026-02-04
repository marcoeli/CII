// Log model for the IoT Simulator

enum LogType { mqtt, system, event, cmd, ack, tel, err }

class LogMessage {
  final DateTime timestamp;
  final String nodeId;
  final String message;
  final String? topic;
  final String? payload;
  final String source;
  final LogType type;
  final bool isError;
  final bool isOutgoing;
  int count;

  LogMessage({
    required this.timestamp,
    required this.nodeId,
    required this.message,
    this.topic,
    this.payload,
    this.source = 'SIMULATOR',
    this.type = LogType.mqtt,
    this.isError = false,
    this.isOutgoing = false,
    this.count = 1,
  });

  String get formattedTime {
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.$ms';
  }
}
