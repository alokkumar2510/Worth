import '../../database/database.dart' as db;

class TransactionValidator {
  // Validates transaction fields and logic constraints
  void validate(db.TransactionsCompanion companion) {
    if (!companion.amount.present || companion.amount.value <= 0) {
      throw const FormatException('Transaction amount must be strictly greater than 0.');
    }

    if (!companion.type.present) {
      throw const FormatException('Transaction type is required.');
    }

    final type = companion.type.value;

    switch (type) {
      case 'income':
        if (!companion.toAccountId.present || companion.toAccountId.value == null) {
          throw const FormatException('Income transaction requires a destination account (toAccountId).');
        }
        if (companion.fromAccountId.value != null) {
          throw const FormatException('Income transaction cannot have a source account (fromAccountId).');
        }
        break;

      case 'expense':
        if (!companion.fromAccountId.present || companion.fromAccountId.value == null) {
          throw const FormatException('Expense transaction requires a source account (fromAccountId).');
        }
        if (companion.toAccountId.value != null) {
          throw const FormatException('Expense transaction cannot have a destination account (toAccountId).');
        }
        break;

      case 'transfer':
        if (!companion.fromAccountId.present || companion.fromAccountId.value == null ||
            !companion.toAccountId.present || companion.toAccountId.value == null) {
          throw const FormatException('Transfer transaction requires both source (fromAccountId) and destination (toAccountId) accounts.');
        }
        if (companion.fromAccountId.value == companion.toAccountId.value) {
          throw const FormatException('Source and destination accounts in a transfer cannot be the same.');
        }
        break;

      case 'borrow_money':
        if (!companion.toAccountId.present || companion.toAccountId.value == null) {
          throw const FormatException('Borrow money transaction requires a destination account (toAccountId).');
        }
        if (!companion.personId.present || companion.personId.value == null) {
          throw const FormatException('Borrow money transaction requires a lender (personId).');
        }
        break;

      case 'repay_money':
        if (!companion.fromAccountId.present || companion.fromAccountId.value == null) {
          throw const FormatException('Repay money transaction requires a source account (fromAccountId).');
        }
        if (!companion.personId.present || companion.personId.value == null) {
          throw const FormatException('Repay money transaction requires a recipient (personId).');
        }
        break;

      case 'lend_money':
        if (!companion.fromAccountId.present || companion.fromAccountId.value == null) {
          throw const FormatException('Lend money transaction requires a source account (fromAccountId).');
        }
        if (!companion.personId.present || companion.personId.value == null) {
          throw const FormatException('Lend money transaction requires a borrower (personId).');
        }
        break;

      case 'recover_money':
        if (!companion.toAccountId.present || companion.toAccountId.value == null) {
          throw const FormatException('Recover money transaction requires a destination account (toAccountId).');
        }
        if (!companion.personId.present || companion.personId.value == null) {
          throw const FormatException('Recover money transaction requires a payer (personId).');
        }
        break;

      case 'investment_buy':
        if (!companion.fromAccountId.present || companion.fromAccountId.value == null) {
          throw const FormatException('Investment buy transaction requires a source account (fromAccountId).');
        }
        if (!companion.investmentId.present || companion.investmentId.value == null) {
          throw const FormatException('Investment buy transaction requires an investment instrument (investmentId).');
        }
        break;

      case 'investment_sell':
        if (!companion.toAccountId.present || companion.toAccountId.value == null) {
          throw const FormatException('Investment sell transaction requires a destination account (toAccountId).');
        }
        if (!companion.investmentId.present || companion.investmentId.value == null) {
          throw const FormatException('Investment sell transaction requires an investment instrument (investmentId).');
        }
        break;

      case 'expected_income_received':
        if (!companion.toAccountId.present || companion.toAccountId.value == null) {
          throw const FormatException('Expected income receipt requires a destination account (toAccountId).');
        }
        break;

      case 'interest_accrued':
        if (!companion.personId.present || companion.personId.value == null) {
          throw const FormatException('Interest accrued transaction requires an associated person (personId).');
        }
        break;

      case 'void':
        // A void transaction is a reversal created by the system, does not need separate fields check
        break;

      default:
        throw FormatException('Unsupported transaction type: $type');
    }
  }
}
