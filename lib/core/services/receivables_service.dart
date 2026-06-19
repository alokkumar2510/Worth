import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../../database/database.dart';
import '../providers/dependency_provider.dart';
import '../providers/mock_database.dart';
import '../providers/app_providers.dart';

class ReceivablesService {
  final Ref _ref;
  final _uuid = const Uuid();

  ReceivablesService(this._ref);

  AppDatabase get _db => _ref.read(realDatabaseProvider);
  bool get _isMock => _ref.read(mockModeProvider);

  Future<String> createReceivable({
    required String personName,
    required double amountGiven,
    String? notes,
    required DateTime date,
  }) async {
    if (_isMock) {
      final notifier = _ref.read(mockDatabaseProvider.notifier);
      // Try to find existing active person
      var person = notifier.state.people.firstWhereOrNull(
        (p) => p.name.toLowerCase() == personName.toLowerCase() && p.isArchived == 0,
      );
      
      if (person == null) {
        person = await notifier.addPerson(personName, null, notes);
      }
      
      await notifier.addLendTransaction(
        person.id,
        'acc_primary_bank_uuid', // default source account
        amountGiven,
        notes,
        date,
      );
      return person.id;
    } else {
      Person? person = await (_db.select(_db.people)
            ..where((tbl) => tbl.name.equals(personName) & tbl.isArchived.equals(0)))
          .getSingleOrNull();
      
      String personId;
      if (person == null) {
        personId = _uuid.v4();
        await _db.into(_db.people).insert(PeopleCompanion(
          id: Value(personId),
          name: Value(personName),
          isArchived: const Value(0),
          createdAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      } else {
        personId = person.id;
      }

      final companion = TransactionsCompanion(
        id: Value(_uuid.v4()),
        type: const Value('lend_money'),
        amount: Value(amountGiven),
        fromAccountId: const Value('acc_primary_bank_uuid'),
        personId: Value(personId),
        notes: Value(notes ?? 'Lent money to $personName'),
        transactionDate: Value(date),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      );

      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      return personId;
    }
  }

  Future<void> recoverAmount({
    required String receivableId,
    required String toAccountId,
    required double amountRecovered,
    String? notes,
    required DateTime date,
  }) async {
    if (_isMock) {
      await _ref.read(mockDatabaseProvider.notifier).addRecoverTransaction(
        receivableId,
        toAccountId,
        amountRecovered,
        notes,
        date,
      );
    } else {
      final companion = TransactionsCompanion(
        id: Value(_uuid.v4()),
        type: const Value('recover_money'),
        amount: Value(amountRecovered),
        toAccountId: Value(toAccountId),
        personId: Value(receivableId),
        notes: Value(notes ?? 'Recovered loan payment'),
        transactionDate: Value(date),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      );

      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
    }
  }

  Future<void> closeReceivable(String receivableId) async {
    if (_isMock) {
      final notifier = _ref.read(mockDatabaseProvider.notifier);
      notifier.state = notifier.state.copyWith(
        people: notifier.state.people.map((p) => p.id == receivableId ? p.copyWith(isArchived: 1, updatedAt: DateTime.now().toUtc()) : p).toList(),
      );
    } else {
      final query = _db.update(_db.people)..where((tbl) => tbl.id.equals(receivableId));
      await query.write(PeopleCompanion(
        isArchived: const Value(1),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
    }
  }

  Future<double> calculateOutstanding(String receivableId) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      return state.getPersonReceivableBalance(receivableId);
    } else {
      final cache = await (_db.select(_db.personBalanceCaches)
            ..where((tbl) => tbl.personId.equals(receivableId)))
          .getSingleOrNull();
      return cache?.receivableBalance ?? 0.0;
    }
  }
}
