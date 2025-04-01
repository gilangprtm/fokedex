import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_providers.dart';
import 'type_chart_state.dart';
import 'type_chart_notifier.dart';

final typeChartProvider =
    StateNotifierProvider.autoDispose<TypeChartNotifier, TypeChartState>((ref) {
  final typeService = ref.watch(typeServiceProvider);
  return TypeChartNotifier(typeService, ref);
});
