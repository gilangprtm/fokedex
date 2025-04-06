import 'package:flutter/material.dart';
import '../../../../core/base/base_state_notifier.dart';
import '../../../../data/models/api_response_model.dart';
import '../../../../data/models/pokemon_list_item_model.dart';

/// State class for the Pokemon List Screen
class PokemonListState extends BaseState {
  // UI state
  final bool showTypeIcons;

  // Data state
  final List<ResourceListItem> pokemonList;
  final Map<int, PokemonList> pokemonDetails;
  final List<ResourceListItem> pokemonTypes;
  final List<ResourceListItem> filteredPokemonList;

  // Pagination state
  final int offset;
  final bool hasMoreData;

  // Filter state
  final String? activeTypeFilter;
  final String searchQuery;

  // Controllers - not stored in state, but passed in constructor for reference
  final ScrollController scrollController;
  final TextEditingController searchController;

  const PokemonListState({
    super.isLoading = false,
    super.error,
    super.stackTrace,
    this.showTypeIcons = false,
    this.pokemonList = const [],
    this.pokemonDetails = const {},
    this.pokemonTypes = const [],
    this.filteredPokemonList = const [],
    this.offset = 0,
    this.hasMoreData = true,
    this.activeTypeFilter,
    this.searchQuery = '',
    required this.scrollController,
    required this.searchController,
  });

  /// Get the list of Pokemon to display - either filtered or full list
  List<ResourceListItem> get displayPokemonList {
    return filteredPokemonList.isEmpty && activeTypeFilter == null
        ? pokemonList
        : filteredPokemonList;
  }

  /// Get Pokemon details by ID
  PokemonList? getPokemonDetails(int id) => pokemonDetails[id];

  @override
  PokemonListState copyWith({
    bool? isLoading,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    bool? showTypeIcons,
    List<ResourceListItem>? pokemonList,
    Map<int, PokemonList>? pokemonDetails,
    List<ResourceListItem>? pokemonTypes,
    List<ResourceListItem>? filteredPokemonList,
    int? offset,
    bool? hasMoreData,
    String? activeTypeFilter,
    bool clearActiveTypeFilter = false,
    String? searchQuery,
  }) {
    return PokemonListState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      showTypeIcons: showTypeIcons ?? this.showTypeIcons,
      pokemonList: pokemonList ?? this.pokemonList,
      pokemonDetails: pokemonDetails ?? this.pokemonDetails,
      pokemonTypes: pokemonTypes ?? this.pokemonTypes,
      filteredPokemonList: filteredPokemonList ?? this.filteredPokemonList,
      offset: offset ?? this.offset,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      activeTypeFilter: clearActiveTypeFilter
          ? null
          : activeTypeFilter ?? this.activeTypeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      scrollController: scrollController,
      searchController: searchController,
    );
  }
}
