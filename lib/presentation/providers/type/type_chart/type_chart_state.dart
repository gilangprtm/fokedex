import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/type_model.dart';

class TypeChartState extends BaseState {
  // Data state
  final List<ResourceListItem> typesList;
  final Map<String, TypeDetail> typeDetails;

  const TypeChartState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.typesList = const [],
    this.typeDetails = const {},
  });

  @override
  TypeChartState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    List<ResourceListItem>? typesList,
    Map<String, TypeDetail>? typeDetails,
  }) {
    return TypeChartState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      typesList: typesList ?? this.typesList,
      typeDetails: typeDetails ?? this.typeDetails,
    );
  }
}
