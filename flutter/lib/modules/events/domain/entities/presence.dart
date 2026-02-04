import 'package:equatable/equatable.dart';

class Presence extends Equatable {
  final String localId;
  final bool detected;
  final int lastSeenSecondsAgo;
  final DateTime lastUpdated;

  const Presence({
    required this.localId,
    required this.detected,
    required this.lastSeenSecondsAgo,
    required this.lastUpdated,
  });

  factory Presence.fromJson(Map<String, dynamic> json, String localId) {
    final timestamp = json['ts'] as int?;
    return Presence(
      localId: localId,
      detected: json['detected'] == true || json['presence'] == true,
      lastSeenSecondsAgo:
          (json['last_seen_seconds_ago'] ?? json['last_seen_s']) as int? ?? 0,
      lastUpdated: timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    localId,
    detected,
    lastSeenSecondsAgo,
    lastUpdated,
  ];

  Presence copyWith({
    String? localId,
    bool? detected,
    int? lastSeenSecondsAgo,
    DateTime? lastUpdated,
    String? displayName,
  }) {
    return Presence(
      localId: localId ?? this.localId,
      detected: detected ?? this.detected,
      lastSeenSecondsAgo: lastSeenSecondsAgo ?? this.lastSeenSecondsAgo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'detected': detected,
      'last_seen_seconds_ago': lastSeenSecondsAgo,
      'ts': lastUpdated.millisecondsSinceEpoch ~/ 1000,
    };
  }
}




