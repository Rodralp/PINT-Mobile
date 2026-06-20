import 'package:flutter/foundation.dart';

import 'local_storage.dart';

class BackendConfig {
  BackendConfig._();

  static const String baseUrlKey = 'backend_base_url';
  static const String _definedBaseUrl = String.fromEnvironment(
    'PINT_API_BASE_URL',
    defaultValue: '',
  );

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

  static String get defaultBaseUrl {
    final definedBaseUrl = _definedBaseUrl.trim();
    return definedBaseUrl.isNotEmpty ? definedBaseUrl : _fallbackBaseUrl();
  }

  static Future<String> getBaseUrl() async {
    final definedBaseUrl = _definedBaseUrl.trim();

    // If the app was launched with --dart-define, always honor it over saved values.
    if (definedBaseUrl.isNotEmpty) {
      return definedBaseUrl;
    }

    final storedValue = (await localStorage.getString(baseUrlKey))?.trim();
    if (storedValue != null && storedValue.isNotEmpty) {
      return storedValue;
    }

    return _fallbackBaseUrl();
  }

  static Future<List<String>> candidateBaseUrls() async {
    final candidates = <String>[];
    final seen = <String>{};

    void addCandidate(String? value) {
      final normalized = value?.trim();
      if (normalized == null || normalized.isEmpty || seen.contains(normalized)) {
        return;
      }

      seen.add(normalized);
      candidates.add(normalized);
    }

    addCandidate(_definedBaseUrl);

    final storedValue = (await localStorage.getString(baseUrlKey))?.trim();
    addCandidate(storedValue);

    addCandidate(_fallbackBaseUrl());

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      addCandidate('http://127.0.0.1:4000/api');
    }

    return candidates;
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

  static String? normalizeBaseUrlInput(String raw, {int defaultPort = 4000}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    var candidate = trimmed;
    if (!candidate.contains('://')) {
      candidate = 'http://$candidate';
    }

    final uri = Uri.tryParse(candidate);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }

    final port = uri.hasPort ? uri.port : defaultPort;
    var path = uri.path;
    if (path.isEmpty || path == '/') {
      path = '/api';
    } else if (!path.contains('/api')) {
      path = path.endsWith('/') ? '${path}api' : '$path/api';
    }

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: port,
      path: path,
    ).toString();
  }

  static String formatServerInput(String baseUrl, {int defaultPort = 4000}) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      return baseUrl;
    }
    final portSuffix = uri.hasPort && uri.port != defaultPort
        ? ':${uri.port}'
        : '';
    return '${uri.host}$portSuffix';
  }
}
