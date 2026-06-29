import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'reminder_api.dart';

class ReminderRecord {
  ReminderRecord({
    this.localId,
    this.serverId,
    required this.accountId,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    required this.updatedAt,
    required this.dirty,
    required this.deleted,
  });

  final int? localId;
  final int? serverId;
  final int accountId;
  final String title;
  final String description;
  final String date;
  final String color;
  final int updatedAt;
  final bool dirty;
  final bool deleted;

  factory ReminderRecord.fromMap(Map<String, dynamic> map) {
    return ReminderRecord(
      localId: map['local_id'] as int?,
      serverId: map['server_id'] as int?,
      accountId: map['account_id'] as int,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      color: map['color']?.toString() ?? 'green',
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
      'title': title,
      'description': description,
      'date': date,
      'color': color,
      'updated_at': updatedAt,
      'dirty': dirty ? 1 : 0,
      'deleted': deleted ? 1 : 0,
    };
  }

  Reminder toReminder() {
    final resolvedId = serverId ?? -(localId ?? 0);
    return Reminder(
      id: resolvedId,
      title: title,
      description: description,
      date: date,
      color: color,
    );
  }

  ReminderRecord copyWith({
    int? localId,
    int? serverId,
    int? accountId,
    String? title,
    String? description,
    String? date,
    String? color,
    int? updatedAt,
    bool? dirty,
    bool? deleted,
  }) {
    return ReminderRecord(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      color: color ?? this.color,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
    );
  }
}

class ReminderRepository {
  ReminderRepository._();

  static final ReminderRepository instance = ReminderRepository._();

  Future<List<Reminder>> loadReminders({
    required int accountId,
    bool forceRefresh = false,
  }) async {
    final db = await LocalDatabase.instance.database;
    final local = await _fetchLocalReminders(db, accountId);

    if (!forceRefresh) {
      unawaited(_syncReminders(accountId));
      return local;
    }

    await _syncReminders(accountId);
    return _fetchLocalReminders(db, accountId);
  }

  Future<Reminder> createReminder({
    required int accountId,
    required String title,
    required String description,
    required String date,
    required String color,
  }) async {
    final db = await LocalDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final localRecord = ReminderRecord(
      accountId: accountId,
      title: title,
      description: description,
      date: date,
      color: color,
      updatedAt: now,
      dirty: true,
      deleted: false,
    );

    final localId = await db.insert('reminders', localRecord.toMap());
    final inserted = localRecord.copyWith(localId: localId);

    await _attemptSyncForRecord(accountId, inserted);

    return inserted.toReminder();
  }

  Future<Reminder> updateReminder({
    required int accountId,
    required Reminder reminder,
    required String title,
    required String description,
    required String date,
    required String color,
  }) async {
    final db = await LocalDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await _findRecord(db, accountId, reminder.id);

    if (existing == null) {
      return createReminder(
        accountId: accountId,
        title: title,
        description: description,
        date: date,
        color: color,
      );
    }

    final updated = existing.copyWith(
      title: title,
      description: description,
      date: date,
      color: color,
      updatedAt: now,
      dirty: true,
      deleted: false,
    );

    await db.update(
      'reminders',
      updated.toMap(),
      where: 'local_id = ?',
      whereArgs: [updated.localId],
    );

    await _attemptSyncForRecord(accountId, updated);

    return updated.toReminder();
  }

