import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash | bank | wallet | credit | other
  TextColumn get notes => text().nullable()();
  IntColumn get isArchived => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();
  TextColumn get fundingSource => text().nullable()();
  TextColumn get fundingLiabilityId => text().nullable()();
  TextColumn get fundingDetails => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
