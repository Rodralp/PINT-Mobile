import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'consultor_api.dart';

class RequestRepository {
  RequestRepository._();

  static final RequestRepository instance = RequestRepository._();

  Future<List<BackendRequest>> loadRequests({
    required int accountId,
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;

    if (!forceRefresh) {
      final cached = await _readCached(db, accountId);
      if (cached != null) {
        unawaited(_sync(accountId));
        return cached;
      }
    }

    await _sync(accountId);
    return (await _readCached(db, accountId)) ?? [];
  }

  Future<List<BackendRequest>?> _readCached(Database db, int accountId) async {
    final rows = await db.query(
      'requests_cache',
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final json = rows.first['requests_json']?.toString() ?? '[]';
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BackendRequest.fromJson)
        .toList(growable: false);
  }

  Future<void> _sync(int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final requests = await ConsultorApi.instance.fetchMyRequests(
        accountId: accountId,
      );

      final db = await LocalDatabase.instance.database;
      final rawList = requests
          .map((r) => {
                'id': r.id,
                'badge': r.badge,
                'level': r.level,
                'date': r.date,
                'status': r.status,
                'badgeDbId': r.badgeDbId,
                'reviewerNote': r.reviewerNote,
                'reviewerName': r.reviewerName,
                'requirements': r.requirements,
              })
          .toList();

      await db.insert(
        'requests_cache',
        {
          'account_id': accountId,
          'requests_json': jsonEncode(rawList),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('[RequestRepo] Cached ${requests.length} requests for account $accountId');
    } catch (e) {
      debugPrint('[RequestRepo] sync error: $e');
    }
  }
}
