import '../models/komentar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/tanaman_user.dart';
import '../models/galeri_tanaman.dart';
import '../models/jadwal_penyiraman.dart';
import '../models/tantangan.dart';
import '../models/lencana.dart';
import '../models/postingan.dart'; // Import Postingan model
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'plantify.db');
    return await openDatabase(
      databasePath,
      version: 5, // Incremented version to ensure table creation
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // onOpen runs every time the DB is opened. Use it to ensure required tables exist
      onOpen: (db) async {
        // If the table is missing (existing installations), create it so app doesn't crash
        await db.execute('''
          CREATE TABLE IF NOT EXISTS postingan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            image_url TEXT,
            caption TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS komentar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            postingan_id INTEGER,
            user_id INTEGER,
            isi_komentar TEXT NOT NULL,
            created_at TEXT,
            FOREIGN KEY (postingan_id) REFERENCES postingan (id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS likes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            postingan_id INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (postingan_id) REFERENCES postingan (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS histori_siram (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            tanaman_user_id INTEGER,
            tanggal_siram TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (tanaman_user_id) REFERENCES tanaman_user (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        hari_beruntun INTEGER DEFAULT 0,
        total_lencana INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tanaman_user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        nama_tanaman TEXT NOT NULL,
        jenis_tanaman TEXT,
        jadwal_siram TEXT,
        terakhir_disiram TEXT,
        foto_path TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE galeri_tanaman (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kategori TEXT,
        status_disiram TEXT,
        deskripsi TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE jadwal_penyiraman (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanaman_user_id INTEGER,
        tanggal_siram TEXT,
        status TEXT,
        FOREIGN KEY (tanaman_user_id) REFERENCES tanaman_user (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tantangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        nama_tantangan TEXT,
        deskripsi TEXT,
        progress_saat_ini INTEGER DEFAULT 0,
        target INTEGER,
        total_peserta INTEGER DEFAULT 0,
        status TEXT,
        icon TEXT,
        last_reset TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE lencana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        nama_lencana TEXT,
        deskripsi TEXT,
        icon TEXT,
        tanggal_diperoleh TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Add Postingan table
    await db.execute('''
      CREATE TABLE postingan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        image_url TEXT,
        caption TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE komentar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postingan_id INTEGER,
        user_id INTEGER,
        isi_komentar TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (postingan_id) REFERENCES postingan (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        postingan_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (postingan_id) REFERENCES postingan (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE histori_siram (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        tanaman_user_id INTEGER,
        tanggal_siram TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (tanaman_user_id) REFERENCES tanaman_user (id) ON DELETE CASCADE
      )
    ''');

    // Seed data for galeri_tanaman
    await db.insert('galeri_tanaman', {
      'nama': 'Monstera',
      'kategori': 'Tropis',
      'status_disiram': 'Sudah Disiram',
      'deskripsi': 'Tanaman hias populer dengan daun berlubang',
    });
    await db.insert('galeri_tanaman', {
      'nama': 'Lidah Mertua',
      'kategori': 'Sukulen',
      'status_disiram': 'Belum Disiram',
      'deskripsi': 'Tanaman pembersih udara yang tahan banting',
    });
    await db.insert('galeri_tanaman', {
      'nama': 'Kaktus',
      'kategori': 'Kaktus',
      'status_disiram': 'Sudah Disiram',
      'deskripsi': 'Sukulen gurun yang memerlukan sedikit air',
    });
    await db.insert('galeri_tanaman', {
      'nama': 'Sirih Gading',
      'kategori': 'Tropis',
      'status_disiram': 'Belum Disiram',
      'deskripsi': 'Tanaman merambat yang mudah tumbuh',
    });
    await db.insert('galeri_tanaman', {
      'nama': 'Bunga Lili',
      'kategori': 'Berbunga',
      'status_disiram': 'Sudah Disiram',
      'deskripsi': 'Bunga cantik dengan aroma harum',
    });
    await db.insert('galeri_tanaman', {
      'nama': 'Aloe Vera',
      'kategori': 'Sukulen',
      'status_disiram': 'Belum Disiram',
      'deskripsi': 'Tanaman obat serbaguna',
    });

    
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Our existing _onUpgrade drops all tables and recreates them via _onCreate.
    // This will ensure all tables, including 'postingan', are created.
    if (oldVersion < newVersion) {
      await db.execute("DROP TABLE IF EXISTS users");
      await db.execute("DROP TABLE IF EXISTS tanaman_user");
      await db.execute("DROP TABLE IF EXISTS galeri_tanaman");
      await db.execute("DROP TABLE IF EXISTS jadwal_penyiraman");
      await db.execute("DROP TABLE IF EXISTS tantangan");
      await db.execute("DROP TABLE IF EXISTS lencana");
      await db.execute("DROP TABLE IF EXISTS postingan"); // Ensure this is also dropped
      await db.execute("DROP TABLE IF EXISTS komentar");
      await db.execute("DROP TABLE IF EXISTS likes");
      await db.execute("DROP TABLE IF EXISTS histori_siram");
      await _onCreate(db, newVersion);
    }
  }

  Future<void> close() async {
    final db = await _instance.database;
    await db.close();
    _database = null;
  }

  // User CRUD Operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addDefaultChallengesForUser(int userId) async {
    final db = await database;
    final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    await db.insert('tantangan', {
      'user_id': userId,
      'nama_tantangan': 'Tantangan Hijau 20 Hari',
      'deskripsi': 'Siram tanaman konsisten 20 hari',
      'progress_saat_ini': 0,
      'target': 20,
      'status': 'aktif',
      'icon': '🌱',
      'last_reset': currentMonth,
    });
    await db.insert('tantangan', {
      'user_id': userId,
      'nama_tantangan': 'Orang Tua Tanaman Pro',
      'deskripsi': 'Tambahkan 5 jenis tanaman berbeda ke koleksimu',
      'progress_saat_ini': 0,
      'target': 5,
      'status': 'aktif',
      'icon': '🏆',
      'last_reset': currentMonth,
    });
    await db.insert('tantangan', {
      'user_id': userId,
      'nama_tantangan': 'Penolong Komunitas',
      'deskripsi': 'Bagikan 10 tips dengan komunitas',
      'progress_saat_ini': 0,
      'target': 10,
      'status': 'aktif',
      'icon': '🤝',
      'last_reset': currentMonth,
    });
  }

  // TanamanUser CRUD Operations
  Future<int> insertTanamanUser(TanamanUser tanamanUser) async {
    final db = await database;
    return await db.insert('tanaman_user', tanamanUser.toMap());
  }

  Future<List<TanamanUser>> getTanamanUserByUserId(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tanaman_user',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return TanamanUser.fromMap(maps[i]);
    });
  }

  Future<List<TanamanUser>> getAllTanamanUser() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('tanaman_user');
    return List.generate(maps.length, (i) {
      return TanamanUser.fromMap(maps[i]);
    });
  }

  Future<TanamanUser?> getTanamanUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tanaman_user',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TanamanUser.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTanamanUser(TanamanUser tanamanUser) async {
    final db = await database;
    return await db.update(
      'tanaman_user',
      tanamanUser.toMap(),
      where: 'id = ?',
      whereArgs: [tanamanUser.id],
    );
  }

  Future<int> deleteTanamanUser(int id) async {
    final db = await database;
    return await db.delete(
      'tanaman_user',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GaleriTanaman CRUD Operations
  Future<int> insertGaleriTanaman(GaleriTanaman galeriTanaman) async {
    final db = await database;
    return await db.insert('galeri_tanaman', galeriTanaman.toMap());
  }

  Future<List<GaleriTanaman>> getAllGaleriTanaman() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('galeri_tanaman');
    return List.generate(maps.length, (i) {
      return GaleriTanaman.fromMap(maps[i]);
    });
  }

  Future<GaleriTanaman?> getGaleriTanamanById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'galeri_tanaman',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return GaleriTanaman.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGaleriTanaman(GaleriTanaman galeriTanaman) async {
    final db = await database;
    return await db.update(
      'galeri_tanaman',
      galeriTanaman.toMap(),
      where: 'id = ?',
      whereArgs: [galeriTanaman.id],
    );
  }

  Future<int> deleteGaleriTanaman(int id) async {
    final db = await database;
    return await db.delete(
      'galeri_tanaman',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // JadwalPenyiraman CRUD Operations
  Future<int> insertJadwalPenyiraman(JadwalPenyiraman jadwalPenyiraman) async {
    final db = await database;
    return await db.insert('jadwal_penyiraman', jadwalPenyiraman.toMap());
  }

  Future<List<JadwalPenyiraman>> getJadwalPenyiramanByTanamanUserId(int tanamanUserId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'jadwal_penyiraman',
      where: 'tanaman_user_id = ?',
      whereArgs: [tanamanUserId],
      orderBy: 'tanggal_siram ASC',
    );
    return List.generate(maps.length, (i) {
      return JadwalPenyiraman.fromMap(maps[i]);
    });
  }

  Future<int> updateJadwalPenyiraman(JadwalPenyiraman jadwalPenyiraman) async {
    final db = await database;
    return await db.update(
      'jadwal_penyiraman',
      jadwalPenyiraman.toMap(),
      where: 'id = ?',
      whereArgs: [jadwalPenyiraman.id],
    );
  }

  Future<int> deleteJadwalPenyiraman(int id) async {
    final db = await database;
    return await db.delete(
      'jadwal_penyiraman',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tantangan CRUD Operations
  Future<int> insertTantangan(Tantangan tantangan) async {
    final db = await database;
    return await db.insert('tantangan', tantangan.toMap());
  }

  Future<List<Tantangan>> getTantanganByUserId(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tantangan',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Tantangan.fromMap(maps[i]);
    });
  }

  Future<Tantangan?> getTantanganById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tantangan',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Tantangan.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTantangan(Tantangan tantangan) async {
    final db = await database;
    return await db.update(
      'tantangan',
      tantangan.toMap(),
      where: 'id = ?',
      whereArgs: [tantangan.id],
    );
  }

  Future<int> deleteTantangan(int id) async {
    final db = await database;
    return await db.delete(
      'tantangan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> checkAndResetChallenges(int userId) async {
    final db = await database;
    final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    List<Tantangan> challenges = await getTantanganByUserId(userId);
    for (var challenge in challenges) {
      if (challenge.lastReset != currentMonth) {
        challenge.progressSaatIni = 0;
        challenge.lastReset = currentMonth;
        await updateTantangan(challenge);
      }
    }
  }

  Future<void> addWateringLog(int userId, int tanamanUserId) async {
    final db = await database;
    await db.insert('histori_siram', {
      'user_id': userId,
      'tanaman_user_id': tanamanUserId,
      'tanggal_siram': DateTime.now().toIso8601String(),
    });
  }
  
  Future<int> getWateringChallengeProgress(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(DISTINCT date(tanggal_siram)) FROM histori_siram WHERE user_id = ? AND strftime('%Y-%m', tanggal_siram) = strftime('%Y-%m', 'now')",
        [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPlantChallengeProgress(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(id) FROM tanaman_user WHERE user_id = ? AND strftime('%Y-%m', created_at) = strftime('%Y-%m', 'now')",
        [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCommunityChallengeProgress(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(id) FROM postingan WHERE user_id = ? AND strftime('%Y-%m', created_at) = strftime('%Y-%m', 'now')",
        [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Lencana CRUD Operations
  Future<int> insertLencana(Lencana lencana) async {
    final db = await database;
    return await db.insert('lencana', lencana.toMap());
  }

  Future<List<Lencana>> getLencanaByUserId(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'lencana',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Lencana.fromMap(maps[i]);
    });
  }

  Future<Lencana?> getLencanaById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'lencana',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Lencana.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateLencana(Lencana lencana) async {
    final db = await database;
    return await db.update(
      'lencana',
      lencana.toMap(),
      where: 'id = ?',
      whereArgs: [lencana.id],
    );
  }

  Future<int> deleteLencana(int id) async {
    final db = await database;
    return await db.delete(
      'lencana',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Postingan CRUD Operations
  Future<int> insertPostingan(Postingan postingan) async {
    final db = await database;
    return await db.insert('postingan', postingan.toMap());
  }

  Future<List<Postingan>> getAllPostingan() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('postingan', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) {
      return Postingan.fromMap(maps[i]);
    });
  }

  Future<List<Postingan>> getPostinganByUserId(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'postingan',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return Postingan.fromMap(maps[i]);
    });
  }

  Future<Postingan?> getPostinganById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'postingan',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Postingan.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePostingan(Postingan postingan) async {
    final db = await database;
    return await db.update(
      'postingan',
      postingan.toMap(),
      where: 'id = ?',
      whereArgs: [postingan.id],
    );
  }

  Future<int> deletePostingan(int id) async {
    final db = await database;
    return await db.delete(
      'postingan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Komentar CRUD Operations
  Future<int> insertKomentar(Komentar komentar) async {
    final db = await database;
    return await db.insert('komentar', komentar.toMap());
  }

  Future<List<Komentar>> getKomentarByPostinganId(int postinganId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'komentar',
      where: 'postingan_id = ?',
      whereArgs: [postinganId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) {
      return Komentar.fromMap(maps[i]);
    });
  }

  // Like CRUD Operations
  Future<void> likePost(int userId, int postinganId) async {
    final db = await database;
    await db.insert('likes', {'user_id': userId, 'postingan_id': postinganId});
  }

  Future<void> unlikePost(int userId, int postinganId) async {
    final db = await database;
    await db.delete('likes', where: 'user_id = ? AND postingan_id = ?', whereArgs: [userId, postinganId]);
  }

  Future<int> getLikesCount(int postinganId) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM likes WHERE postingan_id = ?', [postinganId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> isPostLikedByUser(int userId, int postinganId) async {
    final db = await database;
    final result = await db.query('likes', where: 'user_id = ? AND postingan_id = ?', whereArgs: [userId, postinganId]);
    return result.isNotEmpty;
  }
}