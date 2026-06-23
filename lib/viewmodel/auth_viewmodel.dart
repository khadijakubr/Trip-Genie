import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import 'package:trip_genie/shared/utils/error_parser.dart';

// State untuk AuthViewModel

class AuthState {
  final UserModel? user;       // data user yang login
  final bool isLoading;        // true saat proses login/register berlangsung
  final String? errorMessage;  // pesan error kalau ada

  // Constructor dengan nilai default
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  // copyWith, update state tanpa mengubah field yang lain
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      // ?? artinya: kalau parameter baru tidak diisi, pakai nilai lama
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Pakai Notifier karena mengelola state AuthState sendiri secara manual
class AuthViewModel extends Notifier<AuthState> {

  @override
  AuthState build() {
    // Load user yang sedang login saat pertama kali provider diakses
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    return AuthState(user: user);
  }

  // REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Update state: mulai loading, hapus error sebelumnya
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await ref.read(authRepositoryProvider).register(
        name: name,
        email: email,
        password: password,
      );
      // Berhasil: simpan user, matikan loading
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      // Gagal: matikan loading, simpan pesan error
      state = state.copyWith(
        isLoading: false,
        errorMessage: parseErrorMessage(e.toString()),
      );
    }
  }

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await ref.read(authRepositoryProvider).login(
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: parseErrorMessage(e.toString()),
      );
    }
  }

  // LOGOUT
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await ref.read(authRepositoryProvider).logout();
    // Setelah logout, reset state ke kondisi awal (tidak ada user)
    state = const AuthState();
  }

  // Error parsing delegated to lib/utils/error_parser.dart
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);