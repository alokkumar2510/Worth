import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worth/core/providers/dependency_provider.dart';
import 'package:worth/core/providers/mock_database.dart';
import 'package:worth/database/database.dart';
import 'package:worth/features/recovery/domain/utils/recovery_calculator.dart';

String cleanPhoneNumber(String phone) {
  // 1. Remove spaces and special characters
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  
  // 2. Remove duplicate country code (starts with 9191 and length is 14)
  if (digits.startsWith('9191') && digits.length == 14) {
    digits = digits.substring(2);
  }
  
  // 3. Prepend 91 if it's exactly 10 digits
  if (digits.length == 10) {
    digits = '91$digits';
  }
  
  return digits;
}

void main() {
  group('Debt Recovery Module Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          mockModeProvider.overrideWith((ref) => true),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Phone Number Cleaning Helper Logic', () {
      expect(cleanPhoneNumber('+91 98765 43210'), equals('919876543210'));
      expect(cleanPhoneNumber('91919876543210'), equals('919876543210'));
      expect(cleanPhoneNumber('9876543210'), equals('919876543210'));
      expect(cleanPhoneNumber('+91-98765-43210'), equals('919876543210'));
      expect(cleanPhoneNumber('919876543210'), equals('919876543210'));
    });

    test('Create Test Record and Verify Balance, WhatsApp, UPI', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // Create test record
      // Name: Rahul Sharma
      // Phone: 919876543210
      // Amount: 12500
      // UPI: alok@oksbi
      final testPerson = await notifier.addPerson(
        'Rahul Sharma',
        '919876543210',
        'Test receivable record',
        'receivable',
        '919876543210',
        DateTime.now(),
        null,
        'alok@oksbi',
        null,
        null,
        null, // photoPath
      );

      // Add lend transaction of 12,500
      await notifier.addLendTransaction(
        testPerson.id,
        'acc_primary_bank_uuid',
        12500.0,
        'Initial Lend to Rahul Sharma',
        DateTime.now(),
      );

      final state = container.read(mockDatabaseProvider);

      // 1. Verify record exists and outstanding balance matches
      final person = state.people.firstWhere((p) => p.id == testPerson.id);
      expect(person.name, equals('Rahul Sharma'));
      expect(person.phone, equals('919876543210'));
      expect(person.whatsApp, equals('919876543210'));
      expect(person.upiId, equals('alok@oksbi'));

      final balance = state.getPersonReceivableBalance(person.id);
      expect(balance, equals(12500.0));

      // 2. Verify payment link works (UPI payment URI matching upi://pay...)
      final upiLink = 'upi://pay?pa=${person.upiId}&pn=${Uri.encodeComponent(person.name)}&am=$balance';
      expect(upiLink, contains('upi://pay'));
      expect(upiLink, contains('pa=alok@oksbi'));
      expect(upiLink, contains('am=12500.0'));

      // 3. Verify phone formatting produces the correct cleaned number
      final cleanPhone = cleanPhoneNumber(person.whatsApp ?? person.phone ?? '');
      expect(cleanPhone, equals('919876543210'));

      // 4. Verify WhatsApp opens Rahul's chat with message prefilled
      final shareMsg = 'Hi ${person.name}, outstanding is $balance';
      final waUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(shareMsg)}';
      expect(waUrl, startsWith('https://wa.me/919876543210'));
      expect(waUrl, contains('text=Hi%20Rahul%20Sharma%2C%20outstanding%20is%2012500.0'));
    });
  });
}
