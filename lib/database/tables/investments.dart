import 'package:drift/drift.dart';

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // stock | mutual_fund | etf | gold | crypto | bond | fd | other
  TextColumn get symbol => text().nullable()();
  RealColumn get marketValue => real().nullable()(); // externally supplied
  DateTimeColumn get marketValueUpdatedAt => dateTime().nullable()();
  IntColumn get isArchived => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get purchaseTime => text().nullable()();
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
  TextColumn get fundSource => text().nullable()();
  TextColumn get sourceAccount => text().nullable()();
  TextColumn get ownershipType => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
