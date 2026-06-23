import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';

class ProfileRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET PROFILE USER YANG SEDANG LOGIN
  // Data diambil dari Firebase, bukan SQLite
  UserModel? getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Traveler',
      email: user.email ?? '',
    );
  }

  // UPDATE NAMA USER
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User tidak ditemukan');

    // updateDisplayName mengubah nama yang tersimpan di Firebase
    await user.updateDisplayName(newName);
    
    // Reload agar perubahan langsung terefleksi
    await user.reload();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});