## Trip Genie
> AI-powered travel itinerary generator untuk traveler yang sibuk.

Trip Genie adalah aplikasi mobile berbasis Flutter yang membantu pengguna membuat rencana perjalanan (itinerary) secara otomatis menggunakan kecerdasan buatan. Pengguna cukup memasukkan destinasi, rentang waktu, dan budget — Trip Genie akan menghasilkan itinerary lengkap dalam hitungan detik.

---

## Arsitektur: MVVM (Model-View-ViewModel)

Project ini menggunakan pola arsitektur **MVVM** untuk memisahkan tanggung jawab setiap komponen secara jelas.

### Komponen MVVM

**Model**
Merepresentasikan struktur data dan logika bisnis aplikasi. Dalam project ini, Model terdiri dari data class seperti `Itinerary`, `DayPlan`, dan `Activity` yang merepresentasikan entitas utama aplikasi. Model tidak mengetahui apapun tentang tampilan UI.
- Lokasi: `lib/model/`

**View**
Bertanggung jawab penuh terhadap tampilan UI dan interaksi pengguna. View hanya menampilkan data yang diberikan oleh ViewModel dan meneruskan aksi pengguna (seperti tap tombol) ke ViewModel — tidak ada logika bisnis di sini.
- Lokasi: `lib/view/pages/` dan `lib/view/widgets/`
- Halaman: `auth_page`, `home_page`, `generate_itinerary_page`, `detail_itinerary_page`, `history_page`, `profile_page`, `welcome_page`

**ViewModel**
Menjadi jembatan antara View dan data. ViewModel menerima perintah dari View, memanggil Repository untuk mengambil atau menyimpan data, dan mengembalikan state terbaru ke View menggunakan **Riverpod** sebagai state management. View tidak perlu tahu dari mana data berasal — cukup mengobservasi state dari ViewModel.
- Lokasi: `lib/viewmodel/`
- File: `auth_viewmodel`, `home_viewmodel`, `generate_itinerary_viewmodel`, `detail_itinerary_viewmodel`, `history_viewmodel`, `profile_viewmodel`

**Repository**
Lapisan abstraksi antara ViewModel dan sumber data. Repository menentukan dari mana data diambil — apakah dari Gemini API, Firebase Authentication, atau SQLite lokal — tanpa ViewModel perlu mengetahui detailnya.
- Lokasi: `lib/repository/`
- File: `auth_repository`, `home_repository`, `generate_itinerary_repository`, `detail_itinerary_repository`, `history_repository`, `profile_repository`

File ini masih belum final dan nantinya bisa berubah - ubah sesuai perkembangan dan kebutuhan app nya

---

## 🧪 Testing

### Filosofi Testing

Project ini menerapkan unit testing untuk logika autentikasi menggunakan pola **Arrange-Act-Assert (AAA)**:
- **Arrange**: Siapkan data input untuk test
- **Act**: Jalankan fungsi yang diuji
- **Assert**: Verifikasi hasil sesuai ekspektasi

### Fungsi yang Diuji

Dipilih fungsi-fungsi **murni** (pure functions) yang:
1. Tidak memiliki efek samping atau ketergantungan eksternal (Firebase, database, widget)
2. Kritis untuk pengalaman pengguna (kesalahan validasi membuat user frustasi)
3. Mudah diisolasi dan diuji tanpa setup kompleks

### Test Case yang Tersedia

#### 1. **Validasi Email** (5 test cases)
Menguji fungsi `validateEmail()` yang memvalidasi format email pengguna.

**Mengapa diuji?**
- Email adalah gerbang pertama sebelum permintaan ke Firebase
- Menangkap input tidak valid lebih awal menghemat panggilan API
- Mencegah user frustasi dengan pesan error Firebase yang membingungkan

**Test yang dilakukan:**
- ✅ Email valid dengan format benar mengembalikan `null` (valid)
- ❌ Email kosong menampilkan pesan error spesifik
- ❌ Email tanpa simbol `@` ditolak
- ❌ Email dengan `@` tapi tanpa domain ditolak (edge case)
- ❌ Email `null` (field belum diisi) ditangani dengan error

#### 2. **Validasi Password** (5 test cases)
Menguji fungsi `validatePassword()` yang memastikan password memenuhi persyaratan minimum.

**Mengapa diuji?**
- Firebase menolak password < 6 karakter, tetapi validasi sisi-klien mencegah permintaan yang tidak perlu
- Persyaratan panjang melindungi keamanan akun pengguna
- Boundary testing penting untuk memastikan logika perbandingan benar (`>= 6` bukan `> 6`)

**Test yang dilakukan:**
- ✅ Password ≥ 6 karakter mengembalikan `null` (valid)
- ❌ Password < 6 karakter ditolak dengan pesan error
- ❌ Password kosong ditolak
- ✅ Password tepat 6 karakter (boundary condition) lolos
- ❌ Password 5 karakter (just below boundary) ditolak

#### 3. **Validasi Konfirmasi Password** (5 test cases)
Menguji fungsi `validateConfirmPassword()` yang memastikan konfirmasi password cocok dengan password asli.

