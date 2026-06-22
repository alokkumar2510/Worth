import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/education_loan.dart';
import '../../../database/database.dart' as db;
import '../../../core/providers/app_providers.dart';

// ============================================================
// ISOLATED EDUCATION LOAN PROVIDER
// ============================================================
// This provider is completely decoupled from mockDatabaseProvider.
// It reads / writes ONLY the 'edu_loan_data' settings key in SQLite.
// Zero impact on: Net Worth · Portfolio · Assets · Liabilities · Wealth Score
// ============================================================

final educationLoanProvider =
    StateNotifierProvider<EducationLoanNotifier, EducationLoanState>((ref) {
  return EducationLoanNotifier(ref);
});

const _settingsKey = 'edu_loan_data';

class EducationLoanNotifier extends StateNotifier<EducationLoanState> {
  final Ref _ref;

  EducationLoanNotifier(this._ref) : super(const EducationLoanState()) {
    _loadState();
  }

  // ----------------------------------------------------------
  // LOAD — reads from SQLite settings key
  // ----------------------------------------------------------
  Future<void> _loadState() async {
    try {
      final database = _ref.read(realDatabaseProvider);
      final settingsList = await database.select(database.settings).get();
      final settingsMap = {for (var s in settingsList) s.key: s.value};
      final raw = settingsMap[_settingsKey];
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = EducationLoanState.fromJson(decoded);
      }
    } catch (e) {
      // Silently degrade — no loan data yet
    }
  }

  // ----------------------------------------------------------
  // SAVE — persists current state to SQLite settings key
  // ----------------------------------------------------------
  Future<void> _saveState() async {
    try {
      final database = _ref.read(realDatabaseProvider);
      final json = jsonEncode(state.toJson());
      await database.into(database.settings).insertOnConflictUpdate(
        db.Setting(key: _settingsKey, value: json),
      );
    } catch (e) {
      // log silently
    }
  }

  // ----------------------------------------------------------
  // LOAN CRUD
  // ----------------------------------------------------------
  Future<void> createLoan(EducationLoan loan) async {
    state = state.copyWith(loan: loan);
    await _saveState();
  }

  Future<void> updateLoan(EducationLoan loan) async {
    state = state.copyWith(loan: loan);
    await _saveState();
  }

  Future<void> deleteLoan() async {
    state = state.copyWith(clearLoan: true, disbursements: [], interestRecords: [], documents: [], semesterExpenses: [], emiSimulations: [], prepaymentSimulations: []);
    await _saveState();
  }

  // ----------------------------------------------------------
  // DISBURSEMENTS
  // ----------------------------------------------------------
  Future<void> addDisbursement(LoanDisbursement d) async {
    state = state.copyWith(disbursements: [...state.disbursements, d]);
    await _saveState();
  }

  Future<void> updateDisbursement(LoanDisbursement updated) async {
    final list = state.disbursements.map((d) => d.id == updated.id ? updated : d).toList();
    state = state.copyWith(disbursements: list);
    await _saveState();
  }

  Future<void> deleteDisbursement(String id) async {
    state = state.copyWith(disbursements: state.disbursements.where((d) => d.id != id).toList());
    await _saveState();
  }

  // ----------------------------------------------------------
  // INTEREST RECORDS
  // ----------------------------------------------------------
  Future<void> addInterestRecord(LoanInterestRecord r) async {
    state = state.copyWith(interestRecords: [...state.interestRecords, r]);
    await _saveState();
  }

  Future<void> deleteInterestRecord(String id) async {
    state = state.copyWith(interestRecords: state.interestRecords.where((r) => r.id != id).toList());
    await _saveState();
  }

  // ----------------------------------------------------------
  // DOCUMENTS
  // ----------------------------------------------------------
  Future<void> addDocument(LoanDocument doc) async {
    state = state.copyWith(documents: [...state.documents, doc]);
    await _saveState();
  }

  Future<void> deleteDocument(String id) async {
    state = state.copyWith(documents: state.documents.where((d) => d.id != id).toList());
    await _saveState();
  }

  // ----------------------------------------------------------
  // SEMESTER EXPENSES
  // ----------------------------------------------------------
  Future<void> addSemesterExpense(SemesterExpense s) async {
    state = state.copyWith(semesterExpenses: [...state.semesterExpenses, s]);
    await _saveState();
  }

  Future<void> updateSemesterExpense(SemesterExpense updated) async {
    final list = state.semesterExpenses.map((s) => s.id == updated.id ? updated : s).toList();
    state = state.copyWith(semesterExpenses: list);
    await _saveState();
  }

  Future<void> deleteSemesterExpense(String id) async {
    state = state.copyWith(semesterExpenses: state.semesterExpenses.where((s) => s.id != id).toList());
    await _saveState();
  }

  // ----------------------------------------------------------
  // EMI SIMULATIONS
  // ----------------------------------------------------------
  Future<void> saveEmiSimulation(EmiSimulation sim) async {
    // Keep last 5 simulations
    final list = [sim, ...state.emiSimulations].take(5).toList();
    state = state.copyWith(emiSimulations: list);
    await _saveState();
  }

  // ----------------------------------------------------------
  // PREPAYMENT SIMULATIONS
  // ----------------------------------------------------------
  Future<void> savePrepaymentSimulation(PrepaymentSimulation sim) async {
    final list = [sim, ...state.prepaymentSimulations].take(5).toList();
    state = state.copyWith(prepaymentSimulations: list);
    await _saveState();
  }

  // ----------------------------------------------------------
  // RELOAD (e.g. after app resume)
  // ----------------------------------------------------------
  Future<void> reload() async {
    await _loadState();
  }
}
