import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'connectivity_service.dart';
import 'local_database.dart';
import 'messages_api.dart';

class MessageRecord {
  MessageRecord({
    this.localId,
    this.serverId,
    required this.accountId,
    required this.type,
    required this.priority,
    required this.title,
    required this.summary,
    required this.author,
    required this.authorEmail,
    required this.date,
    required this.message,
    required this.updatedAt,
    required this.dirty,
    required this.deleted,
  });

  final int? localId;
  final int? serverId;
  final int accountId;
  final String type;
  final int priority;
  final String title;
  final String summary;
  final String author;
  final String authorEmail;
  final String date;
  final String message;
  final int updatedAt;
  final bool dirty;
  final bool deleted;

  factory MessageRecord.fromMap(Map<String, dynamic> map) {
    return MessageRecord(
      localId: map['local_id'] as int?,
      serverId: map['server_id'] as int?,
      accountId: map['account_id'] as int,
      type: map['type']?.toString() ?? 'mensagem',
      priority: map['priority'] as int? ?? 3,
      title: map['title']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      author: map['author']?.toString() ?? 'Sistema',
      authorEmail: map['author_email']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
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
      'type': type,
      'priority': priority,
      'title': title,
      'summary': summary,
      'author': author,
      'author_email': authorEmail,
      'date': date,
      'message': message,
      'updated_at': updatedAt,
      'dirty': dirty ? 1 : 0,
      'deleted': deleted ? 1 : 0,
    };
  }

  MessageRecord copyWith({
    int? localId,
    int? serverId,
    int? accountId,
    String? type,
    int? priority,
    String? title,
    String? summary,
    String? author,
    String? authorEmail,
    String? date,
    String? message,
    int? updatedAt,
    bool? dirty,
    bool? deleted,
  }) {
    return MessageRecord(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      author: author ?? this.author,
      authorEmail: authorEmail ?? this.authorEmail,
      date: date ?? this.date,
      message: message ?? this.message,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
    );
  }
}

class MessageRepository {
  MessageRepository._();

  static final MessageRepository instance = MessageRepository._();

  Future<List<BackendAnnouncementItem>> loadMessages({
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

  Future<List<BackendAnnouncementItem>> _fetchLocal(
    Database db,
    int accountId,
  ) async {
    final rows = await db.query(
      'messages',
      where: 'account_id = ? AND deleted = 0',
      whereArgs: [accountId],
      orderBy: 'updated_at DESC',
    );

    final messages = <BackendAnnouncementItem>[];
    for (final row in rows) {
      final record = MessageRecord.fromMap(row);
      final attachmentRows = await db.query(
        'message_attachments',
        where: 'message_local_id = ?',
        whereArgs: [record.localId],
      );

      final attachments = attachmentRows
          .map((a) => BackendAnnouncementAttachment(
                id: a['server_id'] as int? ?? 0,
                logId: a['log_id'] as int? ?? 0,
                originalName: a['original_name']?.toString() ?? '',
                storedName: a['stored_name']?.toString() ?? '',
                mimeType: a['mime_type']?.toString() ?? '',
                size: a['size'] as int? ?? 0,
                path: a['path']?.toString() ?? '',
              ))
          .toList(growable: false);

      final resolvedId = record.serverId ?? -(record.localId ?? 0);
      messages.add(BackendAnnouncementItem(
        id: resolvedId,
        type: record.type,
        priority: record.priority,
        title: record.title,
        summary: record.summary,
        author: record.author,
        authorEmail: record.authorEmail,
        date: record.date,
        message: record.message,
        attachments: attachments,
      ));
    }

    return messages;
  }

  Future<void> _sync(int accountId) async {
    if (!await ConnectivityService.instance.hasConnection()) return;

    try {
      final remote = await MessagesApi.instance.fetchMessages();
      debugPrint('[MessageRepo] Fetched ${remote.length} messages from server');
      await _mergeRemote(accountId, remote);
    } on MessagesApiException catch (e) {
      debugPrint('[MessageRepo] fetchMessages failed: $e');
    } catch (e, stack) {
      debugPrint('[MessageRepo] sync error: $e');
      debugPrint('[MessageRepo] stack: $stack');
    }
  }

  Future<void> _mergeRemote(
    int accountId,
    List<BackendAnnouncementItem> remote,
  ) async {
    final db = await LocalDatabase.instance.database;
    final remoteIds = <int>{};

    for (final item in remote) {
      remoteIds.add(item.id);

      final rows = await db.query(
        'messages',
        where: 'account_id = ? AND server_id = ?',
        whereArgs: [accountId, item.id],
        limit: 1,
      );

      int messageLocalId;

      if (rows.isNotEmpty) {
        final existing = MessageRecord.fromMap(rows.first);
        if (existing.dirty) {
          messageLocalId = existing.localId!;
          continue;
        }

        final updated = existing.copyWith(
          type: item.type,
          priority: item.priority,
          title: item.title,
          summary: item.summary,
          author: item.author,
          authorEmail: item.authorEmail,
          date: item.date,
          message: item.message,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          dirty: false,
          deleted: false,
        );

        await db.update(
          'messages',
          updated.toMap(),
          where: 'local_id = ?',
          whereArgs: [existing.localId],
        );
        messageLocalId = existing.localId!;
      } else {
        final newRecord = MessageRecord(
          accountId: accountId,
          serverId: item.id,
          type: item.type,
          priority: item.priority,
          title: item.title,
          summary: item.summary,
          author: item.author,
          authorEmail: item.authorEmail,
          date: item.date,
          message: item.message,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          dirty: false,
          deleted: false,
        );

        messageLocalId = await db.insert('messages', newRecord.toMap());
      }

      await _mergeAttachments(db, messageLocalId, item.attachments);
    }

    final localRows = await db.query(
      'messages',
      where: 'account_id = ? AND deleted = 0',
      whereArgs: [accountId],
    );

    for (final row in localRows) {
      final record = MessageRecord.fromMap(row);
      if (record.dirty) continue;
      if (record.serverId != null && !remoteIds.contains(record.serverId)) {
        await db.delete(
          'message_attachments',
          where: 'message_local_id = ?',
          whereArgs: [record.localId],
        );
        await db.delete(
          'messages',
          where: 'local_id = ?',
          whereArgs: [record.localId],
        );
      }
    }
  }

  Future<void> _mergeAttachments(
    Database db,
    int messageLocalId,
    List<BackendAnnouncementAttachment> remoteAttachments,
  ) async {
    await db.delete(
      'message_attachments',
      where: 'message_local_id = ?',
      whereArgs: [messageLocalId],
    );

    for (final attachment in remoteAttachments) {
      await db.insert('message_attachments', {
        'server_id': attachment.id,
        'message_local_id': messageLocalId,
        'log_id': attachment.logId,
        'original_name': attachment.originalName,
        'stored_name': attachment.storedName,
        'mime_type': attachment.mimeType,
        'size': attachment.size,
        'path': attachment.path,
      });
    }
  }
}
