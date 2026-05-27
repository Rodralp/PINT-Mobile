import 'dart:convert';
import 'dart:html' as html;

import 'local_storage.dart';

LocalStorage createLocalStorage() => _WebLocalStorage();

class _WebLocalStorage implements LocalStorage {
  html.Storage get _storage => html.window.localStorage;

  @override
  Future<String?> getString(String key) async {
    final raw = _storage[key];
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw);
    return decoded is String ? decoded : decoded?.toString();
  }

  @override
  Future<bool?> getBool(String key) async {
    final raw = _storage[key];
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw);
    return decoded is bool ? decoded : null;
  }

  @override
  Future<int?> getInt(String key) async {
    final raw = _storage[key];
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw);
    return decoded is int ? decoded : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = jsonEncode(value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = jsonEncode(value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = jsonEncode(value);
  }

  @override
  Future<bool> containsKey(String key) async => _storage.containsKey(key);

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

