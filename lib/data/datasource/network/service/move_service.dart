import '../../../../../../core/base/base_network.dart';
import '../../../../../data/models/api_response_model.dart';
import '../../../../../data/models/move_model.dart';
import '../repository/move_repository.dart';

/// Service untuk mengelola logika bisnis terkait Move
class MoveService extends BaseService {
  final MoveRepository _moveRepository = MoveRepository();

  /// Ambil daftar Move dengan pagination
  Future<PaginatedApiResponse<ResourceListItem>> getMoveList({
    int offset = 0,
    int? limit,
  }) async {
    return performanceAsync(
      operationName: 'MoveService.getMoveList',
      function: () async {
        try {
          // Repository sudah mengembalikan data dalam bentuk model
          return await _moveRepository.getMoveList(
            offset: offset,
            limit: limit,
          );
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load move list',
            error: e,
            stackTrace: stackTrace,
            tag: 'MoveService',
          );
          rethrow;
        }
      },
      tag: 'MoveService',
    );
  }

  /// Ambil detail Move berdasarkan ID atau nama
  Future<Move> getMoveDetail(String idOrName) async {
    return performanceAsync(
      operationName: 'MoveService.getMoveDetail',
      function: () async {
        try {
          return await _moveRepository.getMoveDetail(idOrName);
        } catch (e, stackTrace) {
          logger.e(
            'Failed to load move detail',
            error: e,
            stackTrace: stackTrace,
            tag: 'MoveService',
          );
          rethrow;
        }
      },
      tag: 'MoveService',
    );
  }
}
