import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/liability.dart' as domain;
import '../../domain/repositories/liability_repository.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class LiabilityRepositoryImpl implements LiabilityRepository {
  final db.AppDatabase _database;
  final Ref _ref;

  LiabilityRepositoryImpl(this._database, this._ref);

  // Helper to combine streams reactively
  Stream<List<T>> _combineTwoStreams<A, B, T>(
    Stream<A> streamA,
    Stream<B> streamB,
    List<T> Function(A, B) combiner,
  ) {
    StreamController<List<T>>? controller;
    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;

    A? lastA;
    B? lastB;

    bool hasA = false;
    bool hasB = false;

    void update() {
      if (hasA && hasB && controller != null && !controller.isClosed) {
        controller.add(combiner(lastA!, lastB!));
      }
    }

    controller = StreamController<List<T>>(
      onListen: () {
        subA = streamA.listen((data) { lastA = data; hasA = true; update(); }, onError: controller?.addError);
        subB = streamB.listen((data) { lastB = data; hasB = true; update(); }, onError: controller?.addError);
      },
      onCancel: () {
        subA?.cancel();
        subB?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Stream<List<domain.Liability>> watchAllLiabilities() {
    final creditAccountsStream = (_database.select(_database.accounts)
          ..where((tbl) => tbl.type.equals('credit')))
        .watch();

    final peopleStream = _database.select(_database.people).watch();

    return _combineTwoStreams(
      creditAccountsStream,
      peopleStream,
      (List<db.Account> accounts, List<db.Person> people) {
        final List<domain.Liability> liabilities = [];

        for (final acc in accounts) {
          liabilities.add(domain.Liability(
            id: acc.id,
            name: acc.name,
            type: 'credit_card',
            outstandingAmount: 0.0, // Cache balance resolved in service layer or derived in UI
            notes: acc.notes,
            isArchived: acc.isArchived,
            createdAt: acc.createdAt,
            updatedAt: acc.updatedAt,
          ));
        }

        for (final p in people) {
          liabilities.add(domain.Liability(
            id: p.id,
            name: p.name,
            type: p.type,
            outstandingAmount: 0.0,
            notes: p.notes,
            isArchived: p.isArchived,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
          ));
        }

        return liabilities;
      },
    );
  }

  @override
  Future<List<domain.Liability>> getAllLiabilities() async {
    final List<domain.Liability> liabilities = [];

    // Credit Accounts
    final accounts = await (_database.select(_database.accounts)
          ..where((tbl) => tbl.type.equals('credit')))
        .get();
    for (final acc in accounts) {
      liabilities.add(domain.Liability(
        id: acc.id,
        name: acc.name,
        type: 'credit_card',
        outstandingAmount: 0.0,
        notes: acc.notes,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      ));
    }

    // People (Debts)
    final people = await _database.select(_database.people).get();
    for (final p in people) {
      liabilities.add(domain.Liability(
        id: p.id,
        name: p.name,
        type: p.type,
        outstandingAmount: 0.0,
        notes: p.notes,
        isArchived: p.isArchived,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      ));
    }

    return liabilities;
  }

  @override
  Future<domain.Liability?> getLiabilityById(String id) async {
    // Check credit accounts
    final accQuery = _database.select(_database.accounts)
      ..where((tbl) => tbl.id.equals(id) & tbl.type.equals('credit'));
    final acc = await accQuery.getSingleOrNull();
    if (acc != null) {
      return domain.Liability(
        id: acc.id,
        name: acc.name,
        type: 'credit_card',
        outstandingAmount: 0.0,
        notes: acc.notes,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      );
    }

    // Check people
    final pQuery = _database.select(_database.people)..where((tbl) => tbl.id.equals(id));
    final p = await pQuery.getSingleOrNull();
    if (p != null) {
      return domain.Liability(
        id: p.id,
        name: p.name,
        type: p.type,
        outstandingAmount: 0.0,
        notes: p.notes,
        isArchived: p.isArchived,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );
    }

    return null;
  }



  @override
  Future<void> createLiability(domain.Liability liability) async {
    final isPeer = liability.type != 'credit_card';
    await _database.transaction(() async {
      if (isPeer) {
        await _database.into(_database.people).insert(db.PeopleCompanion(
              id: Value(liability.id),
              name: Value(liability.name),
              notes: Value(liability.notes),
              isArchived: Value(liability.isArchived),
              createdAt: Value(liability.createdAt),
              updatedAt: Value(liability.updatedAt),
              type: Value(liability.type),
            ));
      } else {
        await _database.into(_database.accounts).insert(db.AccountsCompanion(
              id: Value(liability.id),
              name: Value(liability.name),
              type: const Value('credit'),
              notes: Value(liability.notes),
              isArchived: Value(liability.isArchived),
              createdAt: Value(liability.createdAt),
              updatedAt: Value(liability.updatedAt),
            ));
      }
    });
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: isPeer ? 'person' : 'account',
      entityId: liability.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> updateLiability(domain.Liability liability) async {
    final isPeer = liability.type != 'credit_card';
    await _database.transaction(() async {
      if (isPeer) {
        await _database.update(_database.people).replace(db.Person(
              id: liability.id,
              name: liability.name,
              notes: liability.notes,
              isArchived: liability.isArchived,
              createdAt: liability.createdAt,
              updatedAt: liability.updatedAt,
              syncStatus: liability.syncStatus,
              type: liability.type,
            ));
      } else {
        await _database.update(_database.accounts).replace(db.Account(
              id: liability.id,
              name: liability.name,
              type: 'credit',
              notes: liability.notes,
              isArchived: liability.isArchived,
              createdAt: liability.createdAt,
              updatedAt: liability.updatedAt,
              syncStatus: liability.syncStatus,
            ));
      }
    });
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: isPeer ? 'person' : 'account',
      entityId: liability.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> deleteLiability(String id) async {
    final liability = await getLiabilityById(id);
    if (liability != null) {
      final updated = liability.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      );
      await updateLiability(updated);
      await _ref.read(syncServiceProvider).queueOperation(
        entityType: liability.type != 'credit_card' ? 'person' : 'account',
        entityId: id,
        operation: 'delete',
      );
    }
  }

  @override
  Future<List<domain.Liability>> searchLiabilities(String query) async {
    final searchPattern = '%$query%';
    final List<domain.Liability> liabilities = [];

    // Search credit accounts
    final accs = await (_database.select(_database.accounts)
          ..where((tbl) => tbl.type.equals('credit') & (tbl.name.like(searchPattern) | tbl.notes.like(searchPattern))))
        .get();
    for (final acc in accs) {
      liabilities.add(domain.Liability(
        id: acc.id,
        name: acc.name,
        type: 'credit_card',
        outstandingAmount: 0.0,
        notes: acc.notes,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      ));
    }

    // Search people
    final ps = await (_database.select(_database.people)
          ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern)))
        .get();
    for (final p in ps) {
      liabilities.add(domain.Liability(
        id: p.id,
        name: p.name,
        type: p.type,
        outstandingAmount: 0.0,
        notes: p.notes,
        isArchived: p.isArchived,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      ));
    }

    return liabilities;
  }
}
