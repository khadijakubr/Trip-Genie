import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';
import '../widgets/auth_widgets/login_form.dart';
import '../widgets/auth_widgets/register_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

// Pakai StatefulWidget biasa (bukan Consumer) karena
// halaman ini hanya perlu menyimpan state tab mana yang aktif tidak perlu akses Riverpod di level halaman ini
class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // TabController untuk mengontrol perpindahan tab Login/Register
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // length: 2 karena ada 2 tab (Login dan Register)
    // vsync: this — dibutuhkan untuk animasi tab, makanya pakai SingleTickerProviderStateMixin
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
            children: [
              // ── Branding section ──────────────
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top > 0 ? 32 : 48,
                  bottom: 4,
                ),
                child: Column(
                  children: [
                    Text(
                      'Trip Genie',
                      style: TextStyle(
                        fontFamily: 'Gloock',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your AI Travel Buddy',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textLight.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ── White card with forms ─────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Tab bar untuk pilih Login atau Register
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: AppTheme.textSecondary,
                        indicatorColor: AppTheme.primaryColor,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Register'),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Konten tab — berisi form sesuai tab yang dipilih
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            // Tab 1: Login Form
                            SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
                              child: LoginForm(),
                            ),
                            // Tab 2: Register Form
                            SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
                              child: RegisterForm(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
