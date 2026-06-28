import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/profile_viewmodel.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    // Seed the name controller with the current user data.
    // Must use addPostFrameCallback because we can't modify
    // Controller from initState before the widget tree is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(profileViewmodelProvider).user;
      if (user != null) {
        _nameController.text = user.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final viewmodel = ref.read(profileViewmodelProvider.notifier);

    await viewmodel.saveProfile(name: _nameController.text.trim());

    final currentPw = _currentPasswordController.text;
    final newPw = _newPasswordController.text;
    if (newPw.isNotEmpty) {
      await viewmodel.changePassword(
        currentPassword: currentPw,
        newPassword: newPw,
      );
      if (ref.read(profileViewmodelProvider).errorMessage == null) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(profileViewmodelProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewmodelProvider);

    // Sync the name field when user data changes
    ref.listen<ProfileState>(profileViewmodelProvider, (prev, next) {
      if (prev?.user?.name != next.user?.name && next.user != null && mounted) {
        _nameController.text = next.user!.name;
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header bar ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: 'Gloock',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Avatar + email (outside card) ────
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        _initials(state.user?.name ?? 'T'),
                        style: const TextStyle(
                          fontFamily: 'Gloock',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.user?.email ?? '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppTheme.textLight.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Scrollable cards area ────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ════════════════════════════════════
                        // SINGLE CARD: Personal Info + Password
                        // ════════════════════════════════════
                        Container(
                          width: double.infinity,
                          decoration: AppTheme.formCardDecoration,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Personal Information ──
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontFamily: 'Gloock',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Name (editable, pre-filled)
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outlined),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Name cannot be empty';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name is too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email (read-only)
                              TextFormField(
                                initialValue: state.user?.email ?? '',
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon:
                                      const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: AppTheme.backgroundColor,
                                  suffixIcon: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.lock_outline,
                                      size: 18,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Divider ─────────────
                              Divider(
                                color: AppTheme.secondaryColor
                                    .withValues(alpha: 0.4),
                                thickness: 1,
                              ),
                              const SizedBox(height: 20),

                              // ── Change Password ────
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontFamily: 'Gloock',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Leave empty if you don\'t want to change',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Current Password
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: _obscureCurrent,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureCurrent
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureCurrent =
                                            !_obscureCurrent),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),

                              // New Password
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNew
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureNew = !_obscureNew),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // ── Save button inside card ──
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      state.isSaving ? null : _handleSave,
                                  style: AppTheme.primaryButtonStyle,
                                  child: state.isSaving
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Error / Success messages ──
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              state.errorMessage!,
                              style: AppTheme.errorTextStyle.copyWith(
                                color: Colors.white,
                                backgroundColor: Colors.red.shade700,
                              ),
                            ),
                          ),
                        if (state.successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              state.successMessage!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // ════════════════════════════════════
                        // LOGOUT BUTTON (outside cards)
                        // ════════════════════════════════════
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: state.isSaving ? null : _handleLogout,
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracts initials (up to 2 characters) from a name.
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'T';
  }
}
