import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'badges_api.dart';
import 'consultor_api.dart';

class BadgeCacheRepository {
  BadgeCacheRepository._();

  static final BadgeCacheRepository instance = BadgeCacheRepository._();

  Future<List<BackendBadgeRequirement>> loadBadgeRequirements({
    required int badgeId,
    required int accountId,
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;

    if (!forceRefresh) {
      final cached = await _readCachedRequirements(db, badgeId, accountId);
      if (cached != null && cached.isNotEmpty) return cached;
    }

    await _syncRequirements(badgeId, accountId);
    return (await _readCachedRequirements(db, badgeId, accountId)) ?? [];
  }

  Future<Map<String, dynamic>?> loadPedidoDetail({
    required int pedidoId,
    required int accountId,
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;

    if (!forceRefresh) {
      final cached = await _readCachedPedidoDetail(db, pedidoId, accountId);
      if (cached != null) return cached;
    }

    await _syncPedidoDetail(pedidoId, accountId);
    return await _readCachedPedidoDetail(db, pedidoId, accountId);
  }

  Future<List<BackendBadgeRequirement>?> _readCachedRequirements(
    Database db,
    int badgeId,
    int accountId,
  ) async {
    final rows = await db.query(
      'badge_requirements_cache',
      where: 'badge_id = ? AND account_id = ?',
      whereArgs: [badgeId, accountId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final json = rows.first['requirements_json']?.toString() ?? '[]';
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;

    return decoded
        .map((item) => BackendBadgeRequirement.fromJson(item))
        .where((item) => item.text.isNotEmpty)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> _readCachedPedidoDetail(
    Database db,
    int pedidoId,
    int accountId,
  ) async {
    final rows = await db.query(
      'pedido_detail_cache',
      where: 'pedido_id = ? AND account_id = ?',
      whereArgs: [pedidoId, accountId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final json = rows.first['detail_json']?.toString() ?? '{}';
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) return decoded;

    return null;
  }

  Future<void> _syncRequirements(int badgeId, int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final requirements = await BadgesApi.instance.fetchBadgeRequirements(
        badgeId: badgeId,
      );

      final db = await LocalDatabase.instance.database;
      final rawList = requirements.map((r) => {'text': r.text}).toList();

      await db.insert(
        'badge_requirements_cache',
        {
          'badge_id': badgeId,
          'account_id': accountId,
          'requirements_json': jsonEncode(rawList),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('[BadgeCacheRepo] Cached ${requirements.length} requirements for badge $badgeId');
    } catch (e) {
      debugPrint('[BadgeCacheRepo] syncRequirements error: $e');
    }
  }

  Future<void> _syncPedidoDetail(int pedidoId, int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final detail = await ConsultorApi.instance.fetchPedidoDetail(
        pedidoId: pedidoId,
      );

      if (detail == null) return;

      final db = await LocalDatabase.instance.database;

      await db.insert(
        'pedido_detail_cache',
        {
          'pedido_id': pedidoId,
          'account_id': accountId,
          'detail_json': jsonEncode(detail),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('[BadgeCacheRepo] Cached pedido detail for pedido $pedidoId');
    } catch (e) {
      debugPrint('[BadgeCacheRepo] syncPedidoDetail error: $e');
    }
  }
}
