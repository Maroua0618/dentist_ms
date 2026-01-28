import 'package:integration_test/integration_test_driver.dart';

/// Integration Test Driver
///
/// This file is the entry point for running integration tests.
/// It sets up the test environment and handles test execution.
///
/// Usage:
/// flutter drive \
///   --driver=integration_test/driver.dart \
///   --target=integration_test/auth_flow_test.dart

Future<void> main() => integrationDriver();
