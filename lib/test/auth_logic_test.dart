import 'package:flutter_test/flutter_test.dart';
import 'package:trip_genie/shared/utils/validators.dart';
import 'package:trip_genie/shared/utils/error_parser.dart';

// ============================================================
// UNIT TEST: Trip Genie Authentication Logic
// ============================================================

void main() {
  // ========================================================
  // TEST GROUP 1: Email Validation
  //
  // FUNCTIONALITY SELECTION:
  // - Pure function: no side effects, no external dependencies
  // - Critical user path: email validation is the first gate before
  //   Firebase request, catching invalid input early saves API calls
  // - Easily testable: simple input/output with no async/await
  // ========================================================
  group('Email Validation', () {
    test('Valid email returns null (happy path)', () {
      // ARRANGE: prepare valid input data
      const validEmail = 'user@gmail.com';

      // ACT: invoke the validator function
      final result = validateEmail(validEmail);

      // ASSERT: verify result is null (means no error, valid input)
      expect(result, isNull);
    });

    test('Empty email returns error message (empty input)', () {
      // ARRANGE: prepare empty email to test null-check logic
      const emptyEmail = '';

      // ACT: invoke validator with empty string
      final result = validateEmail(emptyEmail);

      // ASSERT: verify specific error message for empty input
      expect(result, equals('Email cannot be empty'));
    });

    test('Email without @ returns invalid format (missing @ symbol)', () {
      // ARRANGE: simulate user typing email without @ separator
      const invalidEmail = 'userTanpaAT.com';

      // ACT: invoke validator to check for @ symbol
      final result = validateEmail(invalidEmail);

      // ASSERT: verify error message for format validation failure
      expect(result, equals('Invalid email format'));
    });

    test('Email with @ but no domain returns invalid format (edge case)', () {
      // ARRANGE: edge case - user types "user@" without domain part
      // This tests the substring parsing logic after @ symbol
      const emailNoDomain = 'user@';

      // ACT: invoke validator to check domain existence
      final result = validateEmail(emailNoDomain);

      // ASSERT: verify domain-check logic catches incomplete email
      expect(result, equals('Invalid email format'));
    });

    test('Null email returns empty error (null input handling)', () {
      // ARRANGE: simulate uninitialized text field (null state)
      const String? nullEmail = null;

      // ACT: invoke validator with null input
      final result = validateEmail(nullEmail);

      // ASSERT: verify null handling shows "empty" message
      expect(result, equals('Email cannot be empty'));
    });
  });

  // ========================================================
  // TEST GROUP 2: Password Validation
  //
  // FUNCTIONALITY SELECTION:
  // - Pure function: no Firebase dependency, no state mutation
  // - Business-critical: Firebase rejects <6 char passwords, but
  //   client-side validation catches error before network request
  // - Security relevant: length requirement prevents weak passwords
  // ========================================================
  group('Password Validation', () {
    test('Password with 6+ chars returns null (happy path)', () {
      // ARRANGE: prepare valid password meeting minimum requirement
      const validPassword = 'rahasia123';

      // ACT: invoke password validator
      final result = validatePassword(validPassword);

      // ASSERT: null = valid password, no error message
      expect(result, isNull);
    });

    test('Short password returns error (below minimum length)', () {
      // ARRANGE: prepare password below 6-character minimum
      const shortPassword = '123'; // 3 chars - clearly too short

      // ACT: invoke validator to check length constraint
      final result = validatePassword(shortPassword);

      // ASSERT: verify specific error message for length violation
      expect(result, equals('Password must be at least 6 characters'));
    });

    test('Empty password returns error (empty input)', () {
      // ARRANGE: prepare empty password to test null/empty check
      const emptyPassword = '';

      // ACT: invoke validator with empty string
      final result = validatePassword(emptyPassword);

      // ASSERT: verify error message for empty input
      expect(result, equals('Password cannot be empty'));
    });

    test('Boundary 6-character password passes (boundary condition)', () {
      // ARRANGE: prepare password exactly at boundary (6 chars = minimum valid)
      // This tests the boundary: 5 chars should fail, 6 should pass
      const boundaryPassword = 'abc123'; // exactly 6 characters

      // ACT: invoke validator at exact boundary
      final result = validatePassword(boundaryPassword);

      // ASSERT: 6-char password must pass (return null)
      expect(result, isNull);
    });

    test('Password with 5 chars returns error (just below boundary)', () {
      // ARRANGE: prepare password at -1 from boundary (5 chars)
      // Validates that the >= 6 check is correct, not > 6
      const almostValid = 'abc12'; // 5 chars - should fail

      // ACT: invoke validator just below boundary
      final result = validatePassword(almostValid);

      // ASSERT: 5-char password must fail (show error)
      expect(result, equals('Password must be at least 6 characters'));
    });
  });

  // ========================================================
  // TEST GROUP 3: Confirm Password Validation
  //
  // FUNCTIONALITY SELECTION:
  // - Pure function: comparing two strings, no side effects
  // - User-critical: typo in confirm password is extremely common during
  //   registration; catching mismatch prevents user lockout
  // - Deterministic: same input always produces same output
  // ========================================================
  group('Confirm Password Validation', () {
    test('Matching confirm password returns null (happy path)', () {
      // ARRANGE: prepare password and matching confirmation
      const password = 'rahasia123';
      const confirm = 'rahasia123'; // exactly same as password

      // ACT: invoke confirm validator
      final result = validateConfirmPassword(confirm, password);

      // ASSERT: null = passwords match, valid state
      expect(result, isNull);
    });

    test('Non-matching confirm returns error (mismatch detection)', () {
      // ARRANGE: prepare password and intentionally different confirmation
      // Simulates user making typo in confirm field
      const password = 'rahasia123';
      const wrongConfirm = 'salahPassword'; // completely different string

      // ACT: invoke validator to check equality
      final result = validateConfirmPassword(wrongConfirm, password);

      // ASSERT: verify mismatch error message
      expect(result, equals('Passwords do not match'));
    });

    test('Empty confirm returns error (empty input)', () {
      // ARRANGE: prepare password but leave confirm field empty
      // Simulates user submitting form without confirming
      const password = 'rahasia123';
      const emptyConfirm = '';

      // ACT: invoke validator with empty confirm
      final result = validateConfirmPassword(emptyConfirm, password);

      // ASSERT: verify empty input error
      expect(result, equals('Confirm password cannot be empty'));
    });

    test('Case sensitive check (security: Rahasia123 != rahasia123)', () {
      // ARRANGE: prepare password and confirm with different case
      // This is critical for security: 'Pass123' != 'pass123'
      const password = 'rahasia123';
      const wrongCase = 'Rahasia123'; // R is uppercase - different!

      // ACT: invoke validator to verify case sensitivity
      final result = validateConfirmPassword(wrongCase, password);

      // ASSERT: case mismatch must be treated as different password
      expect(result, equals('Passwords do not match'));
    });

    test('Null confirm returns error (null input handling)', () {
      // ARRANGE: simulate uninitialized confirm field (null state)
      const password = 'rahasia123';
      const String? nullConfirm = null;

      // ACT: invoke validator with null confirm
      final result = validateConfirmPassword(nullConfirm, password);

      // ASSERT: verify null handling shows appropriate error
      expect(result, equals('Confirm password cannot be empty'));
    });
  });

  // ========================================================
  // TEST GROUP 4: Parse Firebase Error Message
  //
  // FUNCTIONALITY SELECTION:
  // - Pure function: string parsing, no external calls
  // - UX-critical: Firebase returns cryptic English error codes
  //   (e.g., "email-already-in-use"). Parser converts to user-friendly
  //   messages. Bad parsing = confused users who can't understand errors
  // - Coverage matters: each Firebase error code needs a mapped message
  // ========================================================
  group('Parse Firebase Error Message', () {
    test('email-already-in-use mapped correctly (error mapping)', () {
      // ARRANGE: prepare Firebase error for duplicate email
      // Simulates Firebase Authentication error response
      const firebaseError =
          '[firebase_auth/email-already-in-use] The email address is already in use';

      // ACT: invoke error parser to extract and map to user message
      final result = parseErrorMessage(firebaseError);

      // ASSERT: verify user-friendly message shown to end user
      expect(result,
          equals('Email already in use. Please use a different email or login.'));
    });

    test('wrong-password mapped correctly (login failure)', () {
      // ARRANGE: prepare Firebase error for incorrect password
      // Common case during login when user enters wrong password
      const firebaseError =
          '[firebase_auth/wrong-password] The password is invalid';

      // ACT: invoke parser to convert technical error to friendly message
      final result = parseErrorMessage(firebaseError);

      // ASSERT: verify appropriate guidance message
      expect(result, equals('Wrong password. Please try again.'));
    });

    test('user-not-found mapped correctly (email lookup)', () {
      // ARRANGE: prepare Firebase error for unregistered email
      // Happens when login email doesn't exist in database
      const firebaseError =
          '[firebase_auth/user-not-found] There is no user record';

      // ACT: invoke parser
      final result = parseErrorMessage(firebaseError);

      // ASSERT: verify user gets clear "not found" message
      expect(result, equals('User not found.'));
    });

    test('weak-password mapped correctly (security requirement)', () {
      // ARRANGE: prepare Firebase error for password too weak
      // Firebase has minimum security standards
      const firebaseError =
          '[firebase_auth/weak-password] The password must be 6 characters';

      // ACT: invoke parser to extract error details
      final result = parseErrorMessage(firebaseError);

      // ASSERT: verify minimum requirement message
      expect(result, equals('Password is too weak. Minimum 6 characters.'));
    });

    test('invalid-email mapped correctly (format validation)', () {
      // ARRANGE: prepare Firebase error for malformed email
      // Firebase validates email format on server side too
      const firebaseError =
          '[firebase_auth/invalid-email] The email address is badly formatted';

      // ACT: invoke parser
      final result = parseErrorMessage(firebaseError);

      // ASSERT: verify format error message
      expect(result, equals('Invalid email format.'));
    });

    test('network-request-failed mapped correctly (connectivity)', () {
      // ARRANGE: prepare Firebase error for network failure
      // Critical for UX: user needs to know it's connection, not validation
      const networkError =
          '[firebase_auth/network-request-failed] A network error occurred';

      // ACT: invoke parser to identify network issue
      final result = parseErrorMessage(networkError);

      // ASSERT: verify helpful network-specific message
      expect(result, equals('No internet connection.'));
    });

    test('unknown error returns fallback (graceful degradation)', () {
      // ARRANGE: prepare unknown Firebase error code
      // IMPORTANT: Firebase might add new error codes in future.
      // Parser must handle unknown codes gracefully, not crash.
      const unknownError =
          '[firebase_auth/unknown-error] Something went wrong';

      // ACT: invoke parser with unmapped error
      final result = parseErrorMessage(unknownError);

      // ASSERT: verify generic fallback message (not null, not crash)
      // This ensures user sees SOME message even if error is unknown
      expect(result, equals('An error occurred. Please try again.'));
    });
  });
}

