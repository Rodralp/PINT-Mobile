import 'local_storage_stub.dart'
    if (dart.library.html) 'local_storage_web.dart'
    if (dart.library.io) 'local_storage_io.dart';

abstract class LocalStorage {
  Future<String?> getString(String key);
  Future<bool?> getBool(String key);
  Future<int?> getInt(String key);
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<bool> containsKey(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

final LocalStorage localStorage = createLocalStorage();

