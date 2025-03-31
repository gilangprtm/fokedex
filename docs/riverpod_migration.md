# Riverpod Migration Documentation

## Overview

Dokumentasi ini menjelaskan implementasi Riverpod untuk state management di aplikasi Fokedex, menggantikan sistem provider sebelumnya. Fokus utama adalah pada optimasi performa dan best practices dalam penggunaan Riverpod.

## Implementasi yang Sudah Selesai

1. Welcome Screen
2. Home Screen
3. Pokemon List Screen
4. Pokemon Detail Screen

## Pola Implementasi

### 1. Struktur File

```
lib/
  ├── presentation/
  │   ├── providers/
  │   │   └── [feature]/
  │   │       ├── [feature]_state.dart
  │   │       ├── [feature]_notifier.dart
  │   │       └── [feature]_provider.dart
  │   └── pages/
  │       └── [feature]/
  │           └── [feature]_page.dart
```

### 2. State Management Pattern

#### State Class

```dart
class FeatureState extends BaseState {
  // Data properties
  final DataType? data;

  // UI state properties
  final bool isLoading;
  final Object? error;

  // Constructor
  const FeatureState({
    super.isLoading = false,
    super.error,
    this.data,
  });

  // Copy with method
  FeatureState copyWith({
    bool? isLoading,
    Object? error,
    DataType? data,
  }) {
    return FeatureState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}
```

#### Notifier Class

```dart
class FeatureNotifier extends BaseStateNotifier<FeatureState> {
  final Service _service;

  FeatureNotifier({
    required FeatureState initialState,
    required Ref ref,
    required Service service,
  }) : _service = service,
       super(initialState, ref);

  // Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    // Initialize logic
  }

  // Business logic methods
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.getData();
      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e,
        isLoading: false,
      );
    }
  }
}
```

#### Provider Definition

```dart
final featureProvider = StateNotifierProvider.autoDispose<FeatureNotifier, FeatureState>((ref) {
  final service = ref.watch(serviceProvider);
  return FeatureNotifier(
    initialState: const FeatureState(),
    ref: ref,
    service: service,
  );
});
```

## Optimasi Performa

### 1. Selective State Watching

```dart
// ❌ Avoid watching entire state
final state = ref.watch(featureProvider);

// ✅ Watch only needed properties
final isLoading = ref.watch(featureProvider.select((state) => state.isLoading));
final data = ref.watch(featureProvider.select((state) => state.data));
```

### 2. Granular Loading States

```dart
// In notifier
bool _isLoadingSpecific = false;
bool get isLoadingSpecific => _isLoadingSpecific;

// In UI
final isLoading = ref.read(featureProvider.notifier).isLoadingSpecific;
```

### 3. Consumer Usage

```dart
// ❌ Avoid wrapping entire widget tree
Consumer(
  builder: (context, ref, child) => EntireWidgetTree(),
)

// ✅ Wrap only widgets that need state
Column(
  children: [
    // Static widgets
    HeaderWidget(),

    // State-dependent widgets
    Consumer(
      builder: (context, ref, child) => DynamicContent(),
    ),

    // More static widgets
    FooterWidget(),
  ],
)
```

### 4. Computed Properties

```dart
// In state class
String? get computedValue {
  if (data == null) return null;
  return expensiveComputation(data!);
}
```

## Best Practices

### 1. State Organization

- Pisahkan state UI dari state data
- Gunakan computed properties untuk nilai yang dihitung
- Batasi jumlah property dalam state

### 2. Error Handling

```dart
try {
  // Operation
} catch (e, stack) {
  state = state.copyWith(
    error: e,
    stackTrace: stack,
    isLoading: false,
  );
}
```

### 3. Loading State Management

```dart
// Set loading at start
state = state.copyWith(isLoading: true);

try {
  // Operation
} finally {
  // Always reset loading state
  state = state.copyWith(isLoading: false);
}
```

### 4. Dependency Injection

```dart
// Service providers
final serviceProvider = Provider<Service>((ref) {
  return Service();
});

// Repository providers
final repositoryProvider = Provider<Repository>((ref) {
  final service = ref.watch(serviceProvider);
  return Repository(service);
});
```

## Contoh Implementasi Lengkap

### Pokemon Detail Screen

```dart
// State
class PokemonDetailState extends BaseState {
  final Pokemon? pokemon;
  final List<EvolutionStage> evolutionStages;
  final String currentPokemonId;

  const PokemonDetailState({
    super.isLoading = false,
    super.error,
    this.pokemon,
    this.evolutionStages = const [],
    this.currentPokemonId = '',
  });

  PokemonDetailState copyWith({...}) {...}
}

// Notifier
class PokemonDetailNotifier extends BaseStateNotifier<PokemonDetailState> {
  bool _isLoadingEvolution = false;
  bool get isLoadingEvolution => _isLoadingEvolution;

  Future<void> loadPokemonDetail(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final pokemon = await _pokemonService.getPokemonDetail(id);
      state = state.copyWith(
        pokemon: pokemon,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e,
        isLoading: false,
      );
    }
  }
}

// Provider
final pokemonDetailProvider = StateNotifierProvider.autoDispose<PokemonDetailNotifier, PokemonDetailState>((ref) {
  final service = ref.watch(pokemonServiceProvider);
  return PokemonDetailNotifier(
    initialState: const PokemonDetailState(),
    ref: ref,
    service: service,
  );
});
```

## Checklist untuk Fitur Baru

1. Struktur File

   - [ ] Buat state class
   - [ ] Buat notifier class
   - [ ] Buat provider
   - [ ] Implementasi UI dengan Consumer

2. Optimasi Performa

   - [ ] Gunakan select() untuk state watching
   - [ ] Implementasi granular loading states
   - [ ] Batasi Consumer scope
   - [ ] Gunakan computed properties

3. Error Handling

   - [ ] Implementasi try-catch
   - [ ] Proper error state management
   - [ ] User-friendly error messages

4. Loading States

   - [ ] Set loading at operation start
   - [ ] Reset loading in finally block
   - [ ] Implementasi loading UI

5. Testing
   - [ ] Unit tests untuk state
   - [ ] Unit tests untuk notifier
   - [ ] Widget tests untuk UI
   - [ ] Integration tests jika diperlukan
