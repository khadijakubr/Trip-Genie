import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import '../shared/constants/app_preferences.dart';

class AuthRepository {

  // Mengambil instance FirebaseAuth yang sudah ada (singleton dari Firebase)
  // Tidak perlu dibuat baru setiap kali karena Firebase mengelolanya sendiri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  // REGISTER dengan email dan password
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // createUserWithEmailAndPassword 
    // Melempar exception kalau email sudah terdaftar atau password lemah
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Setelah akun dibuat, update nama display user
    // currentUser adalah user yang baru saja login/register
    await credential.user!.updateDisplayName(name);
    
    // Reload agar perubahan nama langsung terefleksi
    await credential.user!.reload();

    // Ambil data user terbaru setelah reload
    final updatedUser = _auth.currentUser!;

    // Simpan status login ke SharedPreferences
    await AppPreferences.setLoggedIn(true);

    // Konversi dari tipe User milik Firebase ke UserModel milik kita
    return UserModel(
      id: updatedUser.uid,
      name: updatedUser.displayName ?? name,
      email: updatedUser.email ?? email,
    );
  }

  // LOGIN dengan email dan password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // signInWithEmailAndPassword 
    // Melempar exception kalau email tidak ditemukan atau password salah
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    
    // Simpan status login
    await AppPreferences.setLoggedIn(true);

    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Traveler',
      email: user.email ?? email,
    );
  }

  // GET USER YANG SEDANG LOGIN
  UserModel? getCurrentUser() {
    // currentUser mengembalikan user yang sedang login
    // atau null kalau tidak ada yang login
    final user = _auth.currentUser;
    
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Traveler',
      email: user.email ?? '',
    );
  }

  /// Updates the display name of the currently logged-in user.
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser!.updateDisplayName(name);
    await _auth.currentUser!.reload();
  }

  /// Re-authenticates the user with their current email + password.
  /// Required by Firebase before [updatePassword] if the last login
  /// was too long ago.
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Updates the password for the currently logged-in user.
  /// Call [reauthenticate] first if needed.
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser!.updatePassword(newPassword);
  }

  /// Reloads the current user and returns a fresh [UserModel].
  Future<UserModel> refreshCurrentUser() async {
    await _auth.currentUser!.reload();
    final user = _auth.currentUser!;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Traveler',
      email: user.email ?? '',
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    await AppPreferences.clearAll();
  }

  bool get isLoggedIn => _auth.currentUser != null;
}

// Provider untuk AuthRepository
// Pakai Provider biasa karena AuthRepository hanya menyediakan fungsi-fungsi yang bisa dipanggil
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});