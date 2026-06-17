import 'package:drift/drift.dart';
import 'accounts.dart';
import 'people.dart';
import 'investments.dart';
import 'transactions.dart';

class AccountBalanceCaches extends Table {
  TextColumn get accountId => text().customConstraint('NOT NULL REFERENCES accounts(id)')();
  RealColumn get cashBalance => real().withDefault(const Constant(0.0))();
  RealColumn get liabilityBalance => real().withDefault(const Constant(0.0))();
  TextColumn get lastTransactionId => text().nullable().customConstraint('REFERENCES transactions(id)')();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {accountId};
}

class PersonBalanceCaches extends Table {
  TextColumn get personId => text().customConstraint('NOT NULL REFERENCES people(id)')();
  RealColumn get receivableBalance => real().withDefault(const Constant(0.0))();
  RealColumn get liabilityBalance => real().withDefault(const Constant(0.0))();
  TextColumn get lastTransactionId => text().nullable().customConstraint('REFERENCES transactions(id)')();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {personId};
}

class InvestmentBalanceCaches extends Table {
  TextColumn get investmentId => text().customConstraint('NOT NULL REFERENCES investments(id)')();
  RealColumn get investedCapital => real().withDefault(const Constant(0.0))();
  RealColumn get unitsHeld => real().withDefault(const Constant(0.0))();
  TextColumn get lastTransactionId => text().nullable().customConstraint('REFERENCES transactions(id)')();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {investmentId};
}
