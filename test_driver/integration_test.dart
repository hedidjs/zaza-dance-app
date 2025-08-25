import 'package:integration_test/integration_test_driver.dart';

/// Test driver for running integration tests
/// 
/// This file serves as the entry point for running integration tests
/// in CI/CD pipelines and during development.
/// 
/// Usage:
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
Future<void> main() => integrationDriver();