import 'dart:convert';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/modules/environment/domain/entities/environment.dart';
import 'package:cii/modules/environment/domain/entities/air_quality.dart';
import 'package:cii/modules/environment/domain/repositories/i_environment_repository.dart';

class EnvironmentRepositoryImpl implements IEnvironmentRepository {
  final AppDatabase _db;
  final int _homeId;

  EnvironmentRepositoryImpl(this._db, this._homeId);

  @override
  Stream<Environment?> watchClimate(String id) {
    return _db.resourcesDao.watchDataByTechnicalId(_homeId, id).map((
      resourceData,
    ) {
      if (resourceData == null) return null;

      try {
        final json = jsonDecode(resourceData.dataJson) as Map<String, dynamic>;

        // Ensure timestamp is passed correctly or used from ResourceData
        // ResourceData has 'updatedAt' which is reliable DB timestamp
        return Environment.fromJson(
          json,
          id,
          timestamp: resourceData.updatedAt,
        );
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Stream<AirQuality?> watchAirQuality(String id) {
    return _db.resourcesDao.watchDataByTechnicalId(_homeId, id).map((
      resourceData,
    ) {
      if (resourceData == null) return null;

      try {
        final json = jsonDecode(resourceData.dataJson) as Map<String, dynamic>;
        return AirQuality.fromJson(json, id, timestamp: resourceData.updatedAt);
      } catch (e) {
        return null;
      }
    });
  }
}
