import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/mahas.dart';
import 'base_provider.dart';

/// Widget helper yang secara otomatis menginisialisasi provider dan memanggil
/// lifecycle methods pada waktu yang tepat.
///
/// Gunakan widget ini untuk membungkus setiap halaman yang menggunakan BaseProvider.
class ProviderWidget<T extends BaseProvider> extends StatefulWidget {
  final Widget Function(BuildContext context, T provider, Widget? child)
      builder;
  final T Function(BuildContext context, T provider)? onInitProvider;
  final Widget? child;

  const ProviderWidget({
    super.key,
    required this.builder,
    this.onInitProvider,
    this.child,
  });

  @override
  State<ProviderWidget<T>> createState() => _ProviderWidgetState<T>();
}

class _ProviderWidgetState<T extends BaseProvider>
    extends State<ProviderWidget<T>> {
  // Track whether provider has been initialized
  bool _initialized = false;
  late T _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the provider once to initialize it
    if (!_initialized) {
      _provider = Provider.of<T>(context, listen: false);
      _initializeProvider();
    }
  }

  void _initializeProvider() {
    _initialized = true;

    // Set context and call onInit
    _provider.setContext(context);
    _provider.onInit();

    // Post-frame callback to call onReady after UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.onReady();
    });

    // Call onInitProvider if provided
    if (widget.onInitProvider != null) {
      widget.onInitProvider!(context, _provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Instead of Consumer, use a custom selector or rely on widget rebuild
    return widget.builder(context, _provider, widget.child);
  }

  @override
  void dispose() {
    // Clear arguments dan parameters saat widget di-dispose
    Mahas.clearArguments();
    Mahas.clearParameters();
    super.dispose();
  }
}

/// Widget helper yang lebih sederhana untuk membungkus seluruh halaman
/// yang menggunakan BaseProvider.
class ProviderPage<T extends BaseProvider> extends StatelessWidget {
  final Widget Function(BuildContext context, T provider) builder;
  final Function(T provider)? onInitState;
  final T Function() createProvider;

  const ProviderPage({
    super.key,
    required this.builder,
    required this.createProvider,
    this.onInitState,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) {
        final provider = createProvider();
        // Hanya panggil onInitState sekali di sini
        if (onInitState != null) {
          onInitState!(provider);
        }
        return provider;
      },
      child: _OptimizedProviderWidget<T>(
        builder: (context, provider) => builder(context, provider),
      ),
    );
  }
}

/// Widget bantuan untuk memisahkan listen: false pada provider
class _OptimizedProviderWidget<T extends BaseProvider> extends StatefulWidget {
  final Widget Function(BuildContext context, T provider) builder;

  const _OptimizedProviderWidget({
    required this.builder,
  });

  @override
  State<_OptimizedProviderWidget<T>> createState() =>
      _OptimizedProviderWidgetState<T>();
}

class _OptimizedProviderWidgetState<T extends BaseProvider>
    extends State<_OptimizedProviderWidget<T>> {
  late T _provider;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the provider once to initialize it
    if (!_initialized) {
      _provider = Provider.of<T>(context, listen: false);
      _initializeProvider();
    }
  }

  void _initializeProvider() {
    _initialized = true;

    // Set context and call onInit
    _provider.setContext(context);
    _provider.onInit();

    // Post-frame callback to call onReady after UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.onReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _provider);
  }
}

/// Widget yang menggunakan Selector untuk property tertentu
/// sehingga hanya melakukan rebuild untuk property yang berubah
class PropertySelector<T extends BaseProvider, U> extends StatelessWidget {
  final String property;
  final U Function(T provider) selector;
  final Widget Function(BuildContext context, U value) builder;
  final bool Function(U previous, U next)? shouldRebuild;

  const PropertySelector({
    super.key,
    required this.property,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<T>(context, listen: false);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final selectedValue = selector(provider);
        return builder(context, selectedValue);
      },
    );
  }
}

/// Widget yang menggunakan Selector dari Provider package
/// untuk optimasi performa dengan hanya rebuild pada data yang diperlukan
class SelectorWidget<T extends BaseProvider, U> extends StatelessWidget {
  final U Function(BuildContext context, T provider) selector;
  final Widget Function(BuildContext context, U value) builder;
  final bool Function(U previous, U next)? shouldRebuild;

  const SelectorWidget({
    super.key,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<T, U>(
      selector: (context, provider) => selector(context, provider),
      builder: (context, value, _) => builder(context, value),
      shouldRebuild: shouldRebuild,
    );
  }
}
