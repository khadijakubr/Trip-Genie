import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 32),

              // Logo atau judul aplikasi
              const Text(
                'Trip Genie',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Your AI Travel Buddy',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Tab bar untuk pilih Login atau Register
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Login'),
                  Tab(text: 'Register'),
                ],
              ),

              const SizedBox(height: 24),

              // Konten tab — berisi form sesuai tab yang dipilih
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    // Tab 1: Login Form
                    SingleChildScrollView(child: LoginForm()),
                    // Tab 2: Register Form
                    // SingleChildScrollView agar bisa scroll kalau keyboard muncul
                    SingleChildScrollView(child: RegisterForm()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 