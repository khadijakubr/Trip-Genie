import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodel/auth_viewmodel.dart';
import 'package:trip_genie/shared/utils/validators.dart';
import '../../../shared/routes/app_routes.dart';
import '../../../shared/theme/app_theme.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authViewModelProvider.notifier).register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final authState = ref.read(authViewModelProvider);
    if (authState.user != null && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Field Nama
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name cannot be empty';
              }
              if (value.length < 2) {
                return 'Full name is too short';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

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
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: validatePassword,
          ),

          const SizedBox(height: 16),

          // Field Konfirmasi Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) => validateConfirmPassword(value, _passwordController.text),
          ),

          const SizedBox(height: 8),

          // Tampilkan error dari Firebase
          if (authState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                authState.errorMessage!,
                style: AppTheme.errorTextStyle,
              ),
            ),

          const SizedBox(height: 16),

          // Tombol Register
          ElevatedButton(
            onPressed: authState.isLoading ? null : _handleRegister,
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Register'),
          ),
        ],
      ),
    );
  }
}