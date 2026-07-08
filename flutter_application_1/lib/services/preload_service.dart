import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'auth_session.dart';
import 'connectivity_service.dart';
import 'local_database.dart';
import 'dashboard_repository.dart';
import 'notification_repository.dart';
import 'message_repository.dart';
import 'request_repository.dart';
import 'learning_path_repository.dart';
import 'ranking_repository.dart';
import 'badges_api.dart';

class PreloadService {
  PreloadService._();

  static final PreloadService instance = PreloadService._();

  bool _running = false;
  DateTime? _lastPreloadAt;

  DateTime? get lastPreloadAt => _lastPreloadAt;

  Future<void> preloadAll() async {
    if (_running) return;
    _running = true;

    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId == null || accountId <= 0) {
        debugPrint('[PreloadService] No accountId, skipping preload');
        return;
      }

      if (!await ConnectivityService.instance.hasConnection()) {
        debugPrint('[PreloadService] No connection, skipping preload');
        return;
      }

      debugPrint('[PreloadService] Starting preload for account $accountId');

      await Future.wait([
        _syncDashboard(accountId),
        _syncNotifications(accountId),
        _syncMessages(accountId),
        _syncBadges(accountId),
        _syncLearningPaths(accountId),
        _syncRanking(),
        _syncRequests(accountId),
      ], eagerError: true);

      _lastPreloadAt = DateTime.now();
      debugPrint('[PreloadService] Preload completed');
    } catch (e) {
      debugPrint('[PreloadService] Preload error: $e');
    } finally {
      _running = false;
    }
  }

  Future<void> _syncDashboard(int accountId) async {
    try {
      await DashboardRepository.instance.loadDashboard(
        accountId: accountId,
        forceRefresh: true,
      );
      debugPrint('[PreloadService] Dashboard synced');
    } catch (e) {
      debugPrint('[PreloadService] Dashboard sync error: $e');
    }
  }

  Future<void> _syncNotifications(int accountId) async {
    try {
      await NotificationRepository.instance.loadNotifications(
        accountId: accountId,
        forceRefresh: true,
      );
      debugPrint('[PreloadService] Notifications synced');
    } catch (e) {
      debugPrint('[PreloadService] Notifications sync error: $e');
    }
  }

  Future<void> _syncMessages(int accountId) async {
    try {
      await MessageRepository.instance.loadMessages(
        accountId: accountId,
        forceRefresh: true,
      );
      debugPrint('[PreloadService] Messages synced');
    } catch (e) {
      debugPrint('[PreloadService] Messages sync error: $e');
    }
  }

  Future<void> _syncBadges(int accountId) async {
    try {
      final catalogFuture = BadgesApi.instance.fetchCatalog();
      final myBadgesFuture = BadgesApi.instance.fetchMyBadges(accountId: accountId);
      final results = await Future.wait([catalogFuture, myBadgesFuture]);
      final catalog = results[0];
      final myBadges = results[1];

      final seenIds = <int>{};
      final allBadges = <dynamic>[...myBadges, ...catalog];

      final db = await LocalDatabase.instance.database;

      for (final badge in allBadges) {
        if (badge.id <= 0 || seenIds.contains(badge.id)) continue;
        seenIds.add(badge.id);
        try {
          final requirements = await BadgesApi.instance.fetchBadgeRequirements(
            badgeId: badge.id,
          );
          final rawList = requirements.map((r) => {'text': r.text}).toList();

          await db.insert(
            'badge_requirements_cache',
            {
              'badge_id': badge.id,
              'account_id': accountId,
              'requirements_json': jsonEncode(rawList),
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          debugPrint('[PreloadService] Badge ${badge.id} requirements cached (${requirements.length})');
        } catch (e) {
          debugPrint('[PreloadService] Badge ${badge.id} requirements sync error: $e');
        }
      }

      debugPrint('[PreloadService] Badges synced (${seenIds.length} badges)');
    } catch (e) {
      debugPrint('[PreloadService] Badges sync error: $e');
    }
  }

  Future<void> _syncLearningPaths(int accountId) async {
    try {
      await LearningPathRepository.instance.loadLearningPaths(
        accountId: accountId,
        forceRefresh: true,
      );
      debugPrint('[PreloadService] Learning paths synced');
    } catch (e) {
      debugPrint('[PreloadService] Learning paths sync error: $e');
    }
  }

  Future<void> _syncRanking() async {
    try {
      await RankingRepository.instance.loadRanking(forceRefresh: true);
      debugPrint('[PreloadService] Ranking synced');
    } catch (e) {
      debugPrint('[PreloadService] Ranking sync error: $e');
    }
  }

  Future<void> _syncRequests(int accountId) async {
    try {
      await RequestRepository.instance.loadRequests(
        accountId: accountId,
        forceRefresh: true,
      );
      debugPrint('[PreloadService] Requests synced');
    } catch (e) {
      debugPrint('[PreloadService] Requests sync error: $e');
    }
  }
}
