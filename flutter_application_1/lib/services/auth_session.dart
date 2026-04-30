import 'package:shared_preferences/shared_preferences.dart';

import 'auth_api.dart';

class AuthSession {
  AuthSession._();

  static const String _accountIdKey = 'current_account_id';
  static const String _accountNameKey = 'current_account_name';
  static const String _accountEmailKey = 'current_account_email';
  static const String _accountRoleKey = 'current_account_role';
  static const String _accountHasPreferencesKey = 'current_account_has_preferences';

  static Future<void> saveAccount(AuthAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accountIdKey, account.id);
    await prefs.setString(_accountNameKey, account.name);
    await prefs.setString(_accountEmailKey, account.email);
    await prefs.setString(_accountRoleKey, account.role);
    await prefs.setBool(_accountHasPreferencesKey, account.hasPreferences);
  }

  static Future<int?> getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accountIdKey);
  }

  static Future<bool> hasPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_accountHasPreferencesKey) ?? false;
  }

  static Future<void> setHasPreferences(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountHasPreferencesKey, value);
  }
}