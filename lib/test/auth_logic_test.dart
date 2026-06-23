import 'package:flutter_test/flutter_test.dart';
import 'package:trip_genie/utils/validators.dart';
import 'package:trip_genie/utils/error_parser.dart';

// Unit tests for authentication-related pure logic.

void main() {
  group('Email Validation', () {
    test('Valid email returns null', () {
      const validEmail = 'user@gmail.com';
      final result = validateEmail(validEmail);
      expect(result, isNull);
    });

    test('Empty email returns error message', () {
      const emptyEmail = '';
      final result = validateEmail(emptyEmail);
      expect(result, equals('Email cannot be empty'));
    });

    test('Email without @ returns invalid format', () {
      const invalidEmail = 'userTanpaAT.com';
      final result = validateEmail(invalidEmail);
      expect(result, equals('Invalid email format'));
    });

    test('Email with @ but no domain returns invalid format', () {
      const emailNoDomain = 'user@';
      final result = validateEmail(emailNoDomain);
      expect(result, equals('Invalid email format'));
    });

    test('Null email returns empty error', () {
      const String? nullEmail = null;
      final result = validateEmail(nullEmail);
      expect(result, equals('Email cannot be empty'));
    });
  });

  group('Password Validation', () {
    test('Password with 6+ chars returns null', () {
      const validPassword = 'rahasia123';
      final result = validatePassword(validPassword);
      expect(result, isNull);
    });

    test('Short password returns error', () {
      const shortPassword = '123';
      final result = validatePassword(shortPassword);
      expect(result, equals('Password must be at least 6 characters'));
    });

    test('Empty password returns error', () {
      const emptyPassword = '';
      final result = validatePassword(emptyPassword);
      expect(result, equals('Password cannot be empty'));
    });

    test('Boundary 6-character password passes', () {
      const boundaryPassword = 'abc123';
      final result = validatePassword(boundaryPassword);
      expect(result, isNull);
    });
  });

  group('Confirm Password Validation', () {
    test('Matching confirm password returns null', () {
      const password = 'rahasia123';
      const confirm = 'rahasia123';
      final result = validateConfirmPassword(confirm, password);
      expect(result, isNull);
    });

    test('Non-matching confirm returns error', () {
      const password = 'rahasia123';
      const wrongConfirm = 'salahPassword';
      final result = validateConfirmPassword(wrongConfirm, password);
      expect(result, equals('Passwords do not match'));
    });

    test('Empty confirm returns error', () {
      const password = 'rahasia123';
      const emptyConfirm = '';
      final result = validateConfirmPassword(emptyConfirm, password);
      expect(result, equals('Confirm password cannot be empty'));
    });

    test('Case sensitive check', () {
      const password = 'rahasia123';
      const wrongCase = 'Rahasia123';
      final result = validateConfirmPassword(wrongCase, password);
      expect(result, equals('Passwords do not match'));
    });
  });

  group('Parse Firebase Error Message', () {
    test('email-already-in-use mapped correctly', () {
      const firebaseError =
          '[firebase_auth/email-already-in-use] The email address is already in use';
      final result = parseErrorMessage(firebaseError);
      expect(result, equals('Email already in use. Please use a different email or login.'));
    });

    test('wrong-password mapped correctly', () {
      const firebaseError = '[firebase_auth/wrong-password] The password is invalid';
      final result = parseErrorMessage(firebaseError);
      expect(result, equals('Wrong password. Please try again.'));
    });

    test('user-not-found mapped correctly', () {
      const firebaseError = '[firebase_auth/user-not-found] There is no user record';
      final result = parseErrorMessage(firebaseError);
      expect(result, equals('User not found.'));
    });

    test('unknown error returns fallback', () {
      const unknownError = '[firebase_auth/unknown-error] Something went wrong';
      final result = parseErrorMessage(unknownError);
      expect(result, equals('An error occurred. Please try again.'));
    });

    test('network-request-failed mapped correctly', () {
      const networkError = '[firebase_auth/network-request-failed] A network error occurred';
      final result = parseErrorMessage(networkError);
      expect(result, equals('No internet connection.'));
    });
  });
}
