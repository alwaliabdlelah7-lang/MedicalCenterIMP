import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/appointment.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medical_center.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT,
        phone TEXT,
        fileNumber TEXT,
        address TEXT,
        birthDate TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER,
        doctorName TEXT,
        startTime TEXT,
        endTime TEXT,
        status TEXT
      )
    ''');
  }

  Future<Patient> insertPatient(Patient patient) async {
    final db = await database;
    final id = await db.insert('patients', patient.toMap());
    return Patient(id: id, fullName: patient.fullName, phone: patient.phone, fileNumber: patient.fileNumber);
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final result = await db.query('patients');
    return result.map((json) => Patient(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      fileNumber: json['fileNumber'] as String,
    )).toList();
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await database;
    final result = await db.query('patients', where: 'fullName LIKE ? OR phone LIKE ? OR fileNumber LIKE ?', whereArgs: ['%$query%', '%$query%', '%$query%']);
    return result.map((json) => Patient(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      fileNumber: json['fileNumber'] as String,
    )).toList();
  }
}
