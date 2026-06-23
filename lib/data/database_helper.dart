import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  // Factory constructor — mengembalikan instance yang sama (_instance)
  factory DatabaseHelper() => _instance;
  
  // Private constructor — mencegah pembuatan objek DatabaseHelper
  // dari luar file ini selain melalui factory constructor di atas
  DatabaseHelper._internal();

  // "_database" menyimpan koneksi database yang sudah terbuka.
  // Nullable karena pertama kali belum terbuka (null).
  Database? _database;

  // Getter untuk mengakses database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // getDatabasesPath() → mendapatkan folder penyimpanan database
    final dbPath = await getDatabasesPath();
    
    // join() menggabungkan path folder dengan nama file database
    final path = join(dbPath, 'trip_genie.db');

    return await openDatabase(
      path,
      version: 1,           // versi database, naikkan jika ada perubahan skema
      onCreate: _onCreate,  // fungsi yang dipanggil saat database pertama dibuat
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      }, // mengaktifkan foreign key support
    );
  }

  // _onCreate dipanggil SEKALI saja — saat pertama kali database dibuat
  // di perangkat pengguna. Berisi perintah SQL untuk membuat semua tabel.
  Future<void> _onCreate(Database db, int version) async {
  
    // Tabel itineraries
    await db.execute('''
      CREATE TABLE itineraries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        destination TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        budget REAL NOT NULL,
        accommodation TEXT,
        accommodation_cost REAL,
        food_cost REAL,
        transport_cost REAL,
        activity_cost REAL,
        total_cost REAL,
        created_at TEXT NOT NULL
      )
    ''');


    // Tabel day_plans
    await db.execute('''
      CREATE TABLE day_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itinerary_id INTEGER NOT NULL,
        day_number INTEGER NOT NULL,
        theme TEXT NOT NULL,
        FOREIGN KEY (itinerary_id) REFERENCES itineraries (id)
          ON DELETE CASCADE
      )
    ''');

    // Tabel activities
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_plan_id INTEGER NOT NULL,
        time TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        estimated_cost REAL NOT NULL,
        FOREIGN KEY (day_plan_id) REFERENCES day_plans (id)
          ON DELETE CASCADE
      )
    ''');
  }
}