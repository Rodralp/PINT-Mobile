import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'notifications_api.dart';

class NotificationRecord {
  NotificationRecord({
    this.localId,
    this.serverId,
    required this.accountId,
    required this.logId,
    required this.isRead,
    required this.title,
    required this.summary,
    required this.message,
    required this.type,
    required this.date,
    required this.author,
    required this.updatedAt,
    required this.dirty,
    required this.deleted,
  });

  final int? localId;
  final int? serverId;
  final int accountId;
  final int logId;
  final bool isRead;
  final String title;
  final String summary;
  final String message;
  final String type;
  final String date;
  final String author;
  final int updatedAt;
  final bool dirty;
  final bool deleted;

  factory NotificationRecord.fromMap(Map<String, dynamic> map) {
    return NotificationRecord(
      localId: map['local_id'] as int?,
      serverId: map['server_id'] as int?,
      accountId: map['account_id'] as int,
      logId: map['log_id'] as int? ?? 0,
      isRead: (map['is_read'] as int? ?? 0) == 1,
      title: map['title']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'mensagem',
      date: map['date']?.toString() ?? '',
      author: map['author']?.toString() ?? 'Sistema',
      updatedAt: map['updated_at'] as int? ?? 0,
      dirty: (map['dirty'] as int? ?? 0) == 1,
      deleted: (map['deleted'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'server_id': serverId,
      'account_id': accountId,
      'log_id': logId,
      'is_read': isRead ? 1 : 0,
      'title': title,
      'summary': summary,
      'message': message,
      'type': type,
      'date': date,
      'author': author,
      'updated_at': updatedAt,
      'dirty': dirty ? 1 : 0,
      'deleted': deleted ? 1 : 0,
    };
  }

  BackendNotificationItem toNotificationItem() {
    final resolvedId = serverId ?? -(localId ?? 0);
    return BackendNotificationItem(
      id: resolvedId,
      logId: logId,
      isRead: isRead,
      title: title,
      summary: summary,
      message: message,
      type: type,
      date: date,
      author: author,
    );
  }

  NotificationRecord copyWith({
    int? localId,
    int? serverId,
    int? accountId,
    int? logId,
    bool? isRead,
    String? title,
    String? summary,
    String? message,
    String? type,
    String? date,
    String? author,
    int? updatedAt,
    bool? dirty,
    bool? deleted,
  }) {
    return NotificationRecord(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      accountId: accountId ?? this.accountId,
      logId: logId ?? this.logId,
      isRead: isRead ?? this.isRead,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
      author: author ?? this.author,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
    );
  }
}

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository instance = NotificationRepository._();

  Future<List<BackendNotificationItem>> loadNotifications({
    required int accountId,
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;
    final local = await _fetchLocal(db, accountId);

    if (!forceRefresh) {
      unawaited(_sync(accountId));
      return local;
    }

    await _sync(accountId);
    return _fetchLocal(db, accountId);
  }

  Future<void> markAsRead({
    required int accountId,
    required int notificationId,
  }) async {
    final db = await LocalDatabase.instance.database;
    final isLocal = notificationId < 0;
    final rows = await db.query(
      'notifications',
      where: isLocal
          ? 'account_id = ? AND local_id = ?'
          : 'account_id = ? AND server_id = ?',
      whereArgs: isLocal
          ? [accountId, -notificationId]
          : [accountId, notificationId],
      limit: 1,
    );

    if (rows.isEmpty) return;

    final record = NotificationRecord.fromMap(rows.first);
    final updated = record.copyWith(
      isRead: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      dirty: true,
    );

    await db.update(
      'notifications',
      updated.toMap(),
      where: 'local_id = ?',
      whereArgs: [record.localId],
    );

    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      await NotificationsApi.instance.markAsRead(notificationId);
      final cleared = updated.copyWith(
        dirty: false,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await db.update(
        'notifications',
        cleared.toMap(),
        where: 'local_id = ?',
        whereArgs: [record.localId],
      );
    } catch (e) {
      debugPrint('[NotificationRepo] markAsRead sync failed: $e');
    }
  }

  Future<List<BackendNotificationItem>> _fetchLocal(
    Database db,
    int accountId,
  ) async {
    final rows = await db.query(
      'notifications',
      where: 'account_id = ? AND deleted = 0',
      whereArgs: [accountId],
      orderBy: 'updated_at DESC',
    );

    return rows
        .map(NotificationRecord.fromMap)
        .map((record) => record.toNotificationItem())
        .toList(growable: false);
  }

  Future<void> _sync(int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final remote = await NotificationsApi.instance.fetchNotifications();
      debugPrint('[NotificationRepo] Fetched ${remote.length} notifications from server');
      await _mergeRemote(accountId, remote);
    } on NotificationsApiException catch (e) {
      debugPrint('[NotificationRepo] fetchNotifications failed: $e');
    } catch (e, stack) {
      debugPrint('[NotificationRepo] sync error: $e');
      debugPrint('[NotificationRepo] stack: $stack');
    }
  }

  Future<void> _mergeRemote(
    int accountId,
    List<BackendNotificationItem> remote,
  ) async {
    final db = await LocalDatabase.instance.database;
    final remoteIds = <int>{};

    for (final item in remote) {
      remoteIds.add(item.id);

      final rows = await db.query(
        'notifications',
        where: 'account_id = ? AND server_id = ?',
        whereArgs: [accountId, item.id],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        final existing = NotificationRecord.fromMap(rows.first);
        if (existing.dirty) continue;

        final updated = existing.copyWith(
          logId: item.logId,
          isRead: item.isRead,
          title: item.title,
          summary: item.summary,
          message: item.message,
          type: item.type,
          date: item.date,
          author: item.author,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          dirty: false,
          deleted: false,
        );

        await db.update(
          'notifications',
          updated.toMap(),
          where: 'local_id = ?',
          whereArgs: [existing.localId],
        );
        continue;
      }

      final newRecord = NotificationRecord(
        accountId: accountId,
        serverId: item.id,
        logId: item.logId,
        isRead: item.isRead,
        title: item.title,
        summary: item.summary,
        message: item.message,
        type: item.type,
        date: item.date,
        author: item.author,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        dirty: false,
        deleted: false,
      );

      await db.insert('notifications', newRecord.toMap());
    }

    final localRows = await db.query(
      'notifications',
      where: 'account_id = ? AND deleted = 0',
      whereArgs: [accountId],
    );

    for (final row in localRows) {
      final record = NotificationRecord.fromMap(row);
      if (record.dirty) continue;
      if (record.serverId != null && !remoteIds.contains(record.serverId)) {
        await db.delete(
          'notifications',
          where: 'local_id = ?',
          whereArgs: [record.localId],
        );
      }
    }
  }
}
