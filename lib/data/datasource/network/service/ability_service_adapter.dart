import '../../../models/ability_model.dart';
import '../../../models/api_response_model.dart';
import 'base_service.dart';
import 'ability_service.dart';

/// Adapter untuk AbilityService yang mengimplementasikan IListDetailService
///
/// Kelas ini menjembatani antara AbilityService yang sudah ada dengan
/// pola baru yang menggunakan IListDetailService sebagai interface
class AbilityServiceAdapter implements IListDetailService {
  final AbilityService _abilityService = AbilityService();

  @override
  Future<PaginatedApiResponse<ResourceListItem>> getList({
    int offset = 0,
    int limit = 100,
  }) {
    return _abilityService.getAbilityList(
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<Ability> getDetail(String identifier) {
    return _abilityService.getAbilityDetail(identifier);
  }

  // Delegasi ke AbilityService untuk metode dari BaseService

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return _abilityService.noSuchMethod(invocation);
  }
}
