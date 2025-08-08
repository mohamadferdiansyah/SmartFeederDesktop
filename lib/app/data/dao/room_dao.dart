import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class RoomDao {
  final Database db;
  RoomDao(this.db);

  // CREATE
  Future<int> insert(RoomModel model) async {
    return await db.insert(
      'rooms',
      _toDbMap(model),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<RoomModel>> getAll() async {
    final maps = await db.query('rooms');
    return maps.map((m) => _fromDbMap(m)).toList();
  }

  // READ BY ID
  Future<RoomModel?> getById(String roomId) async {
    final maps = await db.query(
      'rooms',
      where: 'room_id = ?',
      whereArgs: [roomId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return _fromDbMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> update(RoomModel model) async {
    return await db.update(
      'rooms',
      _toDbMap(model),
      where: 'room_id = ?',
      whereArgs: [model.roomId],
    );
  }

  Future<int> updateHorseId(String roomId, String? horseId) async {
    return await db.update(
      'rooms',
      {'horse_id': horseId,
        'status': horseId != null ? 'used' : 'available'
      },
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  Future<int> clearHorseIdInRooms(String horseId) async {
    return await db.update(
      'rooms',
      {'horse_id': null},
      where: 'horse_id = ?',
      whereArgs: [horseId],
    );
  }

  Future<void> clearDeviceSerialInRooms(String deviceId) async {
  await db.update(
    'rooms',
    {'device_serial': null},
    where: 'device_serial = ?',
    whereArgs: [deviceId],
  );
}

Future<void> updateDeviceSerial(String roomId, String? deviceSerial) async {
  await db.update(
    'rooms',
    {'device_serial': deviceSerial},
    where: 'room_id = ?',
    whereArgs: [roomId],
  );
}

  // DELETE BY ID
  Future<int> delete(String roomId) async {
    return await db.delete('rooms', where: 'room_id = ?', whereArgs: [roomId]);
  }

  // DELETE ALL (optional)
  Future<int> deleteAll() async {
    return await db.delete('rooms');
  }

  // ---------- Helper for cctvId (List<String> <-> JSON string) ----------
  Map<String, dynamic> _toDbMap(RoomModel model) {
    final map = model.toMap();
    // Simpan cctvId sebagai JSON string
    map['cctv_id'] = jsonEncode(model.cctvId);
    return map;
  }

  RoomModel _fromDbMap(Map<String, dynamic> map) {
    // Pastikan cctvId dari DB didecode dari JSON string
    var cctvRaw = map['cctv_id'];
    List<String> cctvList = [];
    if (cctvRaw != null && cctvRaw is String && cctvRaw.isNotEmpty) {
      try {
        cctvList = List<String>.from(jsonDecode(cctvRaw));
      } catch (_) {
        // fallback jika bukan json, asumsikan string kosong
        cctvList = [];
      }
    }
    return RoomModel(
      roomId: map['room_id'],
      name: map['name'],
      deviceSerial: map['device_serial'],
      status: map['status'],
      cctvId: cctvList,
      stableId: map['stable_id'],
      horseId: map['horse_id'],
      remainingWater: (map['remaining_water'] ?? 0).toDouble(),
      remainingFeed: (map['remaining_feed'] ?? 0).toDouble(),
      waterScheduleType: map['water_schedule_type'] ?? '',
      feedScheduleType: map['feed_schedule_type'] ?? '',
      // Optional field below
      lastFeedText: map['last_feed_text'] != null
          ? DateTime.tryParse(map['last_feed_text'])
          : null,
      waterScheduleIntervalHour: map['water_schedule_interval_hour'],
      feedScheduleIntervalHour: map['feed_schedule_interval_hour'],
    );
  }
}
