import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/billing/models/payment.dart';

void main() {
  group('Payment Model Tests', () {
    // Test data setup
    final validPaymentJson = {
      'id': 1,
      'invoice_id': 101,
      'payment_date': '2024-01-15',
      'amount': 4500.0,
      'method': 'credit_card',
      'reference': 'REF-12345',
      'notes': 'Payment processed successfully',
      'invoices': {
        'invoice_number': 'INV-2024-001',
        'patients': {'first_name': 'John', 'last_name': 'Doe'},
      },
    };

    test('should create Payment from valid JSON with nested data', () {
      // Act
      final payment = Payment.fromJson(validPaymentJson);

      // Assert
      expect(payment.id, 1);
      expect(payment.invoiceId, 101);
      expect(payment.invoiceNumber, 'INV-2024-001');
      expect(payment.patientName, 'John Doe');
      expect(payment.paymentDate, DateTime.parse('2024-01-15'));
      expect(payment.amount, 4500.0);
      expect(payment.method, 'credit_card');
      expect(payment.reference, 'REF-12345');
      expect(payment.notes, 'Payment processed successfully');
    });

    test('should handle JSON without nested invoice data', () {
      // Arrange
      final minimalJson = {
        'id': 2,
        'invoice_id': 102,
        'payment_date': '2024-01-20',
        'amount': 2000.0,
        'method': 'cash',
      };

      // Act
      final payment = Payment.fromJson(minimalJson);

      // Assert
      expect(payment.id, 2);
      expect(payment.invoiceId, 102);
      expect(payment.invoiceNumber, isNull);
      expect(payment.patientName, isNull);
      expect(payment.amount, 2000.0);
      expect(payment.method, 'cash');
    });

    test('should extract invoice number from nested invoices object', () {
      // Arrange
      final jsonWithInvoice = {
        'id': 3,
        'invoice_id': 103,
        'amount': 3000.0,
        'invoices': {'invoice_number': 'INV-2024-003'},
      };

      // Act
      final payment = Payment.fromJson(jsonWithInvoice);

      // Assert
      expect(payment.invoiceNumber, 'INV-2024-003');
    });

    test('should extract patient name from deeply nested patients object', () {
      // Arrange
      final jsonWithPatient = {
        'id': 4,
        'invoice_id': 104,
        'amount': 1500.0,
        'invoices': {
          'invoice_number': 'INV-2024-004',
          'patients': {'first_name': 'Alice', 'last_name': 'Smith'},
        },
      };

      // Act
      final payment = Payment.fromJson(jsonWithPatient);

      // Assert
      expect(payment.patientName, 'Alice Smith');
    });

    test('should handle patient name with empty strings', () {
      // Arrange
      final jsonWithEmptyNames = {
        'id': 5,
        'invoice_id': 105,
        'amount': 2500.0,
        'invoices': {
          'patients': {'first_name': '', 'last_name': ''},
        },
      };

      // Act
      final payment = Payment.fromJson(jsonWithEmptyNames);

      // Assert
      expect(payment.patientName, isNull);
    });

    test('should serialize Payment to JSON correctly', () {
      // Arrange
      final payment = Payment(
        id: 6,
        invoiceId: 106,
        paymentDate: DateTime.parse('2024-02-01'),
        amount: 5000.0,
        method: 'bank_transfer',
        reference: 'BANK-67890',
        notes: 'Wire transfer completed',
      );

      // Act
      final json = payment.toJson();

      // Assert
      expect(json['id'], 6);
      expect(json['invoice_id'], 106);
      expect(json['payment_date'], '2024-02-01');
      expect(json['amount'], 5000.0);
      expect(json['method'], 'bank_transfer');
      expect(json['reference'], 'BANK-67890');
      expect(json['notes'], 'Wire transfer completed');
    });

    test('should not include id in JSON when null (for new payments)', () {
      // Arrange - New payment without ID
      final newPayment = Payment(
        invoiceId: 999,
        paymentDate: DateTime.parse('2024-03-01'),
        amount: 1000.0,
        method: 'cash',
      );

      // Act
      final json = newPayment.toJson();

      // Assert
      expect(json.containsKey('id'), false);
      expect(json['invoice_id'], 999);
      expect(json['amount'], 1000.0);
    });

    test('should parse numeric amounts as double', () {
      // Arrange
      final jsonWithNumber = {
        'id': 7,
        'invoice_id': 107,
        'amount': 1234, // Integer
      };

      // Act
      final payment = Payment.fromJson(jsonWithNumber);

      // Assert
      expect(payment.amount, 1234.0);
    });

    test('should parse string amounts as double', () {
      // Arrange
      final jsonWithStringAmount = {
        'id': 8,
        'invoice_id': 108,
        'amount': '2500.75', // String
      };

      // Act
      final payment = Payment.fromJson(jsonWithStringAmount);

      // Assert
      expect(payment.amount, 2500.75);
    });

    test('should handle invalid date formats gracefully', () {
      // Arrange
      final jsonWithInvalidDate = {
        'id': 9,
        'invoice_id': 109,
        'payment_date': 'invalid-date',
        'amount': 1000.0,
      };

      // Act
      final payment = Payment.fromJson(jsonWithInvalidDate);

      // Assert
      expect(payment.paymentDate, isNull);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = Payment(
        id: 10,
        invoiceId: 110,
        paymentDate: DateTime.parse('2024-03-15'),
        amount: 3000.0,
        method: 'cash',
      );

      // Act
      final updated = original.copyWith(
        amount: 2800.0,
        method: 'credit_card',
        reference: 'CC-12345',
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.invoiceId, original.invoiceId);
      expect(updated.paymentDate, original.paymentDate);
      expect(updated.amount, 2800.0); // Updated
      expect(updated.method, 'credit_card'); // Updated
      expect(updated.reference, 'CC-12345'); // Updated
    });

    test('should serialize dates to ISO format (date only)', () {
      // Arrange
      final payment = Payment(
        paymentDate: DateTime.parse('2024-04-20T15:30:00Z'),
      );

      // Act
      final json = payment.toJson();

      // Assert
      expect(json['payment_date'], '2024-04-20');
    });

    test('should support equality comparison', () {
      // Arrange
      final payment1 = const Payment(
        id: 1,
        invoiceId: 100,
        amount: 5000.0,
        method: 'cash',
      );

      final payment2 = const Payment(
        id: 1,
        invoiceId: 100,
        amount: 5000.0,
        method: 'cash',
      );

      final payment3 = const Payment(
        id: 2, // Different ID
        invoiceId: 100,
        amount: 5000.0,
        method: 'cash',
      );

      // Act & Assert
      expect(payment1, equals(payment2));
      expect(payment1, isNot(equals(payment3)));
    });

    test('should handle null amount gracefully', () {
      // Arrange
      final jsonWithNullAmount = {'id': 11, 'invoice_id': 111, 'amount': null};

      // Act
      final payment = Payment.fromJson(jsonWithNullAmount);

      // Assert
      expect(payment.amount, isNull);
    });

    test('should handle various payment methods', () {
      // Arrange & Act
      final cashPayment = Payment.fromJson({
        'id': 1,
        'invoice_id': 1,
        'amount': 1000.0,
        'method': 'cash',
      });

      final cardPayment = Payment.fromJson({
        'id': 2,
        'invoice_id': 2,
        'amount': 2000.0,
        'method': 'credit_card',
      });

      final bankPayment = Payment.fromJson({
        'id': 3,
        'invoice_id': 3,
        'amount': 3000.0,
        'method': 'bank_transfer',
      });

      // Assert
      expect(cashPayment.method, 'cash');
      expect(cardPayment.method, 'credit_card');
      expect(bankPayment.method, 'bank_transfer');
    });
  });
}
