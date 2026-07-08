import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'consultor_api.dart';

class LearningPathRepository {
  LearningPathRepository._();

  static final LearningPathRepository instance = LearningPathRepository._();

  Future<List<BackendLearningPath>> loadLearningPaths({
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

  Future<List<BackendLearningPath>?> _readCached(Database db, int accountId) async {
    final rows = await db.query(
      'learning_paths_cache',
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final json = rows.first['paths_json']?.toString() ?? '[]';
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BackendLearningPath.fromJson)
        .toList(growable: false);
  }

  Future<void> _sync(int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final paths = await ConsultorApi.instance.fetchLearningPaths(
        accountId: accountId,
      );

      final db = await LocalDatabase.instance.database;
      final rawList = paths
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'description': p.description,
                'serviceLines': p.serviceLines
                    .map((sl) => {
                          'id': sl.id,
                          'name': sl.name,
                          'description': sl.description,
                          'image': sl.image,
                          'areas': sl.areas
                              .map((a) => {
                                    'id': a.id,
                                    'name': a.name,
                                    'description': a.description,
                                    'levels': a.levels
                                        .map((l) => {
                                              'id': l.id,
                                              'title': l.title,
                                              'subtitle': l.subtitle,
                                              'levelKey': l.levelKey,
                                              'points': l.points,
                                              'badgeImage': l.badgeImage,
                                              'badgeDbId': l.badgeDbId,
                                              'requestId': l.requestId,
                                              'status': l.status,
                                              'isSpecial': l.isSpecial,
                                              'requirements': l.requirements
                                                  .map((r) => {
                                                        'title': r.title,
                                                        'description': r.description,
                                                      })
                                                  .toList(),
                                            })
                                        .toList(),
                                  })
                              .toList(),
                        })
                    .toList(),
              })
          .toList();

      await db.insert(
        'learning_paths_cache',
        {
          'account_id': accountId,
          'paths_json': jsonEncode(rawList),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('[LearningPathRepo] Cached ${paths.length} paths for account $accountId');
    } catch (e) {
      debugPrint('[LearningPathRepo] sync error: $e');
    }
  }
}
