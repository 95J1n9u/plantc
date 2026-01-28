import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plant.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plants.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE plants (
        id $idType,
        name $textType,
        species $textType,
        plantSpeciesId TEXT,
        growthStage TEXT DEFAULT 'mature',
        wateringFrequency $intType,
        lastWateredDate $textType,
        nextWateringDate $textType,
        imagePath TEXT,
        notes TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 버전 1에서 2로 업그레이드: plantSpeciesId 컬럼 추가
      await db.execute('ALTER TABLE plants ADD COLUMN plantSpeciesId TEXT');
    }
    if (oldVersion < 3) {
      // 버전 2에서 3으로 업그레이드: growthStage 컬럼 추가
      await db.execute('ALTER TABLE plants ADD COLUMN growthStage TEXT DEFAULT \'mature\'');
    }
  }

  // 식물 추가
  Future<Plant> createPlant(Plant plant) async {
    final db = await instance.database;
    final id = await db.insert('plants', plant.toMap());
    return plant.copyWith(id: id);
  }

  // 모든 식물 조회
  Future<List<Plant>> getAllPlants() async {
    final db = await instance.database;
    final result = await db.query('plants', orderBy: 'nextWateringDate ASC');
    return result.map((json) => Plant.fromMap(json)).toList();
  }

  // 특정 식물 조회
  Future<Plant?> getPlant(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Plant.fromMap(maps.first);
    }
    return null;
  }

  // 식물 정보 업데이트
  Future<int> updatePlant(Plant plant) async {
    final db = await instance.database;
    return db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  // 식물 삭제
  Future<int> deletePlant(int id) async {
    final db = await instance.database;
    return await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 물 주기 업데이트
  Future<int> waterPlant(int id) async {
    final plant = await getPlant(id);
    if (plant == null) return 0;

    final updatedPlant = plant.copyWithWatered();
    return await updatePlant(updatedPlant);
  }

  // 데이터베이스 닫기
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
