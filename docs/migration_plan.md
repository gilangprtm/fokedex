# Migrating from Provider to Riverpod in Fokedex

This document outlines a comprehensive plan for migrating the Fokedex app from Provider to Riverpod for state management, while maintaining the existing folder structure and MVVM with clean architecture.

## 1. Project Overview & Current Provider Usage

### Project Structure

Fokedex currently follows a well-organized structure:

- **Core Utilities** (`lib/core/`)
  - Base Classes (`lib/core/base/*`)
  - Theme, Utils, Services, DI, etc.
- **Data Layer** (`lib/data/`)
  - Models (`lib/data/datasource/models/*`)
  - Local Storage (`lib/data/datasource/local/services/*`)
  - Network Services and Repositories
- **Presentation Layer** (`lib/presentation/`)
  - Providers (`lib/presentation/providers/*`)
  - Pages (`lib/presentation/pages/*`)
  - Widgets (`lib/presentation/widgets/*`)

### Current Provider Implementation

Fokedex uses Provider with several customizations:

1. **BaseProvider** (`lib/core/base/base_provider.dart`)

   - Extends `ChangeNotifier`
   - Includes lifecycle methods (`onInit`, `onReady`, `onClose`)
   - Property-specific notifications with `notifyPropertyListeners`
   - Batch updates with `beginBatch`/`endBatch`
   - Error handling and logging

2. **Provider Widgets** (`lib/core/base/provider_widget.dart`)

   - `ProviderPage` - Wrapper for pages using providers
   - `PropertySelector` - Optimizes rebuilds for specific properties
   - `SelectorWidget` - Uses Provider's `Selector` for efficient rebuilds

3. **Provider Registration** (`lib/presentation/routes/app_providers.dart`)

   - Registers app-wide providers

4. **Provider Usage in Pages**

   - Pages use `ProviderPage` to access providers
   - Components use `PropertySelector` for targeted rebuilds

5. **Dependency Injection**
   - Uses GetIt (`serviceLocator`) for service registration

## 2. Why Migrate to Riverpod?

### Benefits for Fokedex

1. **Compile-time Safety**: Riverpod catches errors at compile-time rather than runtime
2. **No BuildContext Dependency**: Providers can be accessed without context
3. **Code Organization**: Provider families and auto-dispose for better organization
4. **Improved Asynchronous Handling**: `AsyncValue` for cleaner async state management
5. **Targeted Rebuilds**: More efficient with `ref.watch` and `ref.select`
6. **Testing**: Easier to test with `ProviderContainer`
7. **Modularity**: Better support for modular code with provider overrides

### Specific Improvements for Fokedex Features

- **Pokemon List**: Better pagination with AsyncValue
- **Pokemon Detail**: Cleaner async data loading and error handling
- **Type Chart**: More efficient type comparisons with select
- **Offline Support**: Improved caching with AsyncValue and autoDispose

## 3. Migration Steps

The migration process is divided into 6 phases to ensure a smooth transition. Each phase focuses on specific components and includes a checklist to track progress.

### Phase 1: Preparation and Setup (Week 1)

**Objective:** Prepare the project for migration by adding Riverpod dependencies and identifying components to migrate.

- **Task 1.1: Add Riverpod Dependencies**

  - Update `pubspec.yaml` to include `flutter_riverpod` version `^2.5.0`.
  - Run `flutter pub get` to install dependencies.
  - **Status:** [x] Selesai

- **Task 1.2: Set Up ProviderScope in Entry Point**

  - Modify `main.dart` to use `ProviderScope` as the root application, replacing `MultiProvider` or `ChangeNotifierProvider`.
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 1.3: Identify All Providers and Pages**
  - List all providers in `lib/presentation/providers/` (e.g., `PokemonListProvider`, `PokemonDetailProvider`, `TypeChartProvider`, `LocationListProvider`, `LocationDetailProvider`).
  - List all pages in `lib/presentation/pages/` that use `ProviderPage` and `PropertySelector` (e.g., `PokemonListPage`, `PokemonDetailPage`, `TypeChartPage`, `LocationListPage`, `LocationDetailPage`).
  - **Status:** [ ] Belum selesai / [ ] Selesai

### Phase 2: Migrate Core Components (Week 1-2)

**Objective:** Replace core components in `lib/core/` with Riverpod equivalents.

