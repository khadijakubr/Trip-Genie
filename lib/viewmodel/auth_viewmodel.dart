import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/user.dart';

/// State: User (authenticated user data)
/// Methods: login(), register(), logout()
class AuthViewmodel extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // TODO: Implement initial auth state check
    return null;
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement login logic
      throw UnimplementedError('login() not implemented');
    });
  }

  /// Register new user with email and password
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement register logic
      throw UnimplementedError('register() not implemented');
    });
  }

  /// Logout current user
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement logout logic
      return null;
    });
  }
}

final authViewmodelProvider = AsyncNotifierProvider<AuthViewmodel, UserModel?>(() {
  return AuthViewmodel();
});
