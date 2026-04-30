import 'package:shared_preferences/shared_preferences.dart';

class BackendConfig {
  BackendConfig._();

  static const String baseUrlKey = 'backend_base_url';
  static const String _fallbackBaseUrl = 'http://10.0.2.2:4000/api';
  static const String defaultBaseUrl = String.fromEnvironment(
    'PINT_API_BASE_URL',
    defaultValue: _fallbackBaseUrl,
  );

  static Future<String> getBaseUrl() async {
    // If the app was launched with --dart-define, honor it over stale saved values.
    if (defaultBaseUrl != _fallbackBaseUrl) {
      return defaultBaseUrl;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(baseUrlKey)?.trim();
    if (storedValue != null && storedValue.isNotEmpty) {
      return storedValue;
    }

    return defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      await prefs.remove(baseUrlKey);
      return;
    }

    await prefs.setString(baseUrlKey, normalizedValue);
  }

  static Future<void> clearBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(baseUrlKey);
  }
}
