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

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, provider, child) {
        // Initialize provider if not already initialized
        if (!_initialized) {
          _initialized = true;

          // Set context and call onInit
          provider.setContext(context);
          provider.onInit();

          // Post-frame callback to call onReady after UI is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.onReady();
          });

          // Call onInitProvider if provided
          if (widget.onInitProvider != null) {
            widget.onInitProvider!(context, provider);
          }
        }

        return widget.builder(context, provider, child);
      },
      child: widget.child,
    );
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
      child: ProviderWidget<T>(
        // Hilangkan pemanggilan onInitState di sini
        builder: (context, provider, _) => builder(context, provider),
      ),
    );
  }
}
