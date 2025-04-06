import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/ability_model.dart';

class AbilityDetailState extends BaseState {
  final Ability? ability;
  final String currentAbilityId;
  final String currentAbilityName;
  final ScrollController scrollController;
  final TextEditingController searchController;

  const AbilityDetailState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.ability,
    this.currentAbilityId = '',
    this.currentAbilityName = '',
    required this.scrollController,
    required this.searchController,
  });

  @override
  AbilityDetailState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    Ability? ability,
    String? currentAbilityId,
    String? currentAbilityName,
    ScrollController? scrollController,
    TextEditingController? searchController,
  }) {
    return AbilityDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      ability: ability ?? this.ability,
      currentAbilityId: currentAbilityId ?? this.currentAbilityId,
      currentAbilityName: currentAbilityName ?? this.currentAbilityName,
      scrollController: scrollController ?? this.scrollController,
      searchController: searchController ?? this.searchController,
    );
  }
}