**Mengapa diuji?**
- Kesalahan ketik pada konfirmasi password sangat umum saat registrasi
- Mendeteksi mismatch mencegah user terkunci akun (password tidak sesuai dengan apa yang user harapkan)
- Kepekaan terhadap huruf kapital penting untuk keamanan

**Test yang dilakukan:**
- ✅ Konfirmasi password yang cocok mengembalikan `null` (valid)
- ❌ Konfirmasi password berbeda dari asli ditolak
- ❌ Konfirmasi password kosong ditolak
- ❌ Perbedaan huruf kapital dianggap berbeda (`Pass123` ≠ `pass123`)
- ❌ Nilai `null` pada konfirmasi ditangani dengan error

#### 4. **Parsing Pesan Error Firebase** (8 test cases)
Menguji fungsi `parseErrorMessage()` yang mengubah kode error teknis Firebase menjadi pesan ramah untuk pengguna.

**Mengapa diuji?**
- Firebase mengembalikan kode error teknis dalam bahasa Inggris (contoh: `email-already-in-use`)
- Parsing yang salah membuat pengguna bingung dan tidak tahu apa yang harus dilakukan
- Setiap error code Firebase harus dipetakan ke pesan yang sesuai dalam bahasa Indonesia

**Test yang dilakukan:**
- Email sudah terdaftar → "Email already in use. Please use a different email or login."
- Password salah → "Wrong password. Please try again."
- Email tidak ditemukan → "User not found."
- Password terlalu lemah → "Password is too weak. Minimum 6 characters."
- Format email salah → "Invalid email format."
- Tidak ada koneksi internet → "No internet connection."
- Error tidak dikenal → Fallback message "An error occurred. Please try again." (graceful degradation)

### Menjalankan Test

```bash
# Jalankan semua test autentikasi
flutter test lib/test/auth_logic_test.dart

# Jalankan test spesifik (contoh: Email Validation)
flutter test lib/test/auth_logic_test.dart -k "Email Validation"

# Jalankan dengan verbose output
flutter test lib/test/auth_logic_test.dart -v
```

### Struktur File Test

```
lib/test/
├── auth_logic_test.dart          # Test logika autentikasi
└── database_test.dart            # Test database operations (manual)

lib/shared/utils/
├── validators.dart               # Pure functions: validateEmail, validatePassword, validateConfirmPassword
└── error_parser.dart             # Pure function: parseErrorMessage
```

---

## ⚙️ Cara Menjalankan Project

### Prerequisites
Pastikan sudah terinstall:
- Flutter SDK (versi 3.x ke atas)
- Dart SDK
- Android Studio atau VS Code
- Git
- Node.js
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

### Langkah-langkah

**1. Clone Repository**
```bash
git clone https://github.com/username/trip-genie.git
cd trip-genie
```

**2. Install Dependencies**
```bash
flutter pub get
```

**3. Buat File .env**

Buat file `.env` di root project (sejajar dengan `pubspec.yaml`):
GEMINI_API_KEY=isi_dengan_api_key_gemini_kamu
Cara mendapatkan Gemini API key:
1. Buka https://aistudio.google.com
2. Klik **Get API Key** → **Create API Key**
3. Copy dan paste ke file `.env`

**4. Setup Firebase**

File konfigurasi Firebase tidak disertakan di repository ini karena alasan keamanan. Ikuti langkah berikut untuk membuat konfigurasi:

*4a. Buat Firebase Project*
1. Buka https://console.firebase.google.com
2. Klik **Add Project** → masukkan nama project
3. Matikan Google Analytics → **Create Project**

*4b. Aktifkan Authentication*
1. Di Firebase Console → **Authentication** → **Get Started**
2. Di tab **Sign-in method**, aktifkan **Email/Password**
3. Aktifkan **Google Sign-In** → masukkan project support email → Save

*4c. Login Firebase CLI*
```bash
firebase login
```

*4d. Generate Konfigurasi Firebase*

Jalankan perintah ini di dalam folder project:
```bash
flutterfire configure
```
Pilih project Firebase yang baru dibuat. Perintah ini akan otomatis membuat:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**5. Jalankan Aplikasi**
```bash
flutter run
```

---

## 💭 Refleksi

Pengerjaan Fase 1 ini memberikan banyak pelajaran baru, terutama dalam hal konfigurasi Firebase yang baru pertama kali saya lakukan. Proses menghubungkan Firebase ke Flutter menggunakan FlutterFire CLI ternyata tidak sesederhana yang dibayangkan hingga memahami alasan mengapa beberapa file konfigurasi aman untuk di-commit dan beberapa tidak. Tantangan terbesar yang dihadapi adalah ketika secara tidak sengaja meng-push API key Firebase ke repository publik, sehingga repository harus dibuat ulang dari awal untuk memastikan keamanan kredensial. Dari kejadian ini, ada pelajaran penting yang dipetik: selalu setup `.gitignore` dengan benar sebelum melakukan commit pertama, dan selalu verifikasi file apa saja yang akan ikut ter-push sebelum menjalankan `git push`. Ke depannya, pemahaman tentang keamanan kredensial ini akan menjadi kebiasaan yang diterapkan di setiap project.
