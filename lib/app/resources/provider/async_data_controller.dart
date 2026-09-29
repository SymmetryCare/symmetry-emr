import 'package:flutter/foundation.dart';

/// Lightweight, reusable fetch-once-and-hold-state controller.
///
/// Meant to be created via a widget-scoped `ChangeNotifierProvider` (NOT
/// registered app-wide in main.dart) so its lifecycle matches the widget
/// that owns it: `create:` fetches once, Provider calls `dispose()`
/// automatically when that subtree unmounts. This is what lets the owning
/// widget be a plain StatelessWidget instead of holding a `late Future<T>`
/// field in a State class.
class AsyncDataController<T> extends ChangeNotifier {
  T? _data;
  Object? _error;
  bool _isLoading = true;
  bool _disposed = false;

  T? get data => _data;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  /// Runs [fetcher] once and stores the result. Safe to call again to
  /// refetch (e.g. after a filter change or a CRUD action) — reassigns
  /// state and notifies listeners, same as reassigning a cached Future did.

  Future<void> load(Future<T> Function() fetcher) async {
    _isLoading = true;
    _error = null;
    // Deferred one microtask: `load()` is commonly called directly from a
    // ChangeNotifierProvider's `create:` callback, which runs while that
    // provider's own element is still being built. Calling notifyListeners()
    // synchronously there makes the InheritedElement try to rebuild itself
    // before its current build finishes, tripping Flutter's "!_dirty"
    // assertion. Yielding first lets that build complete before listeners
    // (including the provider itself) are notified.
    await Future.microtask(() {});
    if (_disposed) return;
    notifyListeners();
    try {
      final result = await fetcher();
      if (_disposed) return;
      _data = result;
    } catch (e) {
      if (_disposed) return;
      _error = e;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
