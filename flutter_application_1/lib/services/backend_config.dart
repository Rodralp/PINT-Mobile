class BackendConfig {
  BackendConfig._();

  static const String _hardcodedBaseUrl = 'https://pint-backend-vwqc.onrender.com/api';

  static String get defaultBaseUrl => _hardcodedBaseUrl;

  static Future<String> getBaseUrl() async => _hardcodedBaseUrl;
}
