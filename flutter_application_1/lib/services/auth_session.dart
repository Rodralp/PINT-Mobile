import 'local_storage.dart';

import 'auth_api.dart';

class AuthSession {
  AuthSession._();

  static const String _accountIdKey = 'current_account_id';
  static const String _accountNameKey = 'current_account_name';
  static const String _accountEmailKey = 'current_account_email';
  static const String _accountRoleKey = 'current_account_role';
  static const String _accountPermissionsKey = 'current_account_permissions';
  static const String _accountHasPreferencesKey = 'current_account_has_preferences';
  static const String _rememberLoginKey = 'remember_login';
  static const String _skipAutoLoginOnceKey = 'skip_auto_login_once';

  static Future<void> saveAccount(AuthAccount account) async {
    await localStorage.setInt(_accountIdKey, account.id);
    await localStorage.setString(_accountNameKey, account.name);
    await localStorage.setString(_accountEmailKey, account.email);
    await localStorage.setString(_accountRoleKey, account.role);
    final permissions = account.roles.isNotEmpty ? account.roles.join(';') : account.role;
    await localStorage.setString(_accountPermissionsKey, permissions);
    await localStorage.setBool(_accountHasPreferencesKey, account.hasPreferences);
  }

  static Future<void> setRememberLogin(bool value) async {
    await localStorage.setBool(_rememberLoginKey, value);
  }

  static Future<bool> shouldRememberLogin() async {
    return await localStorage.getBool(_rememberLoginKey) ?? false;
  }

  static Future<void> setSkipAutoLoginOnce(bool value) async {
    await localStorage.setBool(_skipAutoLoginOnceKey, value);
  }

  static Future<bool> shouldSkipAutoLoginOnce() async {
    return await localStorage.getBool(_skipAutoLoginOnceKey) ?? false;
  }

  static Future<int?> getAccountId() async {
    return localStorage.getInt(_accountIdKey);
  }

  static Future<String?> getAccountName() async {
    return localStorage.getString(_accountNameKey);
  }

  static Future<String?> getAccountEmail() async {
    return localStorage.getString(_accountEmailKey);
  }

  static Future<String?> getAccountRole() async {
    return localStorage.getString(_accountRoleKey);
  }

  static Future<String?> getAccountPermissions() async {
    return localStorage.getString(_accountPermissionsKey);
  }

  static Future<bool> hasPreferences() async {
    return await localStorage.getBool(_accountHasPreferencesKey) ?? false;
  }

  static Future<void> setHasPreferences(bool value) async {
    await localStorage.setBool(_accountHasPreferencesKey, value);
  }

  static Future<void> clearSession() async {
    await localStorage.remove(_accountIdKey);
    await localStorage.remove(_accountNameKey);
    await localStorage.remove(_accountEmailKey);
    await localStorage.remove(_accountRoleKey);
    await localStorage.remove(_accountPermissionsKey);
    await localStorage.remove(_accountHasPreferencesKey);
  }
}