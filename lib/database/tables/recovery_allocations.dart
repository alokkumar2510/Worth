import 'package:drift/drift.dart';

/// Stores one record per recovery event — i.e., whenever a receivable is
/// partially or fully recovered. Links to the source recover_money transaction.
class RecoveryAllocations extends Table {
  TextColumn get id => text()();

  /// The person (receivable source) who paid back
  TextColumn get personId => text()();

  /// The recover_money transaction that triggered this allocation
  TextColumn get sourceTransactionId => text()();

  /// Total amount recovered in this event
  RealColumn get totalAmount => real()();

  /// Amount that was explicitly allocated to destinations
  RealColumn get allocatedAmount => real().withDefault(const Constant(0.0))();

  /// Amount left unallocated (kept as-is in source account)
  RealColumn get unallocatedAmount => real().withDefault(const Constant(0.0))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
