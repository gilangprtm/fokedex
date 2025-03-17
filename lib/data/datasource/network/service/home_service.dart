import 'dart:io';

import '../../../../core/base/base_network.dart';
import '../repository/home_repository.dart';

/// Service untuk mengelola logika bisnis terkait home screen
class HomeService extends BaseService {
  final HomeRepository _homeRepository = HomeRepository();

  Future<Map<String, dynamic>> getHomeScreenData() async {
    return performanceAsync(
      operationName: 'HomeService.getHomeScreenData',
      function: () async {
        try {
          // Ambil data dari berbagai endpoint secara paralel untuk optimasi kinerja
          final results = await Future.wait([
            _homeRepository.getBanners(),
          ]);

          // Susun data untuk UI
          final Map<String, dynamic> homeData = {
            'banners': results[0],
            'featuredProducts': results[1],
            'recentItems': results[2],
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          return homeData;
        } on SocketException catch (e, stackTrace) {
          throw Exception(
              'No internet connection. Please check your connection and try again.');
        } catch (e, stackTrace) {
          throw Exception('Failed to load home data: ${e.toString()}');
        }
      },
      tag: 'HomeService',
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
