import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodel/auth_viewmodel.dart';
import 'package:trip_genie/utils/validators.dart';
import '../../../shared/routes/app_routes.dart';
import '../../../shared/theme/app_theme.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {

  // Controller untuk mengambil nilai dari text field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // GlobalKey untuk mengakses dan memvalidasi form
  final _formKey = GlobalKey<FormState>();
  
  // Untuk toggle show/hide password
  bool _obscurePassword = true;

  // dispose dipanggil saat widget dihapus dari layar
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validasi form dulu sebelum proses login
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authViewModelProvider.notifier).login(
      email: _emailController.text.trim(), // trim() menghapus spasi di awal dan akhir teks
      password: _passwordController.text,
    );

    // Cek apakah login berhasil dengan melihat state terbaru
    final authState = ref.read(authViewModelProvider);
    if (authState.user != null && mounted) {
      // mounted berarti widget masih ada di layar
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch untuk pantau perubahan state
    final authState = ref.watch(authViewModelProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Field Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: validateEmail,
          ),

          const SizedBox(height: 16),

          // Field Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,  // true = password disembunyikan
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  // setState di StatefulWidget untuk update UI lokal
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: validatePassword,
          ),

          const SizedBox(height: 8),

          // Tampilkan pesan error dari Firebase jika ada
          if (authState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                authState.errorMessage!,
                style: AppTheme.errorTextStyle,
              ),
            ),

          const SizedBox(height: 16),

          // Tombol Login
          ElevatedButton(
            // Disable tombol saat loading agar tidak bisa diklik berkali-kali
            onPressed: authState.isLoading ? null : _handleLogin,
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Login'),
          ),
        ],
      ),
    );
  }
}