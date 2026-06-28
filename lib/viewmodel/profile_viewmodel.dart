import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import '../shared/utils/validators.dart';
import 'auth_viewmodel.dart';

/// State for the profile page: loading, saving, success/error messages,
/// and the current user data.
class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final UserModel? user;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.user,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    UserModel? user,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
      user: user ?? this.user,
    );
  }
}

class ProfileViewmodel extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    return ProfileState(user: user);
  }

  /// Reloads the current user from Firebase and updates state.
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null, clearSuccess: true);
    try {
      final user = await ref.read(authRepositoryProvider).refreshCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Validates and saves the display name to Firebase.
  /// After a successful save the user is refreshed and a success message
  /// is shown.
  Future<void> saveProfile({required String name}) async {
    // ── Client-side validation ──
    if (name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Name cannot be empty');
      return;
    }
    if (name.trim().length < 2) {
      state = state.copyWith(errorMessage: 'Name is too short');
      return;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      clearSuccess: true,
    );

    try {
      await ref.read(authRepositoryProvider).updateDisplayName(name.trim());
      final updated = await ref.read(authRepositoryProvider).refreshCurrentUser();
      state = state.copyWith(
        user: updated,
        isSaving: false,
        successMessage: 'Profile updated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Re-authenticates the user and updates the password.
  /// [currentPassword] is needed for re-authentication.
  /// [newPassword] must be at least 6 characters.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // ── Client-side validation ──
    if (currentPassword.isEmpty) {
      state = state.copyWith(errorMessage: 'Current password is required');
      return;
    }
    final pwError = validatePassword(newPassword);
    if (pwError != null) {
      state = state.copyWith(errorMessage: pwError);
      return;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      clearSuccess: true,
    );

    try {
      // Re-authenticate first (Firebase requirement)
      await ref.read(authRepositoryProvider).reauthenticate(currentPassword);
      await ref.read(authRepositoryProvider).updatePassword(newPassword);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Password changed successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Delegates to [AuthViewModel.logout] and navigates to the auth
  /// screen automatically via the route redirect.
  Future<void> logout() async {
    await ref.read(authViewModelProvider.notifier).logout();
  }

  /// Dismisses the current success / error messages.
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final profileViewmodelProvider =
    NotifierProvider<ProfileViewmodel, ProfileState>(
  ProfileViewmodel.new,
);
