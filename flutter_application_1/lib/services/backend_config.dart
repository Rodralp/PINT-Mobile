import 'package:flutter/foundation.dart';

import 'local_storage.dart';

class BackendConfig {
  BackendConfig._();

  static const String baseUrlKey = 'backend_base_url';
  static String _fallbackBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.65.8.74:4000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:4000/api';
      case TargetPlatform.fuchsia:
        return 'http://localhost:4000/api';
    }
  }

  static final String defaultBaseUrl = String.fromEnvironment(
    'PINT_API_BASE_URL',
    defaultValue: _fallbackBaseUrl(),
  );

  static Future<String> getBaseUrl() async {
    // If the app was launched with --dart-define, honor it over stale saved values.
    if (defaultBaseUrl != _fallbackBaseUrl()) {
      return defaultBaseUrl;
    }

    final storedValue = (await localStorage.getString(baseUrlKey))?.trim();
    if (storedValue != null && storedValue.isNotEmpty) {
      return storedValue;
    }

    return defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String value) async {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      await localStorage.remove(baseUrlKey);
      return;
    }

    await localStorage.setString(baseUrlKey, normalizedValue);
  }

  static Future<void> clearBaseUrl() async {
    await localStorage.remove(baseUrlKey);
  }
}
