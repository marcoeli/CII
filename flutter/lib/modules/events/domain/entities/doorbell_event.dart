import 'package:equatable/equatable.dart';

class DoorbellEvent extends Equatable {
  final String locationId;
  final DateTime timestamp;

  const DoorbellEvent({required this.locationId, required this.timestamp});

  @override
  List<Object> get props => [locationId, timestamp];

  factory DoorbellEvent.fromJson(Map<String, dynamic> json, String locationId) {
    // Payload might be empty or contain timestamp
    return DoorbellEvent(locationId: locationId, timestamp: DateTime.now());
  }
}




