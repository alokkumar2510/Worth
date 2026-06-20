import 'package:drift/drift.dart';

class ReceivableActivities extends Table {
  TextColumn get id => text()();
  TextColumn get personId => text()();
  TextColumn get activityType => text()(); // 'reminder_sent', 'whatsapp_shared', 'payment_requested', 'payment_received', 'notes_added', 'created', 'settled'
  RealColumn get amount => real().nullable()();
  TextColumn get channel => text().nullable()(); // 'whatsapp', 'telegram', 'sms', 'upi', 'copy'
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
