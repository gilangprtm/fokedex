import '../../../../core/base/base_network.dart';
import '../../../datasource/models/api_response_model.dart';
import '../repository/location_repository.dart';

/// Service untuk mengelola logika bisnis terkait Location
class LocationService extends BaseService {
  final LocationRepository _locationRepository = LocationRepository();

  /// Ambil daftar Location dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getLocationList({
    int offset = 0,
    int? limit,
  }) async {
    return performanceAsync(
      operationName: 'LocationService.getLocationList',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _locationRepository.getLocationList(
            offset: offset,
            limit: limit,
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load location list',
            error: e,
            stackTrace: stackTrace,
            tag: 'LocationService',
          );
          rethrow;
        }
      },
      tag: 'LocationService',
    );
  }

  /// Ambil detail Location berdasarkan ID atau nama
  Future<Map<String, dynamic>> getLocationDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'LocationService.getLocationDetail',
      function: () async {
        try {
          return await _locationRepository.getLocationDetail(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load location detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'LocationService',
          );
          rethrow;
        }
      },
      tag: 'LocationService',
    );
  }
}
