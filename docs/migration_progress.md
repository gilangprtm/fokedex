# Riverpod Migration Progress

## Completed Tasks

- [x] 3.1 Home Screen

  - [x] Create HomeState
  - [x] Create HomeNotifier
  - [x] Create HomeProvider
  - [x] Update HomePage
  - [x] Optimize for performance

- [x] 3.2 Welcome Screen

  - [x] Create WelcomeState
  - [x] Create WelcomeNotifier
  - [x] Create WelcomeProvider
  - [x] Update WelcomePage
  - [x] Optimize for performance

- [x] 3.3 Pokemon List Screen
  - [x] Create PokemonListState
  - [x] Create PokemonListNotifier
  - [x] Create PokemonListProvider
  - [x] Update PokemonListPage
  - [x] Update PokemonGridItem
  - [x] Optimize for performance

## In Progress

- [ ] 3.4 Pokemon Detail Screen
  - [ ] Create PokemonDetailState
  - [ ] Create PokemonDetailNotifier
  - [ ] Create PokemonDetailProvider
  - [ ] Update PokemonDetailPage

## Upcoming

- [ ] 3.5 Type Chart Screen
- [ ] 3.6 Location List Screen
- [ ] 3.7 Location Detail Screen
- [ ] 3.8 Evolution Chain Screen
- [ ] 3.9 Move List Screen
- [ ] 3.10 Move Detail Screen

## Notes

- **BaseProvider** -> **BaseStateNotifier**: BaseProvider methods were migrated to equivalent BaseStateNotifier methods.
- **PropertySelector** -> **ref.watch()**: PropertySelector widgets were replaced with ref.watch() from Riverpod.
- **ProviderPage** -> **ConsumerWidget**: ProviderPage pattern was replaced with ConsumerWidget from Riverpod.
- **notifyPropertyListeners()** -> **state = state.copyWith()**: Property-specific notifications were replaced with immutable state updates.
- **Mounted checks**: Added mounted checks to prevent state updates after disposal.
- **Widget-level providers**: Removed context.watch<Provider>() calls in child widgets, passing data through constructor instead.
- **Manual Loading State**: Removed automatic loading state handling from helper methods to give full manual control.
- **Reduced Logging**: Removed redundant logger calls from methods, relying instead on the logging provided by helper methods.

## Phase 1: Preparation and Setup

### Task 1.1: Add Riverpod Dependencies

- Status: ✅ Completed
- Dependencies already added in pubspec.yaml:
  - flutter_riverpod: ^2.5.0
  - riverpod_annotation: ^2.5.0
  - riverpod_generator: ^2.5.0 (dev dependency)

### Task 1.2: Set Up ProviderScope in Entry Point

- Status: ✅ Completed
- ProviderScope already set up in main.dart

### Task 1.3: Identify All Providers and Pages

- Status: ✅ Completed

#### Providers to Migrate:

1. Welcome
   - welcome_provider.dart
2. Home
   - home_provider.dart
3. Pokemon
   - pokemon_list_provider.dart
   - pokemon_detail_provider.dart
4. Type
   - type_chart_provider.dart (to be confirmed)
5. Location
   - location_list_provider.dart (to be confirmed)
   - location_detail_provider.dart (to be confirmed)
6. Move
   - move_list_provider.dart (to be confirmed)
7. Item
   - item_list_provider.dart (to be confirmed)
8. Ability
   - ability_list_provider.dart (to be confirmed)

#### Pages to Migrate:

1. Welcome
   - welcome_page.dart
2. Home
   - home_page.dart
3. Pokemon
   - pokemon_list_page.dart
   - pokemon_detail_page.dart
4. Type
   - type_chart_page.dart (to be confirmed)
5. Location
   - location_list_page.dart (to be confirmed)
   - location_detail_page.dart (to be confirmed)
6. Move
   - move_list_page.dart (to be confirmed)
7. Item
   - item_list_page.dart (to be confirmed)
8. Ability
   - ability_list_page.dart (to be confirmed)

## Phase 2: Migrate Core Components

- Status: ✅ Completed

### Task 2.1: Replace BaseProvider with BaseStateNotifier

- Status: ✅ Completed
- Created `lib/core/base/base_state_notifier.dart` with:
  - `BaseState` class with common state properties (isLoading, error, stackTrace)
  - `BaseStateNotifier<T extends BaseState>` class with lifecycle methods
  - Helper methods for error handling and async operations
  - State management utilities

### Task 2.2: Replace PropertySelector and ProviderPage

- Status: ✅ Completed
- Created `lib/core/base/riverpod_widget.dart` with:
  - `BaseConsumerStatefulWidget` for stateful widgets
  - `StateNotifierConsumerPage` to replace ProviderPage
  - Extension methods for easier state selection (replacing PropertySelector)
  - `AsyncValueWidget` for handling loading/error states

### Task 2.3: Migrate Dependency Injection

- Status: ✅ Completed
- Created `lib/core/di/providers.dart` with:
  - Core service providers (LoggerService, ErrorHandlerService)
  - Network service providers (PokemonService)
  - Local service providers (LocalPokemonService)

## Updated Migration Structure Pattern

### New File Structure Pattern

For each feature, we now use a three-file structure:

- **feature_state.dart**: Contains the state class extending BaseState
- **feature_notifier.dart**: Contains the notifier class extending BaseStateNotifier
- **feature_provider.dart**: Contains the provider definition using StateNotifierProvider

This separation of concerns provides better organization and maintainability:

- State: Represents the data structure
- Notifier: Contains business logic and state mutations
- Provider: Defines how the state is provided to the UI

All future migrations should follow this pattern.

## Phase 3: Migrate Providers and Pages

- Status: 🔄 In Progress

### Task 3.1: Migrate Welcome Screen

- Status: ✅ Completed
- Created `welcome_state.dart` with:
  - `WelcomeState` class extending `BaseState`
  - State properties for loading status, progress, and messages
- Created `welcome_notifier.dart` with:
  - `WelcomeNotifier`

## Performance Optimization Patterns

We've applied the following optimization patterns to minimize unnecessary rebuilds:

1. **Top-level State Access**:

   - Use `ref.read(provider.notifier)` for accessing methods
   - Avoid using `ref.watch(provider)` at the top level unless necessary

2. **Selective State Watching**:

   - Use `ref.watch(provider.select((state) => state.specificProperty))` to watch only needed parts
   - For multiple properties, use map-based selection:
     ```dart
     ref.watch(provider.select((state) => {
       'prop1': state.prop1,
       'prop2': state.prop2,
     }))
     ```

3. **Consumer Widgets**:

   - Wrap specific UI parts with `Consumer` to create isolated rebuild zones
   - Each Consumer should only watch the specific state it needs

4. **List Item Optimization**:
   - Make list items watch only their own specific data
   - Use Consumer at the item level for independent updates

These patterns have significantly improved performance by reducing unnecessary rebuilds.
