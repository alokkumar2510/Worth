import 'package:drift/drift.dart';

/// One row per destination within a recovery allocation event.
/// A single recovery of ₹10,000 can have multiple destinations:
///   ₹5,000 → Cash | ₹3,000 → NIFTYBEES | ₹2,000 → Emergency Fund
class RecoveryDestinations extends Table {
  TextColumn get id => text()();

  /// Foreign key to the parent recovery_allocations record
  TextColumn get allocationId => text()();

  /// Category: Cash | BankAccount | Investment | MTFPosition | EmergencyFund | Goal | Asset | Custom
  TextColumn get destinationType => text()();

  /// ID of the destination entity (accountId, investmentId, goalId, etc.) — nullable for Cash/Custom
  TextColumn get destinationId => text().nullable()();

  /// Human-readable label shown in UI and reports
  TextColumn get destinationLabel => text()();

  /// Amount allocated to this destination
  RealColumn get amount => real()();

  /// The linked transaction created for this destination (if applicable)
  TextColumn get linkedTransactionId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
