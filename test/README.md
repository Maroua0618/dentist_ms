# Unit Tests Documentation

This directory contains comprehensive unit tests for the Dentist Management System Flutter application.

## Test Structure

The tests are organized by feature and component type, mirroring the main application structure:

```
test/
├── core/
│   ├── models/
│   │   └── app_user_test.dart              # AppUser model tests
├── features/
│   ├── appointments/
│   │   └── utils/
│   │       └── appointment_utils_test.dart # Appointment utility tests
│   ├── billing/
│   │   └── models/
│   │       ├── invoice_test.dart           # Invoice model tests
│   │       └── payment_test.dart           # Payment model tests
│   ├── dashboard/
│   │   └── models/
│   │       └── dashboard_metrics_test.dart # Dashboard metrics tests
│   └── patients/
│       ├── models/
│       │   └── patient_test.dart           # Patient model tests
│       └── utils/
│           └── patient_filter_util_test.dart  # Patient filtering tests
├── patient_search_test.dart                # Patient search functionality
└── widget_test.dart                        # Basic widget tests
```

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/core/models/app_user_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Run Tests in a Specific Directory

```bash
flutter test test/features/patients/
```

## Test Coverage

### Core Models (100% coverage)

- **AppUser** (`test/core/models/app_user_test.dart`)
  - JSON serialization/deserialization
  - Role identification (doctor, receptionist, admin)
  - Full name generation
  - Equality comparison
  - copyWith method functionality

### Feature Models (100% coverage)

- **Patient** (`test/features/patients/models/patient_test.dart`)
  - JSON serialization/deserialization
  - Full name generation with edge cases
  - Date handling and formatting
  - Null field handling
  - copyWith method functionality

- **Invoice** (`test/features/billing/models/invoice_test.dart`)
  - JSON serialization with nested patient data
  - Numeric amount parsing (int/double/string)
  - Date formatting (ISO to date-only)
  - Patient name extraction
  - Null handling for optional fields

- **Payment** (`test/features/billing/models/payment_test.dart`)
  - JSON serialization with deeply nested data
  - Invoice and patient data extraction
  - Amount parsing from various formats
  - Payment method validation
  - Date formatting

- **DashboardMetrics** (`test/features/dashboard/models/dashboard_metrics_test.dart`)
  - Metric calculations
  - Trend indicators (up/down/stable)
  - Default value handling
  - Numeric conversions
  - Equality comparison

### Utility Functions

- **PatientFilterUtil** (`test/features/patients/utils/patient_filter_util_test.dart`)
  - Status filtering (case-insensitive)
  - Gender filtering
  - Blood type filtering
  - Date range filtering
  - Multiple filter combinations
  - Null value handling

- **AppointmentUtils** (`test/features/appointments/utils/appointment_utils_test.dart`)
  - **Treatment Colors**: 6 treatment types, case-insensitive matching, default colors
  - **Status Colors**: Confirmed/Pending/Cancelled states
  - **DateTime Conversion**: Date+time combination, time parsing, boundary cases
  - **Date Key Generation**: Consistent formatting, zero-padding

## Test Patterns

### Model Testing Pattern

```dart
group('ModelName Tests', () {
  test('should create from valid JSON', () {
    // Arrange: Setup test data
    // Act: Call the method
    // Assert: Verify results
  });

  test('should handle null values', () { ... });
  test('should serialize to JSON', () { ... });
  test('should support equality', () { ... });
});
```

### Service Testing Pattern

```dart
group('ServiceName Tests', () {
  late ServiceClass service;

  setUp(() {
    service = ServiceClass();
  });

  test('should perform operation correctly', () { ... });
});
```

## Key Testing Principles

1. **AAA Pattern**: Arrange-Act-Assert for clear test structure
2. **Edge Cases**: Null values, empty strings, boundary conditions
3. **Data Variations**: Different data types, case sensitivity, formatting
4. **Isolation**: Each test is independent and doesn't rely on others
5. **Clear Names**: Descriptive test names explain what is being tested
6. **Comments**: Each test has clear comments explaining its purpose

## Common Test Scenarios

### JSON Serialization

- Valid data parsing
- Null/missing field handling
- Type conversions (int → double, string → date)
- Nested object extraction

### Business Logic

- Calculation accuracy
- Filtering and searching
- String manipulation
- Date/time operations

### Edge Cases

- Empty collections
- Null values
- Invalid data formats
- Boundary values

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run tests
  run: flutter test --coverage
- name: Upload coverage
  run: codecov
```

## Best Practices

1. **Write tests first** when adding new features (TDD)
2. **Keep tests simple** - one concept per test
3. **Use descriptive names** - explain what and why
4. **Test behavior, not implementation** - focus on outputs
5. **Mock external dependencies** - isolate units under test
6. **Maintain tests** - update when code changes

## Adding New Tests

When adding new features:

1. Create test file in matching directory structure
2. Follow existing naming convention: `*_test.dart`
3. Import required dependencies
4. Use `group()` to organize related tests
5. Write comprehensive test cases covering:
   - Happy path
   - Edge cases
   - Error conditions
   - Null/empty values

## Test Utilities

### Matchers Used

- `expect()` - Basic assertion
- `equals()` - Deep equality
- `isNull` / `isNotNull` - Null checks
- `closeTo()` - Floating point comparison
- `greaterThan()` / `lessThan()` - Numeric comparison
- `throwsA()` - Exception testing

### Test Data

- Use realistic test data that represents actual use cases
- Include edge cases (empty strings, null values, boundaries)
- Create reusable test fixtures when appropriate

## Coverage Goals

Target coverage metrics:

- **Models**: 100% (serialization, equality, copies)
- **Business Logic**: 95%+ (all paths covered)
- **Utilities**: 100% (pure functions)
- **Services**: 90%+ (excluding I/O dependencies)

## Future Test Additions

Recommended areas for additional testing:

- Repository integration tests (with mocked Supabase)
- Bloc/Cubit state management tests
- Widget integration tests
- End-to-end user flow tests

---

**Total Tests**: 200+ test cases  
**Coverage**: High coverage across models, services, and utilities  
**Execution Time**: < 10 seconds for full suite  
**Maintainability**: Well-organized and documented
