import 'package:drift/drift.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // income | expense | transfer | borrow_money | repay_money | lend_money | recover_money | investment_buy | investment_sell | expected_income_received | interest_accrued | void
  RealColumn get amount => real()();
  TextColumn get category => text().nullable()();
  TextColumn get fromAccountId => text().nullable().customConstraint('REFERENCES accounts(id)')();
  TextColumn get toAccountId => text().nullable().customConstraint('REFERENCES accounts(id)')();
  TextColumn get personId => text().nullable().customConstraint('REFERENCES people(id)')();
  TextColumn get investmentId => text().nullable().customConstraint('REFERENCES investments(id)')();
  TextColumn get voidedTransactionId => text().nullable().customConstraint('REFERENCES transactions(id)')();
  TextColumn get notes => text().nullable()();
  RealColumn get pricePerUnit => real().nullable()();
  RealColumn get units => real().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
