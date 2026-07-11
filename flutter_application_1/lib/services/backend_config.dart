class BackendConfig {
  BackendConfig._();

  static const String _definedBaseUrl = String.fromEnvironment(
    'PINT_API_BASE_URL',
    defaultValue: '',
  );
  static const String _hardcodedBaseUrl = 'https://pint-backend-vwqc.onrender.com/api';

  static String get defaultBaseUrl {
    final defined = _normalizeBaseUrl(_definedBaseUrl);
    if (defined != null) {
      return defined;
    }
    return _hardcodedBaseUrl;
  }

  static Future<String> getBaseUrl() async => defaultBaseUrl;

  static String? _normalizeBaseUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return null;
    }

    final withoutTrailingSlash = value.endsWith('/')
        ? value.substring(0, value.length - 1)
        : value;

    if (withoutTrailingSlash.toLowerCase().endsWith('/api')) {
      return withoutTrailingSlash;
    }

    return '$withoutTrailingSlash/api';
  }
}
