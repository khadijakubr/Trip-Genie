import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/user.dart';

/// State: User profile data
/// Methods: fetchProfile(), updateProfile(), changePassword()
class ProfileViewmodel extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // TODO: Implement initial fetch of user profile
    return null;
  }

  /// Fetch user profile data
  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement fetch profile logic
      throw UnimplementedError('fetchProfile() not implemented');
    });
  }

  /// Update user profile information
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement update profile logic
      throw UnimplementedError('updateProfile() not implemented');
    });
  }

  /// Change user password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement change password logic
      throw UnimplementedError('changePassword() not implemented');
    });
  }
}

final profileViewmodelProvider =
    AsyncNotifierProvider<ProfileViewmodel, UserModel?>(() {
  return ProfileViewmodel();
});