  Future<void> deleteReminder({
    required int accountId,
    required Reminder reminder,
  }) async {
    final db = await LocalDatabase.instance.database;
    final existing = await _findRecord(db, accountId, reminder.id);
    if (existing == null) {
      return;
    }

    if (existing.serverId == null) {
      await db.delete(
        'reminders',
        where: 'local_id = ?',
        whereArgs: [existing.localId],
      );
      return;
    }

    final updated = existing.copyWith(
      deleted: true,
      dirty: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await db.update(
      'reminders',
      updated.toMap(),
      where: 'local_id = ?',
      whereArgs: [updated.localId],
    );

    await _attemptSyncForRecord(accountId, updated);
  }

  Future<List<Reminder>> _fetchLocalReminders(
    Database db,
    int accountId,
  ) async {
    final rows = await db.query(
      'reminders',
      where: 'account_id = ? AND deleted = 0',
      whereArgs: [accountId],
      orderBy: 'updated_at DESC',
    );

    return rows
        .map(ReminderRecord.fromMap)
        .map((record) => record.toReminder())
        .toList(growable: false);
  }

  Future<ReminderRecord?> _findRecord(
    Database db,
    int accountId,
    int reminderId,
  ) async {
    final isLocal = reminderId < 0;
    final rows = await db.query(
      'reminders',
      where: isLocal
          ? 'account_id = ? AND local_id = ?'
          : 'account_id = ? AND server_id = ?',
      whereArgs: isLocal
          ? [accountId, -reminderId]
          : [accountId, reminderId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ReminderRecord.fromMap(rows.first);
  }

  Future<void> _attemptSyncForRecord(
    int accountId,
    ReminderRecord record,
  ) async {
    if (!await ConnectivityService.instance.hasConnection()) {
      return;
    }

    await _syncReminders(accountId, onlyLocalId: record.localId);
  }

  Future<void> _syncReminders(
    int accountId, {
    int? onlyLocalId,
  }) async {
    if (!await ConnectivityService.instance.hasConnection()) {
      return;
    }

    final db = await LocalDatabase.instance.database;
    await _pushDirtyChanges(db, accountId, onlyLocalId: onlyLocalId);

    try {
      final remote = await ReminderApi.instance.fetchReminders(
        accountId: accountId,
      );
      debugPrint('[ReminderRepo] Fetched ${remote.length} reminders from server');
      await _mergeRemote(db, accountId, remote);
    } on ReminderApiException catch (e) {
      debugPrint('[ReminderRepo] fetchReminders failed: $e');
      // Keep local cache when the server is unavailable.
    } catch (e, stack) {
      debugPrint('[ReminderRepo] sync error: $e');
      debugPrint('[ReminderRepo] stack: $stack');
    }
  }

  Future<void> _pushDirtyChanges(
    Database db,
    int accountId, {
    int? onlyLocalId,
  }) async {
    final rows = await db.query(
      'reminders',
      where: onlyLocalId != null
          ? 'account_id = ? AND local_id = ? AND dirty = 1'
          : 'account_id = ? AND dirty = 1',
      whereArgs: onlyLocalId != null
          ? [accountId, onlyLocalId]
          : [accountId],
      orderBy: 'updated_at ASC',
    );

    for (final row in rows) {
      final record = ReminderRecord.fromMap(row);
      try {
        if (record.deleted) {
          if (record.serverId != null) {
            await ReminderApi.instance.deleteReminder(
              accountId: accountId,
              reminderId: record.serverId!,
            );
          }
          await db.delete(
            'reminders',
            where: 'local_id = ?',
            whereArgs: [record.localId],
          );
          continue;
        }

        if (record.serverId == null) {
          final created = await ReminderApi.instance.createReminder(
            accountId: accountId,
            title: record.title,
            description: record.description,
            date: record.date,
            color: record.color,
          );
          await db.update(
            'reminders',
            record
                .copyWith(
                  serverId: created.id,
                  dirty: false,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                )
                .toMap(),
            where: 'local_id = ?',
            whereArgs: [record.localId],
          );
          continue;
        }

        await ReminderApi.instance.updateReminder(
          accountId: accountId,
          reminderId: record.serverId!,
          title: record.title,
          description: record.description,
          date: record.date,
          color: record.color,
        );

        await db.update(
          'reminders',
          record.copyWith(dirty: false).toMap(),
          where: 'local_id = ?',
          whereArgs: [record.localId],
        );
      } on ReminderApiException {
        // Keep dirty state for later sync attempts.
      }
    }
  }

  Future<void> _mergeRemote(
    Database db,
    int accountId,
    List<Reminder> remote,
  ) async {
    final remoteIds = <int>{};
    for (final reminder in remote) {
      remoteIds.add(reminder.id);

      final rows = await db.query(
        'reminders',
        where: 'account_id = ? AND server_id = ?',
        whereArgs: [accountId, reminder.id],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        final existing = ReminderRecord.fromMap(rows.first);
        if (existing.dirty) {
          continue;
        }

        final updated = existing.copyWith(
          title: reminder.title,
          description: reminder.description,
          date: reminder.date,
          color: reminder.color,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          dirty: false,
          deleted: false,
        );

        await db.update(
          'reminders',
          updated.toMap(),
          where: 'local_id = ?',
          whereArgs: [existing.localId],
        );
        continue;
      }

      final newRecord = ReminderRecord(
        accountId: accountId,
        serverId: reminder.id,
        title: reminder.title,
        description: reminder.description,
        date: reminder.date,
        color: reminder.color,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        dirty: false,
        deleted: false,
      );

      await db.insert('reminders', newRecord.toMap());
    }

    final localRows = await db.query(
      'reminders',
      where: 'account_id = ? AND deleted = 0',
      whereArgs: [accountId],
    );

    for (final row in localRows) {
      final record = ReminderRecord.fromMap(row);
      if (record.dirty) continue;
      if (record.serverId != null && !remoteIds.contains(record.serverId)) {
        await db.delete(
          'reminders',
          where: 'local_id = ?',
          whereArgs: [record.localId],
        );
      }
    }
  }
}

