import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../../database/database.dart';
import '../providers/dependency_provider.dart';
import '../providers/mock_database.dart';
import '../providers/app_providers.dart';

class LiabilitiesService {
  final Ref _ref;
  final _uuid = const Uuid();

  LiabilitiesService(this._ref);

  AppDatabase get _db => _ref.read(realDatabaseProvider);
  bool get _isMock => _ref.read(mockModeProvider);

  Future<String> createLiability({
    required String creditor,
    required double originalAmount,
    String? notes,
    required DateTime date,
  }) async {
    if (_isMock) {
      final notifier = _ref.read(mockDatabaseProvider.notifier);
      // Try to find existing active person
      var person = notifier.state.people.firstWhereOrNull(
        (p) => p.name.toLowerCase() == creditor.toLowerCase() && p.isArchived == 0,
      );

      if (person == null) {
        person = await notifier.addPerson(creditor, null, notes);
      }

      await notifier.addBorrowTransaction(
        person.id,
        'acc_primary_bank_uuid', // default destination account
        originalAmount,
        notes,
        date,
      );
      return person.id;
    } else {
      Person? person = await (_db.select(_db.people)
            ..where((tbl) => tbl.name.equals(creditor) & tbl.isArchived.equals(0)))
          .getSingleOrNull();

      String personId;
      if (person == null) {
        personId = _uuid.v4();
        await _db.into(_db.people).insert(PeopleCompanion(
          id: Value(personId),
          name: Value(creditor),
          isArchived: const Value(0),
          createdAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      } else {
        personId = person.id;
      }

      final companion = TransactionsCompanion(
        id: Value(_uuid.v4()),
        type: const Value('borrow_money'),
        amount: Value(originalAmount),
        toAccountId: const Value('acc_primary_bank_uuid'),
        personId: Value(personId),
        notes: Value(notes ?? 'Borrowed money from $creditor'),
        transactionDate: Value(date),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      );

      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      return personId;
    }
  }

  Future<void> repayAmount({
    required String liabilityId,
    required String fromAccountId,
    required double amountPaid,
    String? notes,
    required DateTime date,
  }) async {
    if (_isMock) {
      await _ref.read(mockDatabaseProvider.notifier).addRepayTransaction(
        liabilityId,
        fromAccountId,
        amountPaid,
        notes,
        date,
      );
    } else {
      final companion = TransactionsCompanion(
        id: Value(_uuid.v4()),
        type: const Value('repay_money'),
        amount: Value(amountPaid),
        fromAccountId: Value(fromAccountId),
        personId: Value(liabilityId),
        notes: Value(notes ?? 'Repaid borrowed money'),
        transactionDate: Value(date),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      );

      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
    }
  }

  Future<void> closeLiability(String liabilityId) async {
    if (_isMock) {
      final notifier = _ref.read(mockDatabaseProvider.notifier);
      notifier.state = notifier.state.copyWith(
        people: notifier.state.people.map((p) => p.id == liabilityId ? p.copyWith(isArchived: 1, updatedAt: DateTime.now().toUtc()) : p).toList(),
      );
    } else {
      final query = _db.update(_db.people)..where((tbl) => tbl.id.equals(liabilityId));
      await query.write(PeopleCompanion(
        isArchived: const Value(1),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
    }
  }

  Future<double> calculateOutstanding(String liabilityId) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      return state.getPersonLiabilityBalance(liabilityId);
    } else {
      final cache = await (_db.select(_db.personBalanceCaches)
            ..where((tbl) => tbl.personId.equals(liabilityId)))
          .getSingleOrNull();
      return cache?.liabilityBalance ?? 0.0;
    }
  }
}
