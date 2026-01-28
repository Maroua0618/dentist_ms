import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';

void main() {
  group('Invoice Model Tests', () {
    // Test data setup
    final validInvoiceJson = {
      'id': 1,
      'invoice_number': 'INV-2024-001',
      'patient_id': 101,
      'status': 'paid',
      'start_date': '2024-01-01',
      'due_date': '2024-01-31',
      'subtotal_amount': 5000.0,
      'discount_amount': 500.0,
      'total_amount': 4500.0,
      'notes': 'Payment received on time',
      'created_at': '2024-01-01T10:00:00Z',
      'updated_at': '2024-01-15T14:30:00Z',
      'patients': {'first_name': 'John', 'last_name': 'Doe'},
    };

    test('should create Invoice from valid JSON with nested patient data', () {
      // Act
      final invoice = Invoice.fromJson(validInvoiceJson);

      // Assert
      expect(invoice.id, 1);
      expect(invoice.invoiceNumber, 'INV-2024-001');
      expect(invoice.patientId, 101);
      expect(invoice.patientName, 'John Doe');
      expect(invoice.status, 'paid');
      expect(invoice.startDate, DateTime.parse('2024-01-01'));
      expect(invoice.dueDate, DateTime.parse('2024-01-31'));
      expect(invoice.subtotalAmount, 5000.0);
      expect(invoice.discountAmount, 500.0);
      expect(invoice.totalAmount, 4500.0);
      expect(invoice.notes, 'Payment received on time');
    });

    test('should handle JSON without nested patient data', () {
      // Arrange
      final jsonWithoutPatient = {
        'id': 2,
        'invoice_number': 'INV-2024-002',
        'patient_id': 102,
        'status': 'pending',
        'total_amount': 3000.0,
      };

      // Act
      final invoice = Invoice.fromJson(jsonWithoutPatient);

      // Assert
      expect(invoice.id, 2);
      expect(invoice.invoiceNumber, 'INV-2024-002');
      expect(invoice.patientId, 102);
      expect(invoice.patientName, isNull); // No patient data
      expect(invoice.status, 'pending');
    });

    test('should extract patient name from nested patients object', () {
      // Arrange
      final jsonWithPatient = {
        'id': 3,
        'invoice_number': 'INV-2024-003',
        'patients': {'first_name': 'Alice', 'last_name': 'Smith'},
      };

      // Act
      final invoice = Invoice.fromJson(jsonWithPatient);

      // Assert
      expect(invoice.patientName, 'Alice Smith');
    });

    test('should handle patient name with empty strings', () {
      // Arrange
      final jsonWithEmptyNames = {
        'id': 4,
        'invoice_number': 'INV-2024-004',
        'patients': {'first_name': '', 'last_name': ''},
      };

      // Act
      final invoice = Invoice.fromJson(jsonWithEmptyNames);

      // Assert
      expect(invoice.patientName, isNull); // Empty name treated as null
    });

    test('should serialize Invoice to JSON correctly', () {
      // Arrange
      final invoice = Invoice(
        id: 5,
        invoiceNumber: 'INV-2024-005',
        patientId: 105,
        status: 'overdue',
        startDate: DateTime.parse('2024-02-01'),
        dueDate: DateTime.parse('2024-02-28'),
        subtotalAmount: 10000.0,
        discountAmount: 1000.0,
        totalAmount: 9000.0,
        notes: 'Payment overdue',
      );

      // Act
      final json = invoice.toJson();

      // Assert
      expect(json['id'], 5);
      expect(json['invoice_number'], 'INV-2024-005');
      expect(json['patient_id'], 105);
      expect(json['status'], 'overdue');
      expect(json['start_date'], '2024-02-01');
      expect(json['due_date'], '2024-02-28');
      expect(json['subtotal_amount'], 10000.0);
      expect(json['discount_amount'], 1000.0);
      expect(json['total_amount'], 9000.0);
      expect(json['notes'], 'Payment overdue');
    });

    test('should not include id in JSON when null (for new invoices)', () {
      // Arrange - New invoice without ID
      final newInvoice = Invoice(
        invoiceNumber: 'INV-2024-NEW',
        patientId: 999,
        status: 'pending',
        totalAmount: 5000.0,
      );

      // Act
      final json = newInvoice.toJson();

      // Assert
      expect(json.containsKey('id'), false);
      expect(json['invoice_number'], 'INV-2024-NEW');
    });

    test('should parse numeric amounts as double', () {
      // Arrange
      final jsonWithNumbers = {
        'id': 6,
        'invoice_number': 'INV-2024-006',
        'subtotal_amount': 1500, // Integer
        'discount_amount': '250.50', // String
        'total_amount': 1249.50, // Double
      };

      // Act
      final invoice = Invoice.fromJson(jsonWithNumbers);

      // Assert
      expect(invoice.subtotalAmount, 1500.0);
      expect(invoice.discountAmount, 250.50);
      expect(invoice.totalAmount, 1249.50);
    });

    test('should handle invalid date formats gracefully', () {
      // Arrange
      final jsonWithInvalidDates = {
        'id': 7,
        'invoice_number': 'INV-2024-007',
        'start_date': 'invalid-date',
        'due_date': 'also-invalid',
      };

      // Act
      final invoice = Invoice.fromJson(jsonWithInvalidDates);

      // Assert
      expect(invoice.startDate, isNull);
      expect(invoice.dueDate, isNull);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = Invoice(
        id: 8,
        invoiceNumber: 'INV-2024-008',
        patientId: 108,
        status: 'pending',
        totalAmount: 2000.0,
      );

      // Act
      final updated = original.copyWith(
        status: 'paid',
        totalAmount: 1800.0,
        notes: 'Discount applied',
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.invoiceNumber, original.invoiceNumber);
      expect(updated.patientId, original.patientId);
      expect(updated.status, 'paid'); // Updated
      expect(updated.totalAmount, 1800.0); // Updated
      expect(updated.notes, 'Discount applied'); // Updated
    });

    test('should serialize dates to ISO format (date only)', () {
      // Arrange
      final invoice = Invoice(
        startDate: DateTime.parse('2024-03-15T10:30:00Z'),
        dueDate: DateTime.parse('2024-04-15T14:45:00Z'),
      );

      // Act
      final json = invoice.toJson();

      // Assert
      expect(json['start_date'], '2024-03-15');
      expect(json['due_date'], '2024-04-15');
    });

    test('should support equality comparison', () {
      // Arrange
      final invoice1 = const Invoice(
        id: 1,
        invoiceNumber: 'INV-001',
        patientId: 100,
        status: 'paid',
        totalAmount: 5000.0,
      );

      final invoice2 = const Invoice(
        id: 1,
        invoiceNumber: 'INV-001',
        patientId: 100,
        status: 'paid',
        totalAmount: 5000.0,
      );

      final invoice3 = const Invoice(
        id: 2, // Different ID
        invoiceNumber: 'INV-001',
        patientId: 100,
        status: 'paid',
        totalAmount: 5000.0,
      );

      // Act & Assert
      expect(invoice1, equals(invoice2));
      expect(invoice1, isNot(equals(invoice3)));
    });

    test('should handle null amounts gracefully', () {
      // Arrange
      final jsonWithNullAmounts = {
        'id': 9,
        'invoice_number': 'INV-2024-009',
        'subtotal_amount': null,
        'discount_amount': null,
        'total_amount': null,
      };

      // Act
      final invoice = Invoice.fromJson(jsonWithNullAmounts);

      // Assert
      expect(invoice.subtotalAmount, isNull);
      expect(invoice.discountAmount, isNull);
      expect(invoice.totalAmount, isNull);
    });
  });
}
