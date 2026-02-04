import 'package:cii/core/database/app_database.dart';

class WaterSensorAggregate {
  final ResourceEntity resource;
  final ResourceDataEntity? data;

  WaterSensorAggregate({required this.resource, this.data});
}

class WaterActuatorAggregate {
  final ResourceEntity resource;
  final ResourceStateEntity? state;
  final List<ResourceBindingEntity> bindings;

  WaterActuatorAggregate({
    required this.resource,
    this.state,
    required this.bindings,
  });
}
