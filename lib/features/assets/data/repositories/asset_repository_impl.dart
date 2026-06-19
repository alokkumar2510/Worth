import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/asset.dart' as domain;
import '../../domain/repositories/asset_repository.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class AssetRepositoryImpl implements AssetRepository {
  final db.AppDatabase _database;
  final Ref _ref;

  AssetRepositoryImpl(this._database, this._ref);

  // Helper to combine streams reactively
  Stream<List<T>> _combineThreeStreams<A, B, C, T>(
    Stream<A> streamA,
    Stream<B> streamB,
    Stream<C> streamC,
    List<T> Function(A, B, C) combiner,
  ) {
    StreamController<List<T>>? controller;
    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;
    StreamSubscription<C>? subC;

    A? lastA;
    B? lastB;
    C? lastC;

    bool hasA = false;
    bool hasB = false;
    bool hasC = false;

    void update() {
      if (hasA && hasB && hasC && controller != null && !controller.isClosed) {
        controller.add(combiner(lastA!, lastB!, lastC!));
      }
    }

    controller = StreamController<List<T>>(
      onListen: () {
        subA = streamA.listen((data) { lastA = data; hasA = true; update(); }, onError: controller?.addError);
        subB = streamB.listen((data) { lastB = data; hasB = true; update(); }, onError: controller?.addError);
        subC = streamC.listen((data) { lastC = data; hasC = true; update(); }, onError: controller?.addError);
      },
      onCancel: () {
        subA?.cancel();
        subB?.cancel();
        subC?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Stream<List<domain.Asset>> watchAllAssets() {
    // Watch accounts (type != credit)
    final accountsStream = (_database.select(_database.accounts)
          ..where((tbl) => tbl.type.equals('credit').not()))
        .watch();

    // Watch investments
    final investmentsStream = _database.select(_database.investments).watch();

    // Watch people (receivables)
    final peopleStream = _database.select(_database.people).watch();

    return _combineThreeStreams(
      accountsStream,
      investmentsStream,
      peopleStream,
      (List<db.Account> accounts, List<db.Investment> investments, List<db.Person> people) {
        final List<domain.Asset> assets = [];
        
        for (final acc in accounts) {
          assets.add(domain.Asset(
            id: acc.id,
            name: acc.name,
            type: acc.type,
            balance: 0.0, // Cache balance resolved in service layer or derived in UI
            notes: acc.notes,
            isArchived: acc.isArchived,
            createdAt: acc.createdAt,
            updatedAt: acc.updatedAt,
          ));
        }

        for (final inv in investments) {
          assets.add(domain.Asset(
            id: inv.id,
            name: inv.name,
            type: inv.type,
            balance: inv.marketValue ?? 0.0,
            notes: inv.notes,
            isArchived: inv.isArchived,
            createdAt: inv.createdAt,
            updatedAt: inv.updatedAt,
          ));
        }

        for (final p in people) {
          assets.add(domain.Asset(
            id: p.id,
            name: p.name,
            type: 'receivable',
            balance: 0.0,
            notes: p.notes,
            isArchived: p.isArchived,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
          ));
        }

        return assets;
      },
    );
  }

  @override
  Future<List<domain.Asset>> getAllAssets() async {
    final List<domain.Asset> assets = [];

    // 1. Accounts
    final accounts = await (_database.select(_database.accounts)
          ..where((tbl) => tbl.type.equals('credit').not()))
        .get();
    for (final acc in accounts) {
      assets.add(domain.Asset(
        id: acc.id,
        name: acc.name,
        type: acc.type,
        balance: 0.0,
        notes: acc.notes,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      ));
    }

    // 2. Investments
    final investments = await _database.select(_database.investments).get();
    for (final inv in investments) {
      assets.add(domain.Asset(
        id: inv.id,
        name: inv.name,
        type: inv.type,
        balance: inv.marketValue ?? 0.0,
        notes: inv.notes,
        isArchived: inv.isArchived,
        createdAt: inv.createdAt,
        updatedAt: inv.updatedAt,
      ));
    }

    // 3. People
    final people = await _database.select(_database.people).get();
    for (final p in people) {
      assets.add(domain.Asset(
        id: p.id,
        name: p.name,
        type: 'receivable',
        balance: 0.0,
        notes: p.notes,
        isArchived: p.isArchived,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      ));
    }

    return assets;
  }

  @override
  Future<domain.Asset?> getAssetById(String id) async {
    // Search non-credit Account
    final accQuery = _database.select(_database.accounts)
      ..where((tbl) => tbl.id.equals(id) & tbl.type.equals('credit').not());
    final acc = await accQuery.getSingleOrNull();
    if (acc != null) {
      return domain.Asset(
        id: acc.id,
        name: acc.name,
        type: acc.type,
        balance: 0.0,
        notes: acc.notes,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      );
    }

    // Search Investment
    final invQuery = _database.select(_database.investments)..where((tbl) => tbl.id.equals(id));
    final inv = await invQuery.getSingleOrNull();
    if (inv != null) {
      return domain.Asset(
        id: inv.id,
        name: inv.name,
        type: inv.type,
        balance: inv.marketValue ?? 0.0,
        notes: inv.notes,
        isArchived: inv.isArchived,
        createdAt: inv.createdAt,
        updatedAt: inv.updatedAt,
      );
    }

    // Search Person
    final pQuery = _database.select(_database.people)..where((tbl) => tbl.id.equals(id));
    final p = await pQuery.getSingleOrNull();
    if (p != null) {
      return domain.Asset(
        id: p.id,
        name: p.name,
        type: 'receivable',
        balance: 0.0,
        notes: p.notes,
        isArchived: p.isArchived,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );
    }

    return null;
  }



  @override
  Future<void> createAsset(domain.Asset asset) async {
    await _database.transaction(() async {
      if (asset.type == 'receivable') {
        // Create Person
        await _database.into(_database.people).insert(db.PeopleCompanion(
              id: Value(asset.id),
              name: Value(asset.name),
              notes: Value(asset.notes),
              isArchived: Value(asset.isArchived),
              createdAt: Value(asset.createdAt),
              updatedAt: Value(asset.updatedAt),
            ));
      } else if (['stock', 'mutual_fund', 'etf', 'gold', 'crypto', 'bond', 'fd'].contains(asset.type)) {
        // Create Investment
        await _database.into(_database.investments).insert(db.InvestmentsCompanion(
              id: Value(asset.id),
              name: Value(asset.name),
              type: Value(asset.type),
              marketValue: Value(asset.balance),
              isArchived: Value(asset.isArchived),
              notes: Value(asset.notes),
              createdAt: Value(asset.createdAt),
              updatedAt: Value(asset.updatedAt),
            ));
      } else {
        // Create non-credit Account
        await _database.into(_database.accounts).insert(db.AccountsCompanion(
              id: Value(asset.id),
              name: Value(asset.name),
              type: Value(asset.type),
              notes: Value(asset.notes),
              isArchived: Value(asset.isArchived),
              createdAt: Value(asset.createdAt),
              updatedAt: Value(asset.updatedAt),
            ));
      }
    });
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: asset.type == 'receivable'
          ? 'person'
          : (['stock', 'mutual_fund', 'etf', 'gold', 'crypto', 'bond', 'fd'].contains(asset.type)
              ? 'investment'
              : 'account'),
      entityId: asset.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> updateAsset(domain.Asset asset) async {
    await _database.transaction(() async {
      if (asset.type == 'receivable') {
        final existing = await (_database.select(_database.people)..where((tbl) => tbl.id.equals(asset.id))).getSingleOrNull();
        await _database.update(_database.people).replace(db.Person(
              id: asset.id,
              name: asset.name,
              phone: existing?.phone,
              notes: asset.notes,
              isArchived: asset.isArchived,
              createdAt: asset.createdAt,
              updatedAt: asset.updatedAt,
              syncStatus: asset.syncStatus,
              lastSyncedAt: existing?.lastSyncedAt,
              deviceId: existing?.deviceId,
              deletedAt: existing?.deletedAt,
              deletedBy: existing?.deletedBy,
              type: existing?.type ?? 'personal_loan',
            ));
      } else if (['stock', 'mutual_fund', 'etf', 'gold', 'crypto', 'bond', 'fd'].contains(asset.type)) {
        await _database.update(_database.investments).replace(db.Investment(
              id: asset.id,
              name: asset.name,
              type: asset.type,
              marketValue: asset.balance,
              isArchived: asset.isArchived,
              notes: asset.notes,
              createdAt: asset.createdAt,
              updatedAt: asset.updatedAt,
              syncStatus: asset.syncStatus,
            ));
      } else {
        await _database.update(_database.accounts).replace(db.Account(
              id: asset.id,
              name: asset.name,
              type: asset.type,
              notes: asset.notes,
              isArchived: asset.isArchived,
              createdAt: asset.createdAt,
              updatedAt: asset.updatedAt,
              syncStatus: asset.syncStatus,
            ));
      }
    });
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: asset.type == 'receivable'
          ? 'person'
          : (['stock', 'mutual_fund', 'etf', 'gold', 'crypto', 'bond', 'fd'].contains(asset.type)
              ? 'investment'
              : 'account'),
      entityId: asset.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> deleteAsset(String id) async {
    final asset = await getAssetById(id);
    if (asset != null) {
      final updated = asset.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now(),
      );
      await updateAsset(updated);
      await _ref.read(syncServiceProvider).queueOperation(
        entityType: asset.type == 'receivable'
            ? 'person'
            : (['stock', 'mutual_fund', 'etf', 'gold', 'crypto', 'bond', 'fd'].contains(asset.type)
                ? 'investment'
                : 'account'),
        entityId: id,
        operation: 'delete',
      );
    }
  }

  @override
  Future<List<domain.Asset>> searchAssets(String query) async {
    final searchPattern = '%$query%';
    final List<domain.Asset> assets = [];

    // search accounts
    final accs = await (_database.select(_database.accounts)
          ..where((tbl) => tbl.type.equals('credit').not() & (tbl.name.like(searchPattern) | tbl.notes.like(searchPattern))))
        .get();
    for (final acc in accs) {
      assets.add(domain.Asset(
        id: acc.id,
        name: acc.name,
        type: acc.type,
        balance: 0.0,
        notes: acc.notes,
        isArchived: acc.isArchived,
        createdAt: acc.createdAt,
        updatedAt: acc.updatedAt,
      ));
    }

    // search investments
    final invs = await (_database.select(_database.investments)
          ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern)))
        .get();
    for (final inv in invs) {
      assets.add(domain.Asset(
        id: inv.id,
        name: inv.name,
        type: inv.type,
        balance: inv.marketValue ?? 0.0,
        notes: inv.notes,
        isArchived: inv.isArchived,
        createdAt: inv.createdAt,
        updatedAt: inv.updatedAt,
      ));
    }

    // search people
    final ps = await (_database.select(_database.people)
          ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern)))
        .get();
    for (final p in ps) {
      assets.add(domain.Asset(
        id: p.id,
        name: p.name,
        type: 'receivable',
        balance: 0.0,
        notes: p.notes,
        isArchived: p.isArchived,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      ));
    }

    return assets;
  }
}
