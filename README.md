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

Project ini menerapkan dua jenis testing:

1. **Unit Testing** — menguji fungsi-fungsi murni (pure functions) seperti validasi form dan parsing error. Test ini cepat, tidak memerlukan widget tree, dan hanya menguji logika bisnis.
2. **Widget Testing** — menguji widget Flutter secara terisolasi dengan dummy data. Test ini memverifikasi rendering UI, teks yang tampil, dan struktur widget.

Kedua jenis test menggunakan pola **Arrange-Act-Assert (AAA)**:
- **Arrange**: Siapkan data input / mock data untuk test
- **Act**: Jalankan fungsi atau render widget yang diuji
- **Assert**: Verifikasi hasil sesuai ekspektasi

---

### A. Unit Test — Logika Autentikasi

#### Fungsi yang Diuji

Dipilih fungsi-fungsi **murni** (pure functions) yang:
1. Tidak memiliki efek samping atau ketergantungan eksternal (Firebase, database, widget)
2. Kritis untuk pengalaman pengguna (kesalahan validasi membuat user frustasi)
3. Mudah diisolasi dan diuji tanpa setup kompleks

#### Test Case yang Tersedia

##### 1. **Validasi Email** (5 test cases)
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

##### 2. **Validasi Password** (5 test cases)
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

##### 3. **Validasi Konfirmasi Password** (5 test cases)
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

##### 4. **Parsing Pesan Error Firebase** (8 test cases)
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

---

### B. Widget Test — DayPlanCard

Widget test untuk `DayPlanCard`, yaitu komponen card yang menampilkan itinerary harian (nomor hari, tema, dan daftar aktivitas). Test ini menggunakan **Flutter Test Framework** (`flutter_test`) untuk merender widget secara virtual dan memverifikasi UI yang tampil.

#### Test Case Structure — Arrange-Act-Assert Pattern (30%)

Setiap test case mengikuti pola AAA secara eksplisit:

```dart
testWidgets('renders all activities with time, name, description, cost',
    (tester) async {
  // ── Arrange ──
  // Data sudah disiapkan di setUp(): dayPlan dengan 2 activities,
  // currencyFormat dengan locale id_ID

  // ── Act ──
  await pumpDayPlanCard(tester);  // merender widget

  // ── Assert ──
  expect(find.text('08.00 - 10.00'), findsOneWidget);
  expect(find.text('Visit Borobudur'), findsOneWidget);
  expect(find.text('Rp 50.000'), findsOneWidget);
  // ... assertions untuk activity ke-2
});
```

**Penjelasan:**
- **Arrange**: Dilakukan di `setUp()` — inisialisasi `DayPlan`, `Activity`, dan `NumberFormat` dengan locale `id_ID`. Ada juga *helper method* `pumpDayPlanCard()` yang membungkus widget dalam `MaterialApp` + `Scaffold` agar tema dan style ter-resolve dengan benar.
- **Act**: Memanggil `pumpDayPlanCard(tester)` yang menjalankan `tester.pumpWidget(...)` untuk merender `DayPlanCard` ke dalam widget tree.
- **Assert**: Menggunakan `find.text()` dari `flutter_test` untuk mencari teks yang diharapkan dan `findsOneWidget` / `findsNothing` untuk memverifikasi keberadaan atau ketidakhadiran widget.

##### Test Coverage 

4 test case mencakup skenario berikut:

| Test Case | Skenario | Apa yang Diuji |
|-----------|----------|----------------|
| 1 | Header lengkap | Nomor hari (badge `1`), judul `Day 1`, tema `Nature` |
| 2 | Semua aktivitas tampil | Waktu, nama, deskripsi, biaya untuk 2 aktivitas berbeda |
| 3 | Format Rupiah | Biaya `150.000` menggunakan separator titik (.) bukan koma (,) — sesuai locale `id_ID` |
| 4 | Daftar aktivitas kosong | Header tetap tampil, tidak ada aktivitas yang muncul (`findsNothing`) |

**Keputusan desain:**
- Test **tidak** menguji warna, borderRadius, atau properti dekorasi lainnya karena properti tersebut rentan berubah. Fokus diberikan pada **konten teks** yang merupakan kontrak utama widget.
- Test **tidak** menguji interaksi (tap) karena `DayPlanCard` tidak memiliki interaksi — ia adalah widget display-only. Interaksi ditangani oleh parent widget (`DetailItineraryPage`).
- Test **tidak** mengirim callback atau memverifikasi navigasi karena `DayPlanCard` tidak menerima callback — semua data sudah diberikan melalui konstruktor.

##### Code Clarity and Comments

Test code ditulis dengan prinsip **self-documenting code** dan dilengkapi komentar strategis dalam bahasa inggris:

```dart
// ── Test 1: Header ──
testWidgets('renders day header with number badge, title, and theme',
    (tester) async {
  await pumpDayPlanCard(tester);

  // Day number badge (the "1" inside the blue square)
  expect(find.text('1'), findsOneWidget);
  // Day title text
  expect(find.text('Day 1'), findsOneWidget);
  // Theme name
  expect(find.text('Nature'), findsOneWidget);
});
```

**Praktik yang diterapkan:**
- **Helper method** `pumpDayPlanCard()` digunakan untuk menghindari duplikasi kode render. Method ini menerima parameter opsional `customDayPlan` dan `customDayNumber` untuk fleksibilitas per-test-case.
- **Deskripsi test case** menggunakan format `verb + expected behavior + context` sehingga jelas apa yang diuji tanpa perlu membaca kode.
- **Komentar** ditempatkan untuk menjelaskan *mengapa* (misalnya: "Indonesian format uses dot, not comma") bukan menjelaskan *apa* yang sudah jelas dari kode.
- **Grouping** dengan `group('DayPlanCard', ...)` mengorganisir test case dalam satu kategori yang bisa dijalankan secara selektif.
- **Naming** variabel dan method menggunakan nama deskriptif: `expensiveDayPlan`, `emptyDayPlan`, `pumpDayPlanCard`.

#### Cara Menjalankan

```bash
# Jalankan widget test DayPlanCard
flutter test lib/test/day_plan_card_test.dart

# Jalankan semua test (unit + widget)
flutter test lib/test/
```

#### Hasil Eksekusi

```bash
00:00 +0: loading /lib/test/day_plan_card_test.dart
00:01 +1: DayPlanCard renders day header with number badge, title, and theme
00:01 +2: DayPlanCard renders all activities with time, name, description, cost
00:01 +3: DayPlanCard cost is formatted in IDR with dot thousands separator
00:01 +4: DayPlanCard renders card body with no activities list
00:01 +4: All tests passed!
```

Semua **4 test case berhasil** (passed) dalam waktu 1 detik tanpa warning atau error.

---

### Menjalankan Semua Test

```bash
# Widget test DayPlanCard
flutter test lib/test/day_plan_card_test.dart

# Unit test autentikasi
flutter test lib/test/auth_logic_test.dart

# Test spesifik (contoh: Email Validation)
flutter test lib/test/auth_logic_test.dart -k "Email Validation"

# Semua test dalam folder lib/test/
flutter test lib/test/

# Dengan verbose output
flutter test lib/test/day_plan_card_test.dart -v
```

### Struktur File Test

```
lib/test/
├── auth_logic_test.dart           # Unit test: validasi auth (19 test cases)
├── day_plan_card_test.dart        # Widget test: DayPlanCard (4 test cases)

lib/shared/utils/
├── validators.dart                # validateEmail, validatePassword, validateConfirmPassword
└── error_parser.dart              # parseErrorMessage
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
