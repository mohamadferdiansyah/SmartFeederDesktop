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

        // feed_logs
        await db.execute('''
          CREATE TABLE feed_logs (
            log_id TEXT PRIMARY KEY,
            feed_id TEXT,
            quantity DOUBLE,
            date TEXT
          )
        ''');

        // water_logs
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
            time TEXT
          )
        ''');

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
        await db.execute('''
          CREATE TABLE horses (
            horse_id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            type TEXT,
            gender TEXT,
            age BIGINT,
            room_id TEXT  
          )
        ''');

        // halter_devices
        await db.execute('''
          CREATE TABLE halter_devices (
            device_id TEXT PRIMARY KEY,
            status TEXT,
            battery_percent BIGINT,
            horse_id TEXT
          )
        ''');

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
            raw_id BIGINT PRIMARY KEY,
            data TEXT,
            time TEXT
          )
        ''');

        // halter_horse_logs
        await db.execute('''
          CREATE TABLE halter_horse_logs (
            log_id BIGINT PRIMARY KEY,
            message TEXT,
            type TEXT,
            time TEXT,
            device_id TEXT
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
            acce_x DOUBLE,
            acce_y DOUBLE,
            acce_z DOUBLE,
            gyro_x DOUBLE,
            gyro_y DOUBLE,
            gyro_z DOUBLE,
            mag_x DOUBLE,
            mag_y DOUBLE,
            mag_z DOUBLE,
            roll DOUBLE,
            pitch DOUBLE,
            yaw DOUBLE,
            current DOUBLE,
            voltage DOUBLE,
            heart_rate BIGINT,
            spo DOUBLE,
            temperature DOUBLE,
            respiratory_rate DOUBLE,
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
