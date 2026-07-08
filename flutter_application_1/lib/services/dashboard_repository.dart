import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'consultor_api.dart';

class DashboardRepository {
  DashboardRepository._();

  static final DashboardRepository instance = DashboardRepository._();

  Future<BackendConsultorDashboard> loadDashboard({
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
    return (await _readCached(db, accountId)) ?? const BackendConsultorDashboard(
      timelineValues: [],
      stats: [],
      inProgressItems: [],
      suggestionItems: [],
    );
  }

  Future<BackendConsultorDashboard?> _readCached(Database db, int accountId) async {
    final rows = await db.query(
      'dashboard_cache',
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final statsJson = row['stats_json']?.toString() ?? '[]';
    final inProgressJson = row['in_progress_json']?.toString() ?? '[]';
    final suggestionsJson = row['suggestions_json']?.toString() ?? '[]';
    final timelineJson = row['timeline_json']?.toString() ?? '[]';

    final stats = (jsonDecode(statsJson) as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendDashboardStat.fromJson)
        .toList(growable: false);

    final inProgressItems = (jsonDecode(inProgressJson) as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendProgressItem.fromJson)
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);

    final suggestionItems = (jsonDecode(suggestionsJson) as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendSuggestionItem.fromJson)
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);

    final timelineValues = (jsonDecode(timelineJson) as List<dynamic>? ?? const [])
        .map((value) => int.tryParse(value.toString()) ?? 0)
        .toList(growable: false);

    return BackendConsultorDashboard(
      timelineValues: timelineValues,
      stats: stats,
      inProgressItems: inProgressItems,
      suggestionItems: suggestionItems,
    );
  }

  Future<void> _sync(int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final dashboard = await ConsultorApi.instance.fetchConsultorDashboard(
        accountId: accountId,
      );

      final db = await LocalDatabase.instance.database;

      final statsList = dashboard.stats
          .map((s) => {
                'titleKey': s.titleKey,
                'value': s.value,
                'noteKey': s.noteKey,
                'iconKey': s.iconKey,
                'tone': s.tone,
              })
          .toList();

      final inProgressList = dashboard.inProgressItems
          .map((item) => {
                'title': item.title,
                'subtitle': item.subtitle,
                'accent': item.accent,
                'iconKey': item.iconKey,
                'badgeImage': item.badgeImage,
                'levelKey': item.levelKey,
                'typeId': item.typeId,
                'isSpecial': item.isSpecial,
              })
          .toList();

      final suggestionsList = dashboard.suggestionItems
          .map((item) => {
                'title': item.title,
                'subtitleKey': item.subtitleKey,
                'accent': item.accent,
                'badgeDbId': item.badgeDbId,
                'badgeImage': item.badgeImage,
                'levelKey': item.levelKey,
                'typeId': item.typeId,
                'isSpecial': item.isSpecial,
              })
          .toList();

      final timelineList = dashboard.timelineValues;

      await db.insert(
        'dashboard_cache',
        {
          'account_id': accountId,
          'stats_json': jsonEncode(statsList),
          'in_progress_json': jsonEncode(inProgressList),
          'suggestions_json': jsonEncode(suggestionsList),
          'timeline_json': jsonEncode(timelineList),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('[DashboardRepo] Cached dashboard for account $accountId');
    } catch (e) {
      debugPrint('[DashboardRepo] sync error: $e');
    }
  }
}
