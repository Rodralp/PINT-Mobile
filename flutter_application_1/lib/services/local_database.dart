import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  static const String _databaseName = 'pint_offline.db';
  static const int _databaseVersion = 4;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final db = await _openDatabase();
    _database = db;
    return db;
  }

  Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createV2Tables(db);
        }
        if (oldVersion < 3) {
          await _createV3Tables(db);
        }
        if (oldVersion < 4) {
          await _createV4Tables(db);
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE reminders (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        account_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        color TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_reminders_account ON reminders(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_reminders_server ON reminders(server_id)',
    );

    await _createV2Tables(db);
    await _createV3Tables(db);
    await _createV4Tables(db);
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE notifications (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        account_id INTEGER NOT NULL,
        log_id INTEGER NOT NULL DEFAULT 0,
        is_read INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL DEFAULT '',
        summary TEXT NOT NULL DEFAULT '',
        message TEXT NOT NULL DEFAULT '',
        type TEXT NOT NULL DEFAULT 'mensagem',
        date TEXT NOT NULL DEFAULT '',
        author TEXT NOT NULL DEFAULT 'Sistema',
        updated_at INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_notifications_account ON notifications(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_server ON notifications(server_id)',
    );

    await db.execute('''
      CREATE TABLE messages (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        account_id INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'mensagem',
        priority INTEGER NOT NULL DEFAULT 3,
        title TEXT NOT NULL DEFAULT '',
        summary TEXT NOT NULL DEFAULT '',
        author TEXT NOT NULL DEFAULT 'Sistema',
        author_email TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL DEFAULT '',
        message TEXT NOT NULL DEFAULT '',
        updated_at INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_messages_account ON messages(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_server ON messages(server_id)',
    );

    await db.execute('''
      CREATE TABLE message_attachments (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        message_local_id INTEGER NOT NULL,
        log_id INTEGER NOT NULL DEFAULT 0,
        original_name TEXT NOT NULL DEFAULT '',
        stored_name TEXT NOT NULL DEFAULT '',
        mime_type TEXT NOT NULL DEFAULT '',
        size INTEGER NOT NULL DEFAULT 0,
        path TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_attachments_message ON message_attachments(message_local_id)',
    );

    await db.execute('''
      CREATE TABLE badge_requirements_cache (
        badge_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL DEFAULT 0,
        requirements_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (badge_id, account_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE pedido_detail_cache (
        pedido_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL DEFAULT 0,
        detail_json TEXT NOT NULL DEFAULT '{}',
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (pedido_id, account_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE preference_areas_cache (
        account_id INTEGER NOT NULL PRIMARY KEY,
        areas_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE dashboard_cache (
        account_id INTEGER NOT NULL PRIMARY KEY,
        stats_json TEXT NOT NULL DEFAULT '[]',
        in_progress_json TEXT NOT NULL DEFAULT '[]',
        suggestions_json TEXT NOT NULL DEFAULT '[]',
        timeline_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createV4Tables(Database db) async {
    await db.execute('''
      CREATE TABLE requests_cache (
        account_id INTEGER NOT NULL,
        requests_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (account_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_paths_cache (
        account_id INTEGER NOT NULL,
        paths_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (account_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ranking_cache (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        data_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}
