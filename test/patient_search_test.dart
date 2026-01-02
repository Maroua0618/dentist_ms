import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';
import 'package:dentist_ms/features/patients/presentation/utils/patient_search.dart';

void main() {
  final patients = [
    const Patient(id: 1, firstName: 'Alice', lastName: 'Smith', email: 'alice@example.com', phone1: '123'),
    const Patient(id: 2, firstName: 'Bob', lastName: 'Jones', email: 'bob@example.com', phone1: '456'),
    const Patient(id: 10, firstName: 'Carlos', lastName: 'Lopez', email: 'carlos@demo.com', phone1: '789'),
  ];

  test('empty query returns all', () {
    final res = filterPatients('', patients);
    expect(res.length, patients.length);
  });

  test('search by first name (case-insensitive)', () {
    final res = filterPatients('alice', patients);
    expect(res.length, 1);
    expect(res.first.id, 1);
  });

  test('search by partial last name', () {
    final res = filterPatients('jon', patients);
    expect(res.length, 1);
    expect(res.first.id, 2);
  });

  test('search by id using p-prefix', () {
    final res = filterPatients('p10', patients);
    expect(res.length, 1);
    expect(res.first.id, 10);
  });

  test('search by email fragment', () {
    final res = filterPatients('example', patients);
    expect(res.length, 2);
  });
}
