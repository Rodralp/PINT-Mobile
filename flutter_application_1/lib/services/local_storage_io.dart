import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_storage.dart';

LocalStorage createLocalStorage() => _FileLocalStorage();

class _FileLocalStorage implements LocalStorage {
  static const String _fileName = 'local_storage.json';
  Map<String, Object?> _cache = <String, Object?>{};
  bool _loaded = false;

  Future<File> _resolveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  Future<void> _load() async {
    if (_loaded) {
      return;
    }

    final file = await _resolveFile();
    if (!await file.exists()) {
      _cache = <String, Object?>{};
      _loaded = true;
      return;
    }

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      _cache = <String, Object?>{};
      _loaded = true;
      return;
    }

    final decoded = jsonDecode(contents);
    if (decoded is Map<String, dynamic>) {
      _cache = Map<String, Object?>.from(decoded);
    } else {
      _cache = <String, Object?>{};
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final file = await _resolveFile();
    await file.writeAsString(jsonEncode(_cache));
  }

  @override
  Future<String?> getString(String key) async {
    await _load();
    final value = _cache[key];
    return value is String ? value : value?.toString();
  }

  @override
  Future<bool?> getBool(String key) async {
    await _load();
    final value = _cache[key];
    return value is bool ? value : null;
  }

  @override
  Future<int?> getInt(String key) async {
    await _load();
    final value = _cache[key];
    return value is int ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _load();
    _cache[key] = value;
    await _persist();
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _load();
    _cache[key] = value;
    await _persist();
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _load();
    _cache[key] = value;
    await _persist();
  }

  @override
  Future<bool> containsKey(String key) async {
    await _load();
    return _cache.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _load();
    _cache.remove(key);
    await _persist();
  }

  @override
  Future<void> clear() async {
    await _load();
    _cache.clear();
    await _persist();
  }
}

