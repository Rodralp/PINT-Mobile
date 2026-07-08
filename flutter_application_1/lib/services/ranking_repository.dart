import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'consultor_api.dart';

class RankingRepository {
  RankingRepository._();

  static final RankingRepository instance = RankingRepository._();

  Future<List<BackendRankingConsultant>> loadRanking({
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;

    if (!forceRefresh) {
      final cached = await _readCached(db);
      if (cached != null) {
        unawaited(_sync());
        return cached;
      }
    }

    await _sync();
    return (await _readCached(db)) ?? [];
  }

  Future<List<BackendRankingConsultant>?> _readCached(Database db) async {
    final rows = await db.query(
      'ranking_cache',
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final json = rows.first['data_json']?.toString() ?? '[]';
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BackendRankingConsultant.fromJson)
        .toList(growable: false);
  }

  Future<void> _sync() async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final ranking = await ConsultorApi.instance.fetchRankingConsultores();

      final db = await LocalDatabase.instance.database;
      final rawList = ranking
          .map((r) => {
                'id': r.id,
                'name': r.name,
                'email': r.email,
                'points': r.points,
                'badges': r.badges,
                'serviceLine': r.serviceLine,
                'avatar': r.avatar,
              })
          .toList();

      await db.insert(
        'ranking_cache',
        {
          'data_json': jsonEncode(rawList),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      debugPrint('[RankingRepo] Cached ${ranking.length} consultants');
    } catch (e) {
      debugPrint('[RankingRepo] sync error: $e');
    }
  }
}
