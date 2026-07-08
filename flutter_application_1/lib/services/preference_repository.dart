import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'auth_api.dart';

class PreferenceRepository {
  PreferenceRepository._();

  static final PreferenceRepository instance = PreferenceRepository._();

  Future<List<BackendArea>> loadPreferenceAreas({
    required int accountId,
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;

    if (!forceRefresh) {
      final cached = await _readCached(db, accountId);
      if (cached != null) return cached;

      unawaited(_sync(accountId));
      return [];
    }

    await _sync(accountId);
    return (await _readCached(db, accountId)) ?? [];
  }

  Future<List<BackendArea>?> _readCached(Database db, int accountId) async {
    final rows = await db.query(
      'preference_areas_cache',
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final json = rows.first['areas_json']?.toString() ?? '[]';
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BackendArea.fromJson)
        .toList(growable: false);
  }

  Future<void> _sync(int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final areas = await AuthApi.instance.fetchPreferenceAreas(
        accountId: accountId,
      );

      final db = await LocalDatabase.instance.database;
      final rawList = areas
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'description': a.description,
                'serviceLine': a.serviceLine,
                'badgeCount': a.badgeCount,
                'selected': a.selected,
              })
          .toList();

      await db.insert(
        'preference_areas_cache',
        {
          'account_id': accountId,
          'areas_json': jsonEncode(rawList),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('[PreferenceRepo] Cached ${areas.length} areas for account $accountId');
    } catch (e) {
      debugPrint('[PreferenceRepo] sync error: $e');
    }
  }
}
