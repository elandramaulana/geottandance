// // lib/services/database_helper.dart
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/attendance_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'attendance.db');
//     return await openDatabase(
//       path,
//       version: 2,
//       onCreate: _createTables,
//       onUpgrade: _upgradeDatabase,
//     );
//   }

//   Future<void> _createTables(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE attendance (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         timestamp INTEGER NOT NULL,
//         latitude REAL NOT NULL,
//         longitude REAL NOT NULL,
//         type TEXT NOT NULL,
//         address TEXT
//       )
//     ''');

//     // New table for tracking daily attendance status
//     await db.execute('''
//       CREATE TABLE daily_attendance_status (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         date TEXT NOT NULL UNIQUE,
//         has_clocked_in INTEGER NOT NULL DEFAULT 0,
//         has_clocked_out INTEGER NOT NULL DEFAULT 0,
//         clock_in_id INTEGER,
//         clock_out_id INTEGER,
//         created_at INTEGER NOT NULL,
//         updated_at INTEGER NOT NULL
//       )
//     ''');
//   }

//   Future<void> _upgradeDatabase(
//     Database db,
//     int oldVersion,
//     int newVersion,
//   ) async {
//     if (oldVersion < 2) {
//       // Add the new table for version 2
//       await db.execute('''
//         CREATE TABLE daily_attendance_status (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           date TEXT NOT NULL UNIQUE,
//           has_clocked_in INTEGER NOT NULL DEFAULT 0,
//           has_clocked_out INTEGER NOT NULL DEFAULT 0,
//           clock_in_id INTEGER,
//           clock_out_id INTEGER,
//           created_at INTEGER NOT NULL,
//           updated_at INTEGER NOT NULL
//         )
//       ''');
//     }
//   }

//   Future<int> insertAttendance(AttendanceRecord record) async {
//     final db = await database;
//     return await db.insert('attendance', record.toMap());
//   }

//   Future<List<AttendanceRecord>> getAllAttendance() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'attendance',
//       orderBy: 'timestamp DESC',
//     );
//     return List.generate(maps.length, (i) {
//       return AttendanceRecord.fromMap(maps[i]);
//     });
//   }

//   Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
//     final db = await database;
//     final startOfDay = DateTime(date.year, date.month, date.day);
//     final endOfDay = startOfDay.add(const Duration(days: 1));

//     final List<Map<String, dynamic>> maps = await db.query(
//       'attendance',
//       where: 'timestamp >= ? AND timestamp < ?',
//       whereArgs: [
//         startOfDay.millisecondsSinceEpoch,
//         endOfDay.millisecondsSinceEpoch,
//       ],
//       orderBy: 'timestamp DESC',
//     );

//     return List.generate(maps.length, (i) {
//       return AttendanceRecord.fromMap(maps[i]);
//     });
//   }

//   Future<AttendanceRecord?> getLastAttendance() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'attendance',
//       orderBy: 'timestamp DESC',
//       limit: 1,
//     );

//     if (maps.isNotEmpty) {
//       return AttendanceRecord.fromMap(maps.first);
//     }
//     return null;
//   }

//   // New methods for daily attendance tracking

//   /// Get today's date in YYYY-MM-DD format
//   String _getTodayDateString() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//   }

//   /// Get or create daily attendance status for today
//   Future<Map<String, dynamic>?> getDailyAttendanceStatus([
//     DateTime? date,
//   ]) async {
//     final db = await database;
//     final dateString = date != null
//         ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
//         : _getTodayDateString();

//     final List<Map<String, dynamic>> maps = await db.query(
//       'daily_attendance_status',
//       where: 'date = ?',
//       whereArgs: [dateString],
//     );

//     if (maps.isNotEmpty) {
//       return maps.first;
//     }
//     return null;
//   }

//   /// Create daily attendance status record
//   Future<void> createDailyAttendanceStatus([DateTime? date]) async {
//     final db = await database;
//     final dateString = date != null
//         ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
//         : _getTodayDateString();

