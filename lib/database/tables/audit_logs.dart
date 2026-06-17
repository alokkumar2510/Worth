import 'package:drift/drift.dart';

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // transaction | account | investment | person | goal
  TextColumn get entityId => text()();
  TextColumn get action => text()(); // created | voided | restored | archived
  TextColumn get detailsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
