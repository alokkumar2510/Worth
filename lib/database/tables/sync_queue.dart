import 'package:drift/drift.dart';

class SyncQueues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'account' | 'person' | 'investment' | 'investment_lot' | 'transaction' | 'expected_income' | 'goal' | 'snapshot' | 'adjustment' | 'mtf_position' | 'sip' | 'setting'
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'upsert' | 'delete'
  TextColumn get payload => text().nullable()(); // JSON serialized representation
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | syncing | synced | failed | retrying
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
}