- **Task 2.1: Replace BaseProvider with BaseStateNotifier**

  - Create a new file `lib/core/base/base_state_notifier.dart` for a base class using `StateNotifier`.
  - Retain features like lifecycle methods (`onInit`, `onReady`, `onClose`), logging, and error handling.
  - Replace `notifyPropertyListeners` with Riverpod mechanisms (`ref.watch`, `ref.select`).
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 2.2: Replace PropertySelector and ProviderPage**

  - Remove `PropertySelector` and `ProviderPage` from `lib/core/base/provider_widget.dart`.
  - Note that `PropertySelector` will be replaced with `ref.select`, and `ProviderPage` will be replaced with `ConsumerWidget` in later phases.
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 2.3: Migrate Dependency Injection**
  - Replace `serviceLocator` in `lib/core/di/service_locator.dart` with `Provider` in Riverpod for services like `LoggerService`, `ErrorHandlerService`, `PokemonService`, and `LocalPokemonService`.
  - Create a new file `lib/core/di/providers.dart` to define all service providers.
  - **Status:** [ ] Belum selesai / [ ] Selesai

### Phase 3: Migrate Providers and Pages (Week 2)

**Objective:** Migrate providers and their corresponding pages to use Riverpod.

- **Task 3.1: Migrate Welcome Screen**

  - Update `WelcomeProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `WelcomePage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure features like data loading and progress tracking remain functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 3.2: Migrate Home Screen**

  - Update `HomeProvider` in `lib/presentation/providers/` to use `Provider`
  - Update `HomePage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure navigation and UI features remain functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 3.3: Migrate Pokemon List Screen**

  - [ ] Create `PokemonListState` and `PokemonListNotifier`
  - [ ] Create `pokemonListProvider`
  - [ ] Update `PokemonListPage` to use Riverpod
  - [ ] Update `PokemonGridItem` to use Riverpod
  - [ ] Test pokemon list screen functionality

- **Task 3.4: Migrate Pokemon Detail Screen**
  - Update `PokemonDetailProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `PokemonDetailPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Use `StateNotifierProvider.family` for parameter handling
  - **Status:** [ ] Belum selesai / [ ] Selesai

### Phase 4: Migrate Providers and Pages (Part 2) (Week 3)

**Objective:** Migrate remaining providers and their corresponding pages to use Riverpod.

- **Task 4.1: Migrate Type Chart Screen**

  - Update `TypeChartProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `TypeChartPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure type chart visualization remains functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 4.2: Migrate Location List Screen**

  - Update `LocationListProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `LocationListPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure location list and search features remain functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 4.3: Migrate Location Detail Screen**
  - Update `LocationDetailProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `LocationDetailPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Use `StateNotifierProvider.family` for parameter handling
  - **Status:** [ ] Belum selesai / [ ] Selesai

### Phase 5: Migrate Providers and Pages (Part 3) (Week 4)

**Objective:** Migrate remaining providers and their corresponding pages to use Riverpod.

- **Task 5.1: Migrate Move List Screen**

  - Update `MoveListProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `MoveListPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure move list and search features remain functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 5.2: Migrate Ability List Screen**

  - Update `AbilityListProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `AbilityListPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure ability list and search features remain functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 5.3: Migrate Item List Screen**
  - Update `ItemListProvider` in `lib/presentation/providers/` to use `StateNotifier` dan `BaseStateNotifier`
  - Update `ItemListPage` in `lib/presentation/pages/` to use `ConsumerWidget`
  - Ensure item list and search features remain functional
  - **Status:** [ ] Belum selesai / [ ] Selesai

### Phase 6: Testing and Validation (Week 5)

**Objective:** Test all features after migration and provide suggestions for improvement.

- **Task 6.1: Test Pokémon List Feature**

  - Run the app and ensure the Pokémon list in `PokemonListPage` displays correctly, including type filtering and search.
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 6.2: Test Pokémon Detail Feature**

  - Ensure `PokemonDetailPage` displays Pokémon details correctly, including stats, abilities, and evolution chain.
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 6.3: Test Type Chart Feature**

  - Ensure `TypeChartPage` displays type effectiveness correctly.
  - **Status:** [ ] Belum selesai / [ ] Selesai

- **Task 6.4: Test Location Feature**

  - Ensure `