//     final now = DateTime.now().millisecondsSinceEpoch;

//     await db.insert('daily_attendance_status', {
//       'date': dateString,
//       'has_clocked_in': 0,
//       'has_clocked_out': 0,
//       'clock_in_id': null,
//       'clock_out_id': null,
//       'created_at': now,
//       'updated_at': now,
//     }, conflictAlgorithm: ConflictAlgorithm.ignore);
//   }

//   /// Update daily attendance status
//   Future<void> updateDailyAttendanceStatus({
//     DateTime? date,
//     bool? hasClickedIn,
//     bool? hasClockedOut,
//     int? clockInId,
//     int? clockOutId,
//   }) async {
//     final db = await database;
//     final dateString = date != null
//         ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
//         : _getTodayDateString();

//     final updateData = <String, dynamic>{
//       'updated_at': DateTime.now().millisecondsSinceEpoch,
//     };

//     if (hasClickedIn != null) {
//       updateData['has_clocked_in'] = hasClickedIn ? 1 : 0;
//     }
//     if (hasClockedOut != null) {
//       updateData['has_clocked_out'] = hasClockedOut ? 1 : 0;
//     }
//     if (clockInId != null) {
//       updateData['clock_in_id'] = clockInId;
//     }
//     if (clockOutId != null) {
//       updateData['clock_out_id'] = clockOutId;
//     }

//     await db.update(
//       'daily_attendance_status',
//       updateData,
//       where: 'date = ?',
//       whereArgs: [dateString],
//     );
//   }

//   /// Check if user has already clocked in today
//   Future<bool> hasClickedInToday([DateTime? date]) async {
//     final status = await getDailyAttendanceStatus(date);
//     if (status == null) {
//       await createDailyAttendanceStatus(date);
//       return false;
//     }
//     return status['has_clocked_in'] == 1;
//   }

//   /// Check if user has already clocked out today
//   Future<bool> hasClockedOutToday([DateTime? date]) async {
//     final status = await getDailyAttendanceStatus(date);
//     if (status == null) {
//       await createDailyAttendanceStatus(date);
//       return false;
//     }
//     return status['has_clocked_out'] == 1;
//   }

//   /// Get today's clock in record
//   Future<AttendanceRecord?> getTodayClockIn([DateTime? date]) async {
//     final status = await getDailyAttendanceStatus(date);
//     if (status != null && status['clock_in_id'] != null) {
//       final db = await database;
//       final List<Map<String, dynamic>> maps = await db.query(
//         'attendance',
//         where: 'id = ?',
//         whereArgs: [status['clock_in_id']],
//       );

//       if (maps.isNotEmpty) {
//         return AttendanceRecord.fromMap(maps.first);
//       }
//     }
//     return null;
//   }

//   /// Get today's clock out record
//   Future<AttendanceRecord?> getTodayClockOut([DateTime? date]) async {
//     final status = await getDailyAttendanceStatus(date);
//     if (status != null && status['clock_out_id'] != null) {
//       final db = await database;
//       final List<Map<String, dynamic>> maps = await db.query(
//         'attendance',
//         where: 'id = ?',
//         whereArgs: [status['clock_out_id']],
//       );

//       if (maps.isNotEmpty) {
//         return AttendanceRecord.fromMap(maps.first);
//       }
//     }
//     return null;
//   }

//   /// Clean up old daily status records (optional - to keep database clean)
//   Future<void> cleanupOldDailyStatus({int daysToKeep = 30}) async {
//     final db = await database;
//     final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
//     final cutoffDateString =
//         '${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}';

//     await db.delete(
//       'daily_attendance_status',
//       where: 'date < ?',
//       whereArgs: [cutoffDateString],
//     );
//   }

//   Future<int> deleteAttendance(int id) async {
//     final db = await database;
//     return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<void> deleteAllAttendance() async {
//     final db = await database;
//     await db.delete('attendance');
//     await db.delete('daily_attendance_status');
//   }
// }
