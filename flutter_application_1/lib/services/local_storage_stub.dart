import 'local_storage.dart';

LocalStorage createLocalStorage() => _MemoryLocalStorage();

class _MemoryLocalStorage implements LocalStorage {
  final Map<String, Object?> _store = <String, Object?>{};

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<bool?> getBool(String key) async => _store[key] as bool?;

  @override
  Future<int?> getInt(String key) async => _store[key] as int?;

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

