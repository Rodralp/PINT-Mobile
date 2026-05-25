import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/reminder_api.dart';
import 'package:flutter_application_1/services/reminder_repository.dart';

void main() {
  test('ReminderRecord maps to and from map', () {
    final record = ReminderRecord(
      localId: 1,
      serverId: 99,
      accountId: 7,
      title: 'Titulo',
      description: 'Descricao',
      date: '2026-05-25',
      color: 'blue',
      updatedAt: 1234567890,
      dirty: true,
      deleted: false,
    );

    final map = record.toMap();
    final fromMap = ReminderRecord.fromMap(map);

    expect(fromMap.localId, record.localId);
    expect(fromMap.serverId, record.serverId);
    expect(fromMap.accountId, record.accountId);
    expect(fromMap.title, record.title);
    expect(fromMap.description, record.description);
    expect(fromMap.date, record.date);
    expect(fromMap.color, record.color);
    expect(fromMap.updatedAt, record.updatedAt);
    expect(fromMap.dirty, record.dirty);
    expect(fromMap.deleted, record.deleted);
  });

  test('ReminderRecord creates negative ids for local-only records', () {
    final record = ReminderRecord(
      localId: 4,
      serverId: null,
      accountId: 1,
      title: 'Teste',
      description: 'Local',
      date: '2026-05-25',
      color: 'green',
      updatedAt: 1,
      dirty: true,
      deleted: false,
    );

    final reminder = record.toReminder();

    expect(reminder, isA<Reminder>());
    expect(reminder.id, -4);
  });
}

