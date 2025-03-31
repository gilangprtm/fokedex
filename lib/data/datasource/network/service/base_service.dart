import '../../../../../../core/base/base_network.dart';
import '../../../../../../data/models/api_response_model.dart';

/// Interface untuk service yang digunakan dalam provider generik
///
/// Memperluas BaseService yang sudah ada dengan menyediakan kontrak
/// untuk metode yang diperlukan oleh BaseListProvider dan BaseDetailProvider
abstract class IListDetailService extends BaseService {
  /// Mengambil daftar item dengan pagination
  ///
  /// [offset] adalah posisi mulai data yang diambil
  /// [limit] adalah jumlah maksimum data yang diambil
  Future<PaginatedApiResponse<ResourceListItem>> getList({
    int offset = 0,
    int limit = 100,
  });

  /// Mengambil detail item berdasarkan identifier
  ///
  /// [identifier] dapat berupa ID atau nama
  Future<dynamic> getDetail(String identifier);
}
