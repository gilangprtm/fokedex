import '../../../../core/base/base_network.dart';

/// HomeRepository yang bertanggung jawab untuk semua endpoint terkait home screen
class HomeRepository extends BaseRepository {
  /// Get home data including banners, featured items, etc.
  Future<dynamic> getHomeData() async {
    logDebug('Getting home data');
    try {
      final response = await dioService.get(
        '/home',
      );
      logDebug('Successfully retrieved home data');
      return response;
    } catch (e, stackTrace) {
      logError('Failed to get home data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get featured banners
  Future<dynamic> getBanners() async {
    logDebug('Getting banners');
    try {
      final response = await dioService.get(
        '/banners',
      );

      final List<dynamic> data = response.data;
      final banners =
          data.map((banner) => banner as Map<String, dynamic>).toList();

      logDebug('Successfully retrieved ${banners.length} banners');
      return banners;
    } catch (e, stackTrace) {
      logError('Failed to get banners', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get featured products
  Future<dynamic> getFeaturedProducts() async {
    logDebug('Getting featured products');
    try {
      final response = await dioService.get(
        '/products/featured',
      );

      final List<dynamic> data = response.data;
      final products =
          data.map((product) => product as Map<String, dynamic>).toList();

      logDebug('Successfully retrieved ${products.length} featured products');
      return products;
    } catch (e, stackTrace) {
      logError('Failed to get featured products',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get recent items
  Future<List<Map<String, dynamic>>> getRecentItems() async {
    logDebug('Getting recent items');
    try {
      final response = await dioService.get(
        '/items/recent',
      );

      final List<dynamic> data = response.data;
      final items = data.map((item) => item as Map<String, dynamic>).toList();

      logDebug('Successfully retrieved ${items.length} recent items');
      return items;
    } catch (e, stackTrace) {
      logError('Failed to get recent items', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
