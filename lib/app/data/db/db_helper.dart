import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int version = 1;
  static const String dbName = 'smart_horse_database.db';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), dbName);
    print('Database path: $path');
    return await openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {
        // feeder_room_devices
        await db.execute('''
          CREATE TABLE feeder_room_devices (
            device_id TEXT PRIMARY KEY,
            status TEXT,
            type TEXT,
            room_id TEXT
          )
        ''');

        // feeder_devices
        await db.execute('''
          CREATE TABLE feeder_devices (
            device_id TEXT PRIMARY KEY,
            status TEXT,
            battery_percent BIGINT,
            voltage DOUBLE,
            current DOUBLE,
            power DOUBLE
          )
        ''');

        // feeds
        await db.execute('''
          CREATE TABLE feeds (
            feed_id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT,
            stock DOUBLE
          )
        ''');

        // waters
        await db.execute('''
          CREATE TABLE waters (
            water_id TEXT PRIMARY KEY,
            name TEXT,
            stock DOUBLE
          )
        ''');

        // feeds log
        await db.execute('''
          CREATE TABLE feed_logs (
            log_id TEXT PRIMARY KEY,
            feed_id TEXT,
            quantity DOUBLE,
            date TEXT
          )
        ''');

        // waters
        await db.execute('''
          CREATE TABLE water_logs (
            log_id TEXT PRIMARY KEY,
            water_id TEXT,
            quantity DOUBLE,
            date TEXT
          )
        ''');

        // node_room_devices
        await db.execute('''
          CREATE TABLE node_room_devices (
            device_id TEXT PRIMARY KEY,
            temperature DOUBLE,
            humidity DOUBLE,
            light_intensity DOUBLE,
            time TEXT,
            version TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE node_room_detail (
            detail_id TEXT PRIMARY KEY,
            device_id TEXT,
            temperature DOUBLE,
            humidity DOUBLE,
            light_intensity DOUBLE,
            time TEXT
          )
        ''');

        // Hardcoded insert for node_room_devices
        // await db.insert('node_room_devices', {
        //   'device_id': 'SRIPB1223001',
        //   'temperature': 25.5,
        //   'humidity': 60.0,
        //   'light_intensity': 300.0,
        //   'time': DateTime.now().toIso8601String(),
        // }, conflictAlgorithm: ConflictAlgorithm.replace);

        // await db.insert('node_room_devices', {
        //   'device_id': 'SRIPB1223002',
        //   'temperature': 26.0,
        //   'humidity': 60.0,
        //   'light_intensity': 300.0,
        //   'time': DateTime.now().toIso8601String(),
        // }, conflictAlgorithm: ConflictAlgorithm.replace);

        // rooms
        await db.execute('''
          CREATE TABLE rooms (
            room_id TEXT PRIMARY KEY,
            name TEXT,
            device_serial TEXT,
            status TEXT,
            remaining_water DOUBLE,
            remaining_feed DOUBLE,
            water_schedule_type TEXT,
            feed_schedule_type TEXT,
            stable_id TEXT,
            horse_id TEXT,
            cctv_id TEXT
          )
        ''');

        // feed_history
        await db.execute('''
          CREATE TABLE feed_history (
            history_id TEXT PRIMARY KEY,
            schedule_type TEXT,
            feed DOUBLE,
            water DOUBLE,
            time TEXT,
            stable_id TEXT,
            room_id TEXT
          )
        ''');

        // stables
        await db.execute('''
          CREATE TABLE stables (
            stable_id TEXT PRIMARY KEY,
            name TEXT,
            address TEXT
          )
        ''');

        // horses
        // await db.execute('''
        //   CREATE TABLE horses (
        //     horse_id TEXT PRIMARY KEY,
        //     name TEXT,
        //     type TEXT,
        //     gender TEXT,
        //     age BIGINT,
        //     room_id TEXT,
        //     category TEXT
        //   )
        // ''');

        await db.execute('''
          CREATE TABLE horses (
            horse_id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT,
            gender TEXT,
            age BIGINT,
            room_id TEXT,
            category TEXT,
            birth_place TEXT,
            birth_date TEXT,
            settle_date TEXT,
            length DOUBLE,
            weight DOUBLE,
            height DOUBLE,
            chest_circum DOUBLE,
            skin_color TEXT,
            mark_desc TEXT,
            photos TEXT
          )
        ''');

        // halter_devices
        // ...existing code...
        await db.execute('''
          CREATE TABLE halter_devices (
            device_id TEXT PRIMARY KEY,
            status TEXT,
            battery_percent BIGINT,
            horse_id TEXT,
            version TEXT
          )
        ''');
        // ...existing code...

        // halter_devices
        await db.execute('''
          CREATE TABLE halter_device_power_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT,
            power_on_time TEXT,
            power_off_time TEXT,
            duration_on INTEGER
          );
        ''');

        // Hardcoded insert for halter_devices
        // await db.insert(
        //   'halter_devices',
        //   {
        //     'device_id': 'SHIPB1223002',
        //     'status': 'on',
        //     'battery_percent': 87,
        //     'horse_id': ''
        //   },
        //   conflictAlgorithm: ConflictAlgorithm.replace,
        // );
        // await db.insert(
        //   'halter_devices',
        //   {
        //     'device_id': 'SHIPB1223003',
        //     'status': 'on',
        //     'battery_percent': 61,
        //     'horse_id': ''
        //   },
        //   conflictAlgorithm: ConflictAlgorithm.replace,
        // );

        // halter_rule_engine
        await db.execute('''
          CREATE TABLE halter_rule_engine (
            rule_id BIGINT PRIMARY KEY,
            temp_max DOUBLE,
            temp_min DOUBLE,
            spo_max DOUBLE,
            spo_min DOUBLE,
            heart_rate_max BIGINT,
            heart_rate_min BIGINT,
            respiratory_max DOUBLE
          )
        ''');

        // halter_settings
        await db.execute('''
          CREATE TABLE halter_settings (
            setting_id BIGINT PRIMARY KEY,
            cloud_url TEXT,
            lora_port TEXT,
            type TEXT
          )
        ''');

        // halter_raw_data
        await db.execute('''
          CREATE TABLE halter_raw_data (
            raw_id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT,
            time TEXT
          )
        ''');

        // halter_horse_logs
        await db.execute('''
          CREATE TABLE halter_horse_logs (
            log_id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT,
            type TEXT,
            time TEXT,
            device_id TEXT,
            is_high INTEGER
          )
        ''');

        // halter_table_rule_biometric_logs
        await db.execute('''
          CREATE TABLE halter_biometric_rule_engine (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            suhu_min DOUBLE,
            suhu_max DOUBLE,
            heart_rate_min INTEGER,
            heart_rate_max INTEGER,
            spo_min DOUBLE,
            spo_max DOUBLE,
            respirasi_min INTEGER,
            respirasi_max INTEGER
          )
        ''');

        // halter_table_rule_position_logs
        await db.execute('''
          CREATE TABLE halter_position_rule_engine (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            pitch_min DOUBLE,
            pitch_max DOUBLE,
            roll_min DOUBLE,
            roll_max DOUBLE,
            yaw_min DOUBLE,
            yaw_max DOUBLE
          )
        ''');

        // Data log kalibrasi halter
        await db.execute('''
          CREATE TABLE halter_calibration_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT,
            timestamp TEXT,
            sensor_name TEXT,
            referensi TEXT,
            sensor_value TEXT,
            nilai_kalibrasi TEXT
          )
        ''');

        // cctv
        await db.execute('''
          CREATE TABLE cctv (
            cctv_id TEXT PRIMARY KEY,
            ip_address TEXT,
            port INTEGER,
            username TEXT,
            password TEXT
          )
        ''');

        // halter_device_detail
        await db.execute('''
          CREATE TABLE halter_device_detail (
            detail_id TEXT PRIMARY KEY,
            latitude DOUBLE,
            longitude DOUBLE,
            altitude DOUBLE,
            sog DOUBLE,
            cog DOUBLE,
            roll DOUBLE,
            pitch DOUBLE,
            yaw DOUBLE,
            voltage DOUBLE,
            heart_rate BIGINT,
            spo DOUBLE,
            temperature DOUBLE,
            respiratory_rate DOUBLE,
            interval BIGINT,
            device_id TEXT,
            time TEXT,
            rssi BIGINT,
            snr DOUBLE
          )
        ''');
      },
    );
  }
}
