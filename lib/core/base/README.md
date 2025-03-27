# Optimized Provider Pattern

Dokumentasi penggunaan pola Provider yang dioptimalkan untuk performa terbaik

## BaseProvider - Granular State Management

BaseProvider sekarang mendukung manajemen state yang granular, memungkinkan:

1. Notifikasi untuk properti spesifik
2. Batch updates untuk mengurangi rebuild
3. Optimasi run/runAsync methods

### Contoh Penggunaan:

```dart
class ProductProvider extends BaseProvider {
  List<Product> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Load products dengan notifikasi properti spesifik
  Future<void> loadProducts() async {
    await runAsync('loadProducts', () async {
      _isLoading = true;

      // Notifikasi hanya untuk loading state
      notifyPropertyListeners('isLoading');

      final data = await productRepository.getProducts();

      _products = data;
      _isLoading = false;
    }, properties: ['products', 'isLoading']);
  }

  // Update search query dengan notifikasi spesifik
  void updateSearchQuery(String query) {
    run('updateSearchQuery', () {
      _searchQuery = query;
    }, properties: ['searchQuery']);
  }

  // Batch update untuk multiple properties
  void resetFilters() {
    run('resetFilters', () {
      _searchQuery = '';
      _filter = null;
      _sortOrder = SortOrder.newest;
    }, properties: ['searchQuery', 'filter', 'sortOrder']);
  }
}
```

## Widget Optimization

Penggunaan widget yang dioptimalkan:

### 1. PropertySelector

Gunakan `PropertySelector` untuk mendengarkan perubahan pada properti spesifik:

```dart
PropertySelector<ProductProvider, bool>(
  property: 'isLoading',
  selector: (provider) => provider.isLoading,
  builder: (context, isLoading) {
    return isLoading
      ? CircularProgressIndicator()
      : ProductGrid();
  },
)
```

### 2. SelectorWidget

Gunakan `SelectorWidget` untuk mengoptimasi rebuild berdasarkan nilai data:

```dart
SelectorWidget<ProductProvider, List<Product>>(
  selector: (context, provider) => provider.filteredProducts,
  builder: (context, products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => ProductItem(products[index]),
    );
  },
  // Rebuild hanya jika list produk berubah
  shouldRebuild: (prev, next) => prev != next,
)
```

### 3. Optimized Provider Page

Halaman utama hanya menggunakan provider sekali dan mencegah rebuild:

```dart
class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderPage<ProductProvider>(
      createProvider: () => ProductProvider(),
      builder: (context, provider) {
        return Scaffold(
          appBar: AppBar(title: Text('Products')),
          body: Column(
            children: [
              // Bagian search hanya di-rebuild ketika searchQuery berubah
              PropertySelector<ProductProvider, String>(
                property: 'searchQuery',
                selector: (provider) => provider.searchQuery,
                builder: (context, query) => SearchBar(initialValue: query),
              ),

              // Loading indicator hanya di-rebuild ketika isLoading berubah
              PropertySelector<ProductProvider, bool>(
                property: 'isLoading',
                selector: (provider) => provider.isLoading,
                builder: (context, isLoading) {
                  return isLoading
                    ? LinearProgressIndicator()
                    : SizedBox.shrink();
                },
              ),

              // Product list hanya di-rebuild ketika products berubah
              SelectorWidget<ProductProvider, List<Product>>(
                selector: (context, provider) => provider.products,
                builder: (context, products) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) => ProductItem(products[index]),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Best Practices

1. **Pisahkan State By Frequency**:

   - High frequency updates: properti yang sering berubah
   - Low frequency updates: properti yang jarang berubah

2. **Gunakan Immutability**:

   - Selalu kembalikan unmodifiable copy dari collections (List, Map, etc.)
   - Buat objek baru saat update state (hindari mutasi langsung)

3. **Hindari Nested Providers**:

   - Gunakan SelectorWidget ketika perlu mengakses data dari provider lain
   - Pisahkan provider berdasarkan domain/feature, bukan UI

4. **Batch Updates**:

   - Gunakan beginBatch() dan endBatch() untuk perubahan multiple state
   - Atau gunakan properties parameter pada run/runAsync methods

5. **Memory Management**:
   - Implementasikan onClose() untuk membersihkan resources
   - Gunakan properti listen: false ketika hanya perlu akses provider tanpa rebuild
