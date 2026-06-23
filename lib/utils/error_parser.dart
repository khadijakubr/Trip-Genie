String parseErrorMessage(String error) {
  if (error.contains('email-already-in-use')) {
    return 'Email already in use. Please use a different email or login.';
  } else if (error.contains('wrong-password')) {
    return 'Wrong password. Please try again.';
  } else if (error.contains('user-not-found')) {
    return 'User not found.';
  } else if (error.contains('weak-password')) {
    return 'Password is too weak. Minimum 6 characters.';
  } else if (error.contains('invalid-email')) {
    return 'Invalid email format.';
  } else if (error.contains('network-request-failed')) {
    return 'No internet connection.';
  }
  return 'An error occurred. Please try again.';
}
