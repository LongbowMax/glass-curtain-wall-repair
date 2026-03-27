import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/repair_request.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'glass_curtain_wall_repair.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE repair_requests (
        id TEXT PRIMARY KEY,
        projectName TEXT,
        buildingName TEXT,
        ownerName TEXT,
        ownerPhone TEXT,
        ownerUnit TEXT,
        address TEXT,
        inspectionDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        items TEXT NOT NULL,
        photos TEXT,
        notes TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requestId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // 保存需求单
  Future<void> saveRequest(RepairRequest request) async {
    final db = await database;
    await db.insert(
      'repair_requests',
      _requestToMap(request),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有需求单
  Future<List<RepairRequest>> getAllRequests() async {
    final db = await database;
    final maps = await db.query('repair_requests', orderBy: 'createdAt DESC');
    return maps.map((map) => _mapToRequest(map)).toList();
  }

  // 获取单个需求单
  Future<RepairRequest?> getRequest(String id) async {
    final db = await database;
    final maps = await db.query(
      'repair_requests',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToRequest(maps.first);
  }

  // 删除需求单
  Future<void> deleteRequest(String id) async {
    final db = await database;
    await db.delete(
      'repair_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 更新同步状态
  Future<void> updateSyncStatus(String id, bool isSynced) async {
    final db = await database;
    await db.update(
      'repair_requests',
      {'isSynced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取未同步的数据
  Future<List<RepairRequest>> getUnsyncedRequests() async {
    final db = await database;
    final maps = await db.query(
      'repair_requests',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => _mapToRequest(map)).toList();
  }

  // 搜索需求单
  Future<List<RepairRequest>> searchRequests(String keyword) async {
    final db = await database;
    final maps = await db.query(
      'repair_requests',
      where: 'projectName LIKE ? OR ownerName LIKE ? OR ownerPhone LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => _mapToRequest(map)).toList();
  }

  // 辅助方法：将RepairRequest转换为Map
  Map<String, dynamic> _requestToMap(RepairRequest request) {
    return {
      'id': request.id,
      'projectName': request.projectName,
      'buildingName': request.buildingName,
      'ownerName': request.ownerName,
      'ownerPhone': request.ownerPhone,
      'ownerUnit': request.ownerUnit,
      'address': request.address,
      'inspectionDate': request.inspectionDate?.toIso8601String(),
      'createdAt': request.createdAt.toIso8601String(),
      'updatedAt': request.updatedAt.toIso8601String(),
      'items': jsonEncode(request.items.map((i) => i.toJson()).toList()),
      'photos': request.photos != null ? jsonEncode(request.photos) : null,
      'notes': request.notes,
      'isSynced': request.isSynced ? 1 : 0,
    };
  }

  // 辅助方法：将Map转换为RepairRequest
  RepairRequest _mapToRequest(Map<String, dynamic> map) {
    return RepairRequest(
      id: map['id'],
      projectName: map['projectName'],
      buildingName: map['buildingName'],
      ownerName: map['ownerName'],
      ownerPhone: map['ownerPhone'],
      ownerUnit: map['ownerUnit'],
      address: map['address'],
      inspectionDate: map['inspectionDate'] != null
          ? DateTime.parse(map['inspectionDate'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      items: map['items'] != null
          ? (jsonDecode(map['items']) as List)
              .map((e) => RepairItem.fromJson(e))
              .toList()
          : [],
      photos: map['photos'] != null
          ? List<String>.from(jsonDecode(map['photos']))
          : [],
      notes: map['notes'],
      isSynced: map['isSynced'] == 1,
    );
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
