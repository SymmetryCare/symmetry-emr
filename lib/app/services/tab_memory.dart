import 'dart:html' as html;

/// Remembers the selected tab of a tabbed screen across browser refreshes.
///
/// Uses `sessionStorage` so the value is scoped to the current browser tab,
/// survives a reload, and is not shared with other tabs on the same origin.
class TabMemory {
  static const String _prefix = 'tabMemory.';

  /// Returns the stored index for [key], or 0 when missing/invalid/out of range.
  static int read(String key, {required int pageCount}) {
    try {
      final index = int.tryParse(html.window.sessionStorage[_prefix + key] ?? '');
      if (index == null || index < 0 || index >= pageCount) return 0;
      return index;
    } catch (_) {
      return 0;
    }
  }

  static void write(String key, int index) {
    try {
      html.window.sessionStorage[_prefix + key] = '$index';
    } catch (_) {}
  }

  /// Clears every remembered tab — call when the session ends (logout).
  static void clearAll() {
    try {
      final storage = html.window.sessionStorage;
      storage.keys
          .where((k) => k.startsWith(_prefix))
          .toList()
          .forEach(storage.remove);
    } catch (_) {}
  }
}
