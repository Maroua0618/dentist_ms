# 🚀 Integration Tests - Quick Start Guide

## ⚡ Run Tests (3 Simple Steps)

### 1️⃣ Install Dependencies

```bash
flutter pub get
```

### 2️⃣ Run All Integration Tests

```bash
flutter test integration_test/
```

### 3️⃣ View Results

Check the console output for test results! ✅

---

## 📝 Common Commands

### Run Specific Tests

```bash
# Authentication tests
flutter test integration_test/auth_flow_test.dart

# Patient management
flutter test integration_test/patient_crud_flow_test.dart

# Appointments
flutter test integration_test/appointment_flow_test.dart

# Billing
flutter test integration_test/billing_flow_test.dart

# Navigation
flutter test integration_test/navigation_flow_test.dart
```

### Run with Options

```bash
# Verbose output
flutter test integration_test/ --verbose

# Generate coverage
flutter test integration_test/ --coverage

# Run specific test
flutter test integration_test/auth_flow_test.dart --name "login flow"
```

---

## 🎯 What Gets Tested

| Feature            | Tests                              |
| ------------------ | ---------------------------------- |
| **Authentication** | Login, Logout, Validation, Tabs    |
| **Patients**       | Add, View, Edit, Delete, Search    |
| **Appointments**   | Schedule, Calendar, Status, Filter |
| **Billing**        | Create Invoice, Payments, Reports  |
| **Navigation**     | All screens, Routing, State        |

**Total: 39 integration test cases**

---

## 🔑 Test Credentials

Default test credentials (configure in `.env`):

- **Email:** `test@dentalcare.com`
- **Password:** `TestPassword123`

⚠️ **Make sure these exist in your test database!**

---

## 🐛 Quick Troubleshooting

| Problem          | Solution                            |
| ---------------- | ----------------------------------- |
| Tests timeout    | Add `await tester.pumpAndSettle()`  |
| Widget not found | Check widget keys, wait for loading |
| Auth fails       | Verify credentials in `.env`        |
| Flaky tests      | Add more wait times                 |

---

## 📊 Test Structure

```
integration_test/
├── helpers/              # Test utilities
├── auth_flow_test.dart          # 7 tests
├── patient_crud_flow_test.dart  # 5 tests
├── appointment_flow_test.dart   # 8 tests
├── billing_flow_test.dart       # 9 tests
└── navigation_flow_test.dart    # 10 tests
```

---

## 💡 Tips

- ✅ Run tests before committing code
- ✅ Keep tests updated with UI changes
- ✅ Add tests for new features
- ✅ Clean up test data after runs

---

## 📚 Full Documentation

For detailed information, see [README.md](README.md)

---

**Need Help?** Check the full README or troubleshooting section!

🎉 **Happy Testing!**
