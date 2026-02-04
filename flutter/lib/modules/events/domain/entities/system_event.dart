import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:cii/core/database/app_database.dart';

/// Entidade para eventos do sistema (doorbell, alarm, etc)
class SystemEvent extends Equatable {
  final int? id; // ID do banco de dados (nulo se não persistido ainda)
  final String type; // 'doorbell', 'alarm', 'presence'
  final String location;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const SystemEvent({
    this.id,
    required this.type,
    required this.location,
    required this.timestamp,
    required this.data,
  });

  factory SystemEvent.fromJson(
    Map<String, dynamic> json,
    String type,
    String location,
  ) {
    return SystemEvent(
      type: type,
      location: location,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['ts'] as int? ?? 0) * 1000,
      ),
      data: json,
    );
  }

  factory SystemEvent.fromEntityV24(EventEntityV24 e) {
    return SystemEvent(
      id: e.id,
      type: e.kind,
      location: e.resourceId?.toString() ?? 'unknown',
      timestamp: e.timestamp,
      data: e.payloadJson != null ? jsonDecode(e.payloadJson!) : {},
    );
  }

  @override
  List<Object?> get props => [id, type, location, timestamp, data];

  SystemEvent copyWith({
    int? id,
    String? type,
    String? location,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return SystemEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }
}
