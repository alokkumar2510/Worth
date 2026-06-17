import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import 'transaction_validator.dart';
import 'transaction_processor.dart';

class TransactionService {
  final db.AppDatabase _db;
  final TransactionValidator _validator;
  final TransactionProcessor _processor;

  TransactionService(
    this._db,
    this._validator,
    this._processor,
  );

  // Validates and processes a new transaction within a DB transaction block
  Future<String> createTransaction(db.TransactionsCompanion companion) async {
    // 1. Double-entry style validation check
    _validator.validate(companion);

    // 2. Execute database transaction
    await _db.transaction(() async {
      await _processor.processTransaction(companion);
    });

    return companion.id.value;
  }

  // Voids an existing transaction within a DB transaction block
  Future<void> voidTransaction(String originalTxId) async {
    await _db.transaction(() async {
      await _processor.processVoid(originalTxId);
    });
  }
}
