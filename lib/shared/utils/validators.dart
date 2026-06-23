// Common validators used across the app. Pure Dart (no Flutter widgets).

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email cannot be empty';
  }
  if (!value.contains('@')) {
    return 'Invalid email format';
  }
  final parts = value.split('@');
  if (parts.length != 2 || parts[1].isEmpty) {
    return 'Invalid email format';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? validateConfirmPassword(String? value, String originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Confirm password cannot be empty';
  }
  if (value != originalPassword) {
    return 'Passwords do not match';
  }
  return null;
}
