import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/location_model.dart';
import '../repository/location_repository.dart';

/// Service untuk mengelola logika bisnis terkait Location
class LocationService extends BaseService {
  final LocationRepository _locationRepository = LocationRepository();

  /// Ambil daftar Location dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getLocationList({
    int offset = 0,
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Cache key yang unik berdasarkan parameter
    final cacheKey = 'locations_list_${offset}_${limit ?? "all"}';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'LocationService.getLocationList',
      fetchFunction: () async {
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
      fromJson: (json) => PaginatedApiResponse<ResourceListItem>.fromJson(
        json,
        (item) => ResourceListItem.fromJson(item),
      ),
      tag: 'LocationService',
    );
  }

  /// Ambil detail Location berdasarkan ID atau nama
  Future<Location> getLocationDetail(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'location_detail_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'LocationService.getLocationDetail',
      fetchFunction: () async {
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
      fromJson: (json) => Location.fromJson(json),
      tag: 'LocationService',
    );
  }

  /// Ambil detail Location Area berdasarkan ID atau nama
  Future<LocationAreaDetail> getLocationAreaDetail(String idOrName,
      {bool forceRefresh = false}) async {
    // Cache key yang unik berdasarkan ID/nama
    final cacheKey = 'location_area_detail_$idOrName';

    // Gunakan cachedOperationAsync dengan TTL 7 hari
    return cachedOperationAsync(
      cacheKey: cacheKey,
      ttlMinutes: 60 * 24 * 7, // 7 hari
      forceRefresh: forceRefresh,
      operationName: 'LocationService.getLocationAreaDetail',
      fetchFunction: () async {
        try {
          return await _locationRepository.getLocationAreaDetail(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load location area detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'LocationService',
          );
          rethrow;
        }
      },
      fromJson: (json) => LocationAreaDetail.fromJson(json),
      tag: 'LocationService',
    );
  }
}
