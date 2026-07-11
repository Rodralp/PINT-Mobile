import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'local_storage.dart';

const String _kLanguageKey = 'app_language';

class LocaleService {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

  Future<Locale?> init() async {
    final code = await localStorage.getString(_kLanguageKey);
    if (code != null && code.isNotEmpty) {
      final locale = Locale(code);
      localeNotifier.value = locale;
      return locale;
    }
    return null;
  }

  Future<void> setLanguage(String code) async {
    await localStorage.setString(_kLanguageKey, code);
    localeNotifier.value = Locale(code);
  }

  Future<String?> getLanguageCode() async {
    return localStorage.getString(_kLanguageKey);
  }
}
