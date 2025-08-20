import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/dao/cctv_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/halter_device_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/halter_device_detail_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/horse_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/node_room_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/room_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/stable_dao.dart';
import 'package:smart_feeder_desktop/app/data/db/db_helper.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_position_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feed_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_room_device_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/water_model.dart';
import 'package:sqflite/sqflite.dart';

class DataController extends GetxController {
  // Data Stable
  final RxList<StableModel> stableList = <StableModel>[
    // StableModel(
    //   stableId: 'S1',
    //   name: 'Kandang Alpha',
    //   address: 'Jl. Kuda No.1',
    // ),
    // StableModel(
    //   stableId: 'S2',
    //   name: 'Kandang Bravo',
    //   address: 'Jl. Kuda No.2',
    // ),
    // StableModel(
    //   stableId: 'S3',
    //   name: 'Kandang Charlie',
    //   address: 'Jl. Kuda No.3',
    // ),
  ].obs;

  // Data Room
  final RxList<RoomModel> roomList = <RoomModel>[
    // Stable 1
    // RoomModel(
    //   roomId: 'R1',
    //   name: 'Ruangan 1',
    //   deviceSerial: 'SRIPB1223003',
    //   status: 'used',
    //   cctvId: ['CCTV1', 'CCTV2'],
    //   stableId: 'S1',
    //   horseId: 'H1',
    //   remainingWater: 43.0,
    //   remainingFeed: 30.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'penjadwalan',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 1, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R2',
    //   name: 'Ruangan 2',
    //   deviceSerial: 'SRIPB1223002',
    //   status: 'available',
    //   cctvId: ['CCTV3', 'CCTV4'],
    //   stableId: 'S1',
    //   horseId: 'H2',
    //   remainingWater: 21.0,
    //   remainingFeed: 15.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'otomatis',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 2, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R3',
    //   name: 'Ruangan 3',
    //   deviceSerial: 'SRIPB1223001',
    //   status: 'used',
    //   cctvId: ['CCTV5', 'CCTV6'],
    //   stableId: 'S1',
    //   horseId: 'H3',
    //   remainingWater: 11.0,
    //   remainingFeed: 12.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'manual',
    //   lastFeedText: DateTime(2025, 7, 3, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R4',
    //   name: 'Ruangan 4',
    //   deviceSerial: 'SRIPB1223004',
    //   status: 'available',
    //   cctvId: ['CCTV7', 'CCTV8'],
    //   stableId: 'S1',
    //   horseId: 'H4',
    //   remainingWater: 50.0,
    //   remainingFeed: 17.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'penjadwalan',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 4, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R5',
    //   name: 'Ruangan 5',
    //   deviceSerial: 'SRIPB1223005',
    //   status: 'used',
    //   cctvId: ['CCTV9', 'CCTV10'],
    //   stableId: 'S1',
    //   horseId: 'H5',
    //   remainingWater: 18.0,
    //   remainingFeed: 21.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'otomatis',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 5, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R6',
    //   name: 'Ruangan 6',
    //   deviceSerial: 'SRIPB1223006',
    //   status: 'available',
    //   cctvId: ['CCTV11', 'CCTV12'],
    //   stableId: 'S1',
    //   horseId: 'H6',
    //   remainingWater: 26.0,
    //   remainingFeed: 7.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'manual',
    //   lastFeedText: DateTime(2025, 7, 6, 8, 0),
    // ),
    // // Stable 2
    // RoomModel(
    //   roomId: 'R7',
    //   name: 'Ruangan 7',
    //   deviceSerial: 'SRIPB1223007',
    //   status: 'used',
    //   cctvId: ['CCTV13', 'CCTV14'],
    //   stableId: 'S2',
    //   horseId: 'H7',
    //   remainingWater: 10.0,
    //   remainingFeed: 13.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'penjadwalan',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 7, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R8',
    //   name: 'Ruangan 8',
    //   deviceSerial: 'SRIPB1223008',
    //   status: 'available',
    //   cctvId: ['CCTV15', 'CCTV16'],
    //   stableId: 'S2',
    //   horseId: 'H8',
    //   remainingWater: 9.0,
    //   remainingFeed: 6.5,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'otomatis',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 8, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R9',
    //   name: 'Ruangan 9',
    //   deviceSerial: 'SRIPB1223009',
    //   status: 'used',
    //   cctvId: ['CCTV17', 'CCTV18'],
    //   stableId: 'S2',
    //   horseId: 'H9',
    //   remainingWater: 31.0,
    //   remainingFeed: 22.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'manual',
    //   lastFeedText: DateTime(2025, 7, 9, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R10',
    //   name: 'Ruangan 10',
    //   deviceSerial: 'SRIPB1223010',
    //   status: 'available',
    //   cctvId: ['CCTV19', 'CCTV20'],
    //   stableId: 'S2',
    //   horseId: 'H10',
    //   remainingWater: 23.0,
    //   remainingFeed: 20.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'penjadwalan',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 10, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R11',
    //   name: 'Ruangan 11',
    //   deviceSerial: 'SRIPB1223011',
    //   status: 'used',
    //   cctvId: ['CCTV2', 'CCTV3'],
    //   stableId: 'S2',
    //   horseId: 'H11',
    //   remainingWater: 11.0,
    //   remainingFeed: 16.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'otomatis',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 11, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R12',
    //   name: 'Ruangan 12',
    //   deviceSerial: 'SRIPB1223012',
    //   status: 'available',
    //   cctvId: ['CCTV4', 'CCTV5'],
    //   stableId: 'S2',
    //   horseId: 'H12',
    //   remainingWater: 41.0,
    //   remainingFeed: 19.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'manual',
    //   lastFeedText: DateTime(2025, 7, 12, 8, 0),
    // ),
    // // Stable 3
    // RoomModel(
    //   roomId: 'R13',
    //   name: 'Ruangan 13',
    //   deviceSerial: 'SRIPB1223013',
    //   status: 'used',
    //   cctvId: ['CCTV6', 'CCTV7'],
    //   stableId: 'S3',
    //   horseId: 'H13',
    //   remainingWater: 36.0,
    //   remainingFeed: 3.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'penjadwalan',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 13, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R14',
    //   name: 'Ruangan 14',
    //   deviceSerial: 'SRIPB1223014',
    //   status: 'available',
    //   cctvId: ['CCTV8', 'CCTV9'],
    //   stableId: 'S3',
    //   horseId: 'H14',
    //   remainingWater: 24.0,
    //   remainingFeed: 10.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'otomatis',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 14, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R15',
    //   name: 'Ruangan 15',
    //   deviceSerial: 'SRIPB1223015',
    //   status: 'used',
    //   cctvId: ['CCTV10', 'CCTV11'],
    //   stableId: 'S3',
    //   horseId: 'H15',
    //   remainingWater: 14.5,
    //   remainingFeed: 24.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'manual',
    //   lastFeedText: DateTime(2025, 7, 15, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R16',
    //   name: 'Ruangan 16',
    //   deviceSerial: 'SRIPB1223016',
    //   status: 'available',
    //   cctvId: ['CCTV12', 'CCTV13'],
    //   stableId: 'S3',
    //   horseId: 'H16',
    //   remainingWater: 7.0,
    //   remainingFeed: 16.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'penjadwalan',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 16, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R17',
    //   name: 'Ruangan 17',
    //   deviceSerial: 'SRIPB1223017',
    //   status: 'used',
    //   cctvId: ['CCTV14', 'CCTV15'],
    //   stableId: 'S3',
    //   horseId: 'H17',
    //   remainingWater: 6.0,
    //   remainingFeed: 2.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'otomatis',
    //   waterScheduleIntervalHour: 2,
    //   feedScheduleIntervalHour: 3,
    //   lastFeedText: DateTime(2025, 7, 17, 8, 0),
    // ),
    // RoomModel(
    //   roomId: 'R18',
    //   name: 'Ruangan 18',
    //   deviceSerial: 'SRIPB1223018',
    //   status: 'available',
    //   cctvId: ['CCTV16', 'CCTV17'],
    //   stableId: 'S3',
    //   horseId: 'H18',
    //   remainingWater: 39.0,
    //   remainingFeed: 11.0,
    //   waterScheduleType: 'manual',
    //   feedScheduleType: 'manual',
    //   lastFeedText: DateTime(2025, 7, 18, 8, 0),
    // ),
  ].obs;

  // Data Horse
  final RxList<HorseModel> horseList = <HorseModel>[
    // Stable 1
    // HorseModel(
    //   horseId: 'H1',
    //   name: 'Farel',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R1',
    // ),
    // HorseModel(
    //   horseId: 'H2',
    //   name: 'Bella',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R2',
    // ),
    // HorseModel(
    //   horseId: 'H3',
    //   name: 'Jupiter',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R3',
    // ),
    // HorseModel(
    //   horseId: 'H4',
    //   name: 'Mawar',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R4',
    // ),
    // HorseModel(
    //   horseId: 'H5',
    //   name: 'Tornado',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R5',
    // ),
    // HorseModel(
    //   horseId: 'H6',
    //   name: 'Dewi',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R6',
    // ),
    // // Stable 2
    // HorseModel(
    //   horseId: 'H7',
    //   name: 'Raja',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R7',
    // ),
    // HorseModel(
    //   horseId: 'H8',
    //   name: 'Putri',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R8',
    // ),
    // HorseModel(
    //   horseId: 'H9',
    //   name: 'Guntur',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R9',
    // ),
    // HorseModel(
    //   horseId: 'H10',
    //   name: 'Bunga',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R10',
    // ),
    // HorseModel(
    //   horseId: 'H11',
    //   name: 'Bintang',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R11',
    // ),
    // HorseModel(
    //   horseId: 'H12',
    //   name: 'Melati',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R12',
    // ),
    // // Stable 3
    // HorseModel(
    //   horseId: 'H13',
    //   name: 'Satria',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R13',
    // ),
    // HorseModel(
    //   horseId: 'H14',
    //   name: 'Citra',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R14',
    // ),
    // HorseModel(
    //   horseId: 'H15',
    //   name: 'Mega',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R15',
    // ),
    // HorseModel(
    //   horseId: 'H16',
    //   name: 'Embun',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R16',
    // ),
    // HorseModel(
    //   horseId: 'H17',
    //   name: 'Petir',
    //   type: 'local',
    //   gender: 'male',
    //   age: 18,
    //   roomId: 'R17',
    // ),
    // HorseModel(
    //   horseId: 'H18',
    //   name: 'Indah',
    //   type: 'crossbred',
    //   gender: 'female',
    //   age: 18,
    //   roomId: 'R18',
    // ),
  ].obs;

  final RxList<NodeRoomModel> nodeRoomList = <NodeRoomModel>[
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223001',
    //   stableId: 'S1',
    //   roomId: 'R1',
    //   temperature: 25.0,
    //   humidity: 60.0,
    //   lightIntensity: 300.0,
    // ),
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223002',
    //   stableId: 'S1',
    //   roomId: 'R2',
    //   temperature: 26.0,
    //   humidity: 55.0,
    //   lightIntensity: 350.0,
    // ),
  ].obs;

  // Data Log Halter
  final RxList<HalterLogModel> halterLogList = <HalterLogModel>[
    // // Kuda
    // HalterLogModel(
    //   logId: 1,
    //   deviceId: 'SHIPB1223002',
    //   message: 'Suhu kuda terlalu rendah: (27.5°C)',
    //   type: 'temperature',
    //   time: DateTime.now(),
    //   isHigh: false,
    // ),
    // HalterLogModel(
    //   logId: 2,
    //   deviceId: 'SHIPB1223002',
    //   message: 'Kadar oksigen terlalu rendah: (23%)',
    //   type: 'spo',
    //   time: DateTime.now(),
    //   isHigh: false,
    // ),
    // HalterLogModel(
    //   logId: 3,
    //   deviceId: 'SHIPB1223007',
    //   message: 'Kadar oksigen terlalu tinggi: (105%)',
    //   type: 'spo',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),
    // HalterLogModel(
    //   logId: 4,
    //   deviceId: 'SHIPB1223008',
    //   message: 'Suhu kuda terlalu tinggi: (40.2°C)',
    //   type: 'temperature',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),
    // HalterLogModel(
    //   logId: 5,
    //   deviceId: 'SHIPB1223002',
    //   message: 'Detak jantung terlalu rendah: (15 bpm)',
    //   type: 'bpm',
    //   time: DateTime.now(),
    //   isHigh: false,
    // ),
    // HalterLogModel(
    //   logId: 6,
    //   deviceId: 'SHIPB1223002',
    //   message: 'Detak jantung terlalu tinggi: (80 bpm)',
    //   type: 'bpm',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),
    // HalterLogModel(
    //   logId: 7,
    //   deviceId: 'SHIPB1223002',
    //   message: 'Respirasi terlalu tinggi: (30)',
    //   type: 'respirasi',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),

    // // Halter (battery)
    // HalterLogModel(
    //   logId: 8,
    //   deviceId: 'SHIPB1223002',
    //   message: 'Baterai Halter terlalu rendah: (15%)',
    //   type: 'battery',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),

    // // Node Room - Suhu Ruangan
    // HalterLogModel(
    //   logId: 9,
    //   deviceId: 'SRIPB1223002',
    //   message: 'Suhu Ruangan terlalu rendah: (18°C)',
    //   type: 'room_temperature',
    //   time: DateTime.now(),
    //   isHigh: false,
    // ),
    // HalterLogModel(
    //   logId: 10,
    //   deviceId: 'SRIPB1223002',
    //   message: 'Suhu Ruangan terlalu tinggi: (40°C)',
    //   type: 'room_temperature',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),

    // // Node Room - Kelembapan
    // HalterLogModel(
    //   logId: 11,
    //   deviceId: 'SRIPB1223002',
    //   message: 'Kelembapan Ruangan terlalu rendah: (35%)',
    //   type: 'humidity',
    //   time: DateTime.now(),
    //   isHigh: false,
    // ),
    // HalterLogModel(
    //   logId: 12,
    //   deviceId: 'SRIPB1223002',
    //   message: 'Kelembapan Ruangan terlalu tinggi: (90%)',
    //   type: 'humidity',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),

    // // Node Room - Intensitas cahaya
    // HalterLogModel(
    //   logId: 13,
    //   deviceId: 'SRIPB1223003',
    //   message: 'Intensitas cahaya Ruangan terlalu rendah: (50 lux)',
    //   type: 'light_intensity',
    //   time: DateTime.now(),
    //   isHigh: false,
    // ),
    // HalterLogModel(
    //   logId: 14,
    //   deviceId: 'SRIPB1223003',
    //   message: 'Intensitas cahaya Ruangan terlalu tinggi: (2000 lux)',
    //   type: 'light_intensity',
    //   time: DateTime.now(),
    //   isHigh: true,
    // ),
  ].obs;

  // Data Feeder Room Device
  final RxList<FeederRoomDeviceModel> feederRoomDeviceList =
      <FeederRoomDeviceModel>[
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223005',
        //   roomId: 'R1',
        //   status: 'on',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223006',
        //   roomId: 'R2',
        //   status: 'off',
        //   type: 'sensor',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223007',
        //   roomId: 'R3',
        //   status: 'on',
        //   type: 'gateway',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223008',
        //   roomId: 'R4',
        //   status: 'off',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223009',
        //   roomId: 'R5',
        //   status: 'on',
        //   type: 'sensor',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223010',
        //   roomId: 'R6',
        //   status: 'off',
        //   type: 'gateway',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223011',
        //   roomId: 'R7',
        //   status: 'on',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223012',
        //   roomId: 'R8',
        //   status: 'off',
        //   type: 'sensor',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223013',
        //   roomId: 'R9',
        //   status: 'on',
        //   type: 'gateway',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223014',
        //   roomId: 'R10',
        //   status: 'off',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223015',
        //   roomId: 'R11',
        //   status: 'on',
        //   type: 'sensor',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223016',
        //   roomId: 'R12',
        //   status: 'off',
        //   type: 'gateway',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223017',
        //   roomId: 'R13',
        //   status: 'on',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223018',
        //   roomId: 'R14',
        //   status: 'off',
        //   type: 'sensor',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223019',
        //   roomId: 'R15',
        //   status: 'on',
        //   type: 'gateway',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223020',
        //   roomId: 'R16',
        //   status: 'off',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223021',
        //   roomId: 'R17',
        //   status: 'on',
        //   type: 'sensor',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223022',
        //   roomId: 'R18',
        //   status: 'off',
        //   type: 'gateway',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223023',
        //   roomId: 'R19',
        //   status: 'on',
        //   type: 'actuator',
        // ),
        // FeederRoomDeviceModel(
        //   deviceId: 'SFIPB1223024',
        //   roomId: 'R20',
        //   status: 'off',
        //   type: 'sensor',
        // ),
      ].obs;

  // Data Feeder Device
  final RxList<FeederDeviceModel> feederDeviceList = <FeederDeviceModel>[
    // FeederDeviceModel(
    //   deviceId: 'feeder1',
    //   current: 1.5,
    //   voltage: 220.0,
    //   power: 330.0,
    //   status: 'ready',
    //   batteryPercent: 87,
    // ),
  ].obs;

  // Data History Entry
  final RxList<HistoryEntryModel> historyEntryList = <HistoryEntryModel>[
    // Stable 1, Room R1-R6
    // HistoryEntryModel(
    //   historyId: 'HIST1',
    //   stableId: 'S1',
    //   roomId: 'R1',
    //   time: DateTime(2025, 7, 1, 8, 0),
    //   scheduleType: 'penjadwalan',
    //   feed: 38.2,
    //   water: 4.2,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST2',
    //   stableId: 'S1',
    //   roomId: 'R2',
    //   time: DateTime(2025, 7, 2, 8, 0),
    //   scheduleType: 'otomatis',
    //   feed: 40.1,
    //   water: 3.8,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST3',
    //   stableId: 'S1',
    //   roomId: 'R3',
    //   time: DateTime(2025, 7, 3, 8, 0),
    //   scheduleType: 'manual',
    //   feed: 25.7,
    //   water: 2.6,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST4',
    //   stableId: 'S1',
    //   roomId: 'R4',
    //   time: DateTime(2025, 7, 4, 8, 0),
    //   scheduleType: 'penjadwalan',
    //   feed: 22.5,
    //   water: 1.9,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST5',
    //   stableId: 'S1',
    //   roomId: 'R5',
    //   time: DateTime(2025, 7, 5, 8, 0),
    //   scheduleType: 'otomatis',
    //   feed: 18.4,
    //   water: 4.7,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST6',
    //   stableId: 'S1',
    //   roomId: 'R6',
    //   time: DateTime(2025, 7, 6, 8, 0),
    //   scheduleType: 'manual',
    //   feed: 41.9,
    //   water: 5.5,
    // ),

    // // Stable 2, Room R7-R12
    // HistoryEntryModel(
    //   historyId: 'HIST7',
    //   stableId: 'S2',
    //   roomId: 'R7',
    //   time: DateTime(2025, 7, 7, 8, 0),
    //   scheduleType: 'penjadwalan',
    //   feed: 37.4,
    //   water: 4.8,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST8',
    //   stableId: 'S2',
    //   roomId: 'R8',
    //   time: DateTime(2025, 7, 8, 8, 0),
    //   scheduleType: 'otomatis',
    //   feed: 29.5,
    //   water: 5.1,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST9',
    //   stableId: 'S2',
    //   roomId: 'R9',
    //   time: DateTime(2025, 7, 9, 8, 0),
    //   scheduleType: 'manual',
    //   feed: 26.0,
    //   water: 2.9,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST10',
    //   stableId: 'S2',
    //   roomId: 'R10',
    //   time: DateTime(2025, 7, 10, 8, 0),
    //   scheduleType: 'penjadwalan',
    //   feed: 21.1,
    //   water: 2.1,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST11',
    //   stableId: 'S2',
    //   roomId: 'R11',
    //   time: DateTime(2025, 7, 11, 8, 0),
    //   scheduleType: 'otomatis',
    //   feed: 39.8,
    //   water: 4.0,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST12',
    //   stableId: 'S2',
    //   roomId: 'R12',
    //   time: DateTime(2025, 7, 12, 8, 0),
    //   scheduleType: 'manual',
    //   feed: 27.7,
    //   water: 3.3,
    // ),

    // // Stable 3, Room R13-R18
    // HistoryEntryModel(
    //   historyId: 'HIST13',
    //   stableId: 'S3',
    //   roomId: 'R13',
    //   time: DateTime(2025, 7, 13, 8, 0),
    //   scheduleType: 'penjadwalan',
    //   feed: 23.4,
    //   water: 2.4,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST14',
    //   stableId: 'S3',
    //   roomId: 'R14',
    //   time: DateTime(2025, 7, 14, 8, 0),
    //   scheduleType: 'otomatis',
    //   feed: 31.5,
    //   water: 5.8,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST15',
    //   stableId: 'S3',
    //   roomId: 'R15',
    //   time: DateTime(2025, 7, 15, 8, 0),
    //   scheduleType: 'manual',
    //   feed: 35.6,
    //   water: 4.5,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST16',
    //   stableId: 'S3',
    //   roomId: 'R16',
    //   time: DateTime(2025, 7, 16, 8, 0),
    //   scheduleType: 'penjadwalan',
    //   feed: 33.9,
    //   water: 6.2,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST17',
    //   stableId: 'S3',
    //   roomId: 'R17',
    //   time: DateTime(2025, 7, 17, 8, 0),
    //   scheduleType: 'otomatis',
    //   feed: 42.2,
    //   water: 7.0,
    // ),
    // HistoryEntryModel(
    //   historyId: 'HIST18',
    //   stableId: 'S3',
    //   roomId: 'R18',
    //   time: DateTime(2025, 7, 18, 8, 0),
    //   scheduleType: 'manual',
    //   feed: 19.8,
    //   water: 2.0,
    // ),
  ].obs;

  // Data Health Horse
  final RxList<HorseHealthModel> horseHealthList = <HorseHealthModel>[
    // HorseHealthModel(
    //   healthId: 'HEALTH1',
    //   horseId: 'H1',
    //   heartRate: 38,
    //   bodyTemp: 37.2,
    //   oxygen: 98.5,
    //   respiration: 18,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 98.0,
    //   batteryPercent: 90,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH2',
    //   horseId: 'H2',
    //   heartRate: 41,
    //   bodyTemp: 38.0,
    //   oxygen: 97.2,
    //   respiration: 17,
    //   posture: "Tidur",
    //   postureAccuracy: 94.2,
    //   batteryPercent: 80,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH3',
    //   horseId: 'H3',
    //   heartRate: 36,
    //   bodyTemp: 37.9,
    //   oxygen: 98.8,
    //   respiration: 19,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 96.8,
    //   batteryPercent: 85,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH4',
    //   horseId: 'H4',
    //   heartRate: 39,
    //   bodyTemp: 37.1,
    //   oxygen: 99.2,
    //   respiration: 16,
    //   posture: "Tidur",
    //   postureAccuracy: 92.3,
    //   batteryPercent: 78,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH5',
    //   horseId: 'H5',
    //   heartRate: 37,
    //   bodyTemp: 36.8,
    //   oxygen: 95.8,
    //   respiration: 20,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 99.0,
    //   batteryPercent: 95,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH6',
    //   horseId: 'H6',
    //   heartRate: 42,
    //   bodyTemp: 37.5,
    //   oxygen: 97.5,
    //   respiration: 15,
    //   posture: "Tidur",
    //   postureAccuracy: 98.5,
    //   batteryPercent: 77,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH7',
    //   horseId: 'H7',
    //   heartRate: 35,
    //   bodyTemp: 37.6,
    //   oxygen: 98.1,
    //   respiration: 20,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 97.8,
    //   batteryPercent: 89,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH8',
    //   horseId: 'H8',
    //   heartRate: 44,
    //   bodyTemp: 39.0,
    //   oxygen: 98.2,
    //   respiration: 18,
    //   posture: "Tidur",
    //   postureAccuracy: 95.7,
    //   batteryPercent: 64,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH9',
    //   horseId: 'H9',
    //   heartRate: 40,
    //   bodyTemp: 36.9,
    //   oxygen: 96.7,
    //   respiration: 19,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 98.3,
    //   batteryPercent: 91,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH10',
    //   horseId: 'H10',
    //   heartRate: 38,
    //   bodyTemp: 37.8,
    //   oxygen: 99.1,
    //   respiration: 16,
    //   posture: "Tidur",
    //   postureAccuracy: 92.8,
    //   batteryPercent: 75,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH11',
    //   horseId: 'H11',
    //   heartRate: 36,
    //   bodyTemp: 37.4,
    //   oxygen: 98.0,
    //   respiration: 18,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 97.9,
    //   batteryPercent: 82,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH12',
    //   horseId: 'H12',
    //   heartRate: 41,
    //   bodyTemp: 38.5,
    //   oxygen: 97.9,
    //   respiration: 20,
    //   posture: "Tidur",
    //   postureAccuracy: 93.4,
    //   batteryPercent: 83,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH13',
    //   horseId: 'H13',
    //   heartRate: 39,
    //   bodyTemp: 36.7,
    //   oxygen: 97.3,
    //   respiration: 17,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 98.1,
    //   batteryPercent: 88,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH14',
    //   horseId: 'H14',
    //   heartRate: 43,
    //   bodyTemp: 38.2,
    //   oxygen: 98.6,
    //   respiration: 19,
    //   posture: "Tidur",
    //   postureAccuracy: 92.2,
    //   batteryPercent: 79,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH15',
    //   horseId: 'H15',
    //   heartRate: 40,
    //   bodyTemp: 37.5,
    //   oxygen: 99.0,
    //   respiration: 20,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 99.8,
    //   batteryPercent: 97,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH16',
    //   horseId: 'H16',
    //   heartRate: 38,
    //   bodyTemp: 36.9,
    //   oxygen: 95.9,
    //   respiration: 15,
    //   posture: "Tidur",
    //   postureAccuracy: 97.4,
    //   batteryPercent: 74,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH17',
    //   horseId: 'H17',
    //   heartRate: 37,
    //   bodyTemp: 37.2,
    //   oxygen: 98.6,
    //   respiration: 17,
    //   posture: "Berdiri Kepala Tegak",
    //   postureAccuracy: 97.2,
    //   batteryPercent: 83,
    // ),
    // HorseHealthModel(
    //   healthId: 'HEALTH18',
    //   horseId: 'H18',
    //   heartRate: 35,
    //   bodyTemp: 37.8,
    //   oxygen: 99.3,
    //   respiration: 18,
    //   posture: "Tidur",
    //   postureAccuracy: 98.2,
    //   batteryPercent: 92,
    // ),
  ].obs;

  // Data Feed
  final RxList<FeedModel> feedList = <FeedModel>[
    // FeedModel(feedId: 'F1', name: 'Pakan A', type: 'hijauan', stock: 100.0),
    // FeedModel(feedId: 'F2', name: 'Pakan B', type: 'konsentrat', stock: 50.0),
    // FeedModel(feedId: 'F3', name: 'Pakan C', type: 'hijauan', stock: 75.0),
    // FeedModel(feedId: 'F4', name: 'Pakan D', type: 'konsentrat', stock: 62.0),
    // FeedModel(feedId: 'F5', name: 'Pakan E', type: 'hijauan', stock: 80.0),
    // FeedModel(feedId: 'F6', name: 'Pakan F', type: 'konsentrat', stock: 55.0),
    // FeedModel(feedId: 'F7', name: 'Pakan G', type: 'hijauan', stock: 90.0),
    // FeedModel(feedId: 'F8', name: 'Pakan H', type: 'konsentrat', stock: 70.0),
    // FeedModel(feedId: 'F9', name: 'Pakan I', type: 'hijauan', stock: 78.0),
    // FeedModel(feedId: 'F10', name: 'Pakan J', type: 'konsentrat', stock: 80.0),
    // FeedModel(feedId: 'F11', name: 'Pakan K', type: 'hijauan', stock: 60.0),
    // FeedModel(feedId: 'F12', name: 'Pakan L', type: 'konsentrat', stock: 71.0),
    // FeedModel(feedId: 'F13', name: 'Pakan M', type: 'hijauan', stock: 93.0),
    // FeedModel(feedId: 'F14', name: 'Pakan N', type: 'konsentrat', stock: 86.0),
    // FeedModel(feedId: 'F15', name: 'Pakan O', type: 'hijauan', stock: 65.0),
    // FeedModel(feedId: 'F16', name: 'Pakan P', type: 'konsentrat', stock: 59.0),
    // FeedModel(feedId: 'F17', name: 'Pakan Q', type: 'hijauan', stock: 85.0),
    // FeedModel(feedId: 'F18', name: 'Pakan R', type: 'konsentrat', stock: 67.0),
    // FeedModel(feedId: 'F19', name: 'Pakan S', type: 'hijauan', stock: 95.0),
    // FeedModel(feedId: 'F20', name: 'Pakan T', type: 'konsentrat', stock: 77.0),
  ].obs;

  // Data Water
  final RxList<WaterModel> waterList = <WaterModel>[
    // WaterModel(waterId: 'W1', name: 'Tandon A', stock: 100.0),
    // WaterModel(waterId: 'W2', name: 'Tandon B', stock: 80.0),
    // WaterModel(waterId: 'W3', name: 'Tandon C', stock: 90.0),
    // WaterModel(waterId: 'W4', name: 'Tandon D', stock: 70.0),
    // WaterModel(waterId: 'W5', name: 'Tandon E', stock: 60.0),
    // WaterModel(waterId: 'W6', name: 'Tandon F', stock: 85.0),
    // WaterModel(waterId: 'W7', name: 'Tandon G', stock: 98.0),
    // WaterModel(waterId: 'W8', name: 'Tandon H', stock: 120.0),
    // WaterModel(waterId: 'W9', name: 'Tandon I', stock: 88.0),
    // WaterModel(waterId: 'W10', name: 'Tandon J', stock: 75.0),
    // WaterModel(waterId: 'W11', name: 'Tandon K', stock: 110.0),
    // WaterModel(waterId: 'W12', name: 'Tandon L', stock: 95.0),
    // WaterModel(waterId: 'W13', name: 'Tandon M', stock: 78.0),
    // WaterModel(waterId: 'W14', name: 'Tandon N', stock: 104.0),
    // WaterModel(waterId: 'W15', name: 'Tandon O', stock: 115.0),
    // WaterModel(waterId: 'W16', name: 'Tandon P', stock: 99.0),
    // WaterModel(waterId: 'W17', name: 'Tandon Q', stock: 93.0),
    // WaterModel(waterId: 'W18', name: 'Tandon R', stock: 79.0),
    // WaterModel(waterId: 'W19', name: 'Tandon S', stock: 85.0),
    // WaterModel(waterId: 'W20', name: 'Tandon T', stock: 102.0),
  ].obs;

  // Data Halter Device
  final RxList<HalterDeviceModel> halterDeviceList = <HalterDeviceModel>[
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223002',
    //   horseId: 'H1',
    //   status: 'on',
    //   batteryPercent: 87,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223006',
    //   horseId: null,
    //   status: 'off',
    //   batteryPercent: 35,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223003',
    //   horseId: 'H2',
    //   status: 'on',
    //   batteryPercent: 73,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223008',
    //   horseId: 'H3',
    //   status: 'off',
    //   batteryPercent: 19,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223009',
    //   horseId: 'H4',
    //   status: 'on',
    //   batteryPercent: 66,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223010',
    //   horseId: null,
    //   status: 'off',
    //   batteryPercent: 42,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223011',
    //   horseId: 'H5',
    //   status: 'on',
    //   batteryPercent: 91,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223012',
    //   horseId: null,
    //   status: 'off',
    //   batteryPercent: 25,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223013',
    //   horseId: 'H6',
    //   status: 'on',
    //   batteryPercent: 54,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223014',
    //   horseId: 'H7',
    //   status: 'off',
    //   batteryPercent: 77,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223015',
    //   horseId: 'H8',
    //   status: 'on',
    //   batteryPercent: 68,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223016',
    //   horseId: 'H9',
    //   status: 'off',
    //   batteryPercent: 31,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223017',
    //   horseId: 'H10',
    //   status: 'on',
    //   batteryPercent: 81,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223018',
    //   horseId: null,
    //   status: 'off',
    //   batteryPercent: 58,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223019',
    //   horseId: 'H11',
    //   status: 'on',
    //   batteryPercent: 94,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223020',
    //   horseId: 'H12',
    //   status: 'off',
    //   batteryPercent: 21,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223021',
    //   horseId: 'H13',
    //   status: 'on',
    //   batteryPercent: 49,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223022',
    //   horseId: 'H14',
    //   status: 'off',
    //   batteryPercent: 64,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223023',
    //   horseId: 'H15',
    //   status: 'on',
    //   batteryPercent: 76,
    // ),
    // HalterDeviceModel(
    //   deviceId: 'SHIPB1223024',
    //   horseId: null,
    //   status: 'off',
    //   batteryPercent: 28,
    // ),
  ].obs;

  // Data CCTV
  final RxList<CctvModel> cctvList = <CctvModel>[
    // CctvModel(
    //   cctvId: 'CCTV1',
    //   ipAddress: '172.19.0.193',
    //   port: 8000,
    //   username: 'admin',
    //   password: 'fkh12345',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV2',
    //   ipAddress: '172.19.0.194',
    //   port: 8001,
    //   username: 'admin2',
    //   password: 'fkh12346',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV3',
    //   ipAddress: '172.19.0.195',
    //   port: 8002,
    //   username: 'admin3',
    //   password: 'fkh12347',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV4',
    //   ipAddress: '172.19.0.196',
    //   port: 8003,
    //   username: 'admin4',
    //   password: 'fkh12348',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV5',
    //   ipAddress: '172.19.0.197',
    //   port: 8004,
    //   username: 'admin5',
    //   password: 'fkh12349',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV6',
    //   ipAddress: '172.19.0.198',
    //   port: 8005,
    //   username: 'admin6',
    //   password: 'fkh12350',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV7',
    //   ipAddress: '172.19.0.199',
    //   port: 8006,
    //   username: 'admin7',
    //   password: 'fkh12351',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV8',
    //   ipAddress: '172.19.0.200',
    //   port: 8007,
    //   username: 'admin8',
    //   password: 'fkh12352',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV9',
    //   ipAddress: '172.19.0.201',
    //   port: 8008,
    //   username: 'admin9',
    //   password: 'fkh12353',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV10',
    //   ipAddress: '172.19.0.202',
    //   port: 8009,
    //   username: 'admin10',
    //   password: 'fkh12354',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV11',
    //   ipAddress: '172.19.0.203',
    //   port: 8010,
    //   username: 'admin11',
    //   password: 'fkh12355',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV12',
    //   ipAddress: '172.19.0.204',
    //   port: 8011,
    //   username: 'admin12',
    //   password: 'fkh12356',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV13',
    //   ipAddress: '172.19.0.205',
    //   port: 8012,
    //   username: 'admin13',
    //   password: 'fkh12357',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV14',
    //   ipAddress: '172.19.0.206',
    //   port: 8013,
    //   username: 'admin14',
    //   password: 'fkh12358',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV15',
    //   ipAddress: '172.19.0.207',
    //   port: 8014,
    //   username: 'admin15',
    //   password: 'fkh12359',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV16',
    //   ipAddress: '172.19.0.208',
    //   port: 8015,
    //   username: 'admin16',
    //   password: 'fkh12360',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV17',
    //   ipAddress: '172.19.0.209',
    //   port: 8016,
    //   username: 'admin17',
    //   password: 'fkh12361',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV18',
    //   ipAddress: '172.19.0.210',
    //   port: 8017,
    //   username: 'admin18',
    //   password: 'fkh12362',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV19',
    //   ipAddress: '172.19.0.211',
    //   port: 8018,
    //   username: 'admin19',
    //   password: 'fkh12363',
    // ),
    // CctvModel(
    //   cctvId: 'CCTV20',
    //   ipAddress: '172.19.0.212',
    //   port: 8019,
    //   username: 'admin20',
    //   password: 'fkh12364',
    // ),
  ].obs;

  // Data Raw Halter
  // RxList<HalterRawDataModel> dataSerialList = <HalterRawDataModel>[
  //   // HalterRawDataModel(
  //   //   rawId: 1,
  //   //   data:
  //   //       "SHIPB1223004,-6.967736500,107.659127167,683.50,0.00,211.00,1.79,-0.40,10.20,-0.00,0.00,0.00,-15.62,45.94,17.79,-10,-177,-66,NAN,0.00,0.00,0.00,29.77,*",
  //   //   time: DateTime(2025, 7, 22, 12, 0),
  //   // ),
  //   // HalterRawDataModel(
  //   //   rawId: 2,
  //   //   data:
  //   //       "SHIPB1223005,-6.967800,107.659200,700.12,1.00,205.00,1.81,-0.30,15.30,-0.10,0.10,0.00,-12.62,48.94,14.79,-12,-150,-60,NAN,1.00,1.00,1.00,28.77,*",
  //   //   time: DateTime(2025, 7, 22, 12, 0),
  //   // ),
  //   // HalterRawDataModel(
  //   //   rawId: 3,
  //   //   data:
  //   //       "SHIPB1223006,-6.968000,107.659300,710.00,2.00,220.00,2.00,-0.20,11.20,-0.20,0.20,0.10,-14.00,46.00,18.00,-14,-160,-70,NAN,2.00,2.00,2.00,30.00,*",
  //   //   time: DateTime(2025, 7, 22, 12, 0),
  //   // ),
  // ].obs;

  final RxList<HalterRawDataModel> rawData = <HalterRawDataModel>[].obs;

  final RxList<HalterDeviceDetailModel> detailHistory =
      <HalterDeviceDetailModel>[].obs;

  final RxList<HalterBiometricRuleEngineModel> biometricClassificationList =
      <HalterBiometricRuleEngineModel>[].obs;

  final RxList<HalterPositionRuleEngineModel> positionClassificationList =
      <HalterPositionRuleEngineModel>[].obs;

  Future<void> initAllDaosAndLoadAll() async {
    final db = await DBHelper.database;
    initNodeRoomDao(db);
    initRoomDao(db);
    initStableDao(db);
    initHorseDao(db);
    initHalterDeviceDao(db);
    initCctvDao(db);
    initHalterDeviceDetailDao(db);
    // dst...
    await Future.wait([
      loadNodeRoomsFromDb(),
      loadRoomsFromDb(),
      loadStablesFromDb(),
      loadHorsesFromDb(),
      loadHalterDevicesFromDb(),
      loadCctvsFromDb(),
      loadAllHalterDeviceDetails(),
      // dst...
    ]);
  }

  // Data Stable
  late StableDao stableDao;

  void initStableDao(Database db) {
    stableDao = StableDao(db);
  }

  // Future<void> loadAllFromDb() async {
  //   final stable = await stableDao.getAll();
  //   stableList.assignAll(stable);
  // }

  /// Muat data dari DB ke stableList
  Future<void> loadStablesFromDb() async {
    final list = await stableDao.getAll();
    stableList.assignAll(list);
  }

  Future<void> addStable(StableModel model) async {
    await stableDao.insert(model);
    await loadStablesFromDb();
  }

  Future<void> updateStable(StableModel model) async {
    await stableDao.update(model);
    await loadStablesFromDb();
  }

  Future<void> deleteStable(String stableId) async {
    await stableDao.delete(stableId);
    await loadStablesFromDb();
  }

  // Data Room
  late RoomDao roomDao;

  void initRoomDao(Database db) {
    roomDao = RoomDao(db);
  }

  /// Muat data rooms dari DB ke roomList
  Future<void> loadRoomsFromDb() async {
    final list = await roomDao.getAll();
    roomList.assignAll(list);
  }

  Future<void> addRoom(RoomModel model) async {
    await roomDao.insert(model);
    await loadRoomsFromDb();
  }

  Future<void> updateRoom(RoomModel model) async {
    await roomDao.update(model);
    await loadRoomsFromDb();
  }

  Future<void> updateRoomScheduleFlexible(
    String roomId, {
    String? waterScheduleType,
    int? waterScheduleIntervalHour,
    String? feedScheduleType,
    int? feedScheduleIntervalHour,
  }) async {
    await roomDao.updateRoomScheduleFlexible(
      roomId,
      waterScheduleType: waterScheduleType,
      waterScheduleIntervalHour: waterScheduleIntervalHour,
      feedScheduleType: feedScheduleType,
      feedScheduleIntervalHour: feedScheduleIntervalHour,
    );
    await loadRoomsFromDb();
  }

  Future<void> deleteRoom(String roomId) async {
    await roomDao.delete(roomId);
    await loadRoomsFromDb();
  }

  /// Generate next RoomId (misal "RM001")
  Future<String> getNextRoomId() async {
    final list = await roomDao.getAll();
    if (list.isEmpty) return "R001";
    final lastIdNum = list
        .map(
          (r) => int.tryParse(r.roomId.replaceAll(RegExp('[^0-9]'), '')) ?? 0,
        )
        .fold<int>(0, (prev, el) => el > prev ? el : prev);
    final nextNum = lastIdNum + 1;
    return "R${nextNum.toString().padLeft(3, '0')}";
  }

  // Data Horse
  late HorseDao horseDao;

  void initHorseDao(Database db) {
    horseDao = HorseDao(db);
  }

  /// Muat data horses dari DB ke horseList
  Future<void> loadHorsesFromDb() async {
    final list = await horseDao.getAll();
    horseList.assignAll(list);
  }

  Future<void> addHorse(HorseModel model) async {
    await horseDao.insert(model);

    if (model.roomId != null && model.roomId!.isNotEmpty) {
      // Jika horse memiliki room_id, update room tersebut
      await roomDao.updateHorseId(model.roomId!, model.horseId);
    }

    await loadHorsesFromDb();
    await loadRoomsFromDb();
  }

  Future<void> updateHorse(HorseModel model) async {
    // Ambil data horse sebelum update
    final old = await horseDao.getById(model.horseId);

    // Update tabel horses
    await horseDao.update(model);

    // Jika room_id berubah, update tabel rooms juga
    if (model.roomId != null && model.roomId!.isNotEmpty) {
      // 1. Kosongkan horse_id di room lama (jika ada dan beda dengan yg sekarang)
      if (old != null && old.roomId != null && old.roomId != model.roomId) {
        await roomDao.updateHorseId(old.roomId!, null);
      }
      // 2. Isi horse_id di room baru
      await roomDao.updateHorseId(model.roomId!, model.horseId);
    } else if (old != null && old.roomId != null) {
      // Jika kuda dilepas dari ruangan, kosongkan horse_id di room lama
      await roomDao.updateHorseId(old.roomId!, null);
    }

    await loadHorsesFromDb();
    await loadRoomsFromDb();
  }

  Future<void> detachHorseFromRoom(String horseId) async {
    await roomDao.clearHorseIdInRooms(horseId);
    await loadHorsesFromDb();
    await loadRoomsFromDb();
  }

  Future<void> assignHorseToRoom(String horseId, String roomId) async {
    await roomDao.updateHorseId(roomId, horseId);
    await loadHorsesFromDb();
    await loadRoomsFromDb();
  }

  Future<void> deleteHorse(String horseId) async {
    // 1. Kosongkan horseId di tabel rooms yang menunjuk ke horseId ini
    await roomDao.clearHorseIdInRooms(horseId);

    // 2. Hapus dari tabel horses
    await horseDao.delete(horseId);

    // 3. Refresh data (kalau pakai RxList)
    await loadHorsesFromDb();
    await loadRoomsFromDb();
  }

  /// Ambil semua data horse (untuk next ID, dsb)
  Future<List<HorseModel>> getAllHorses() async {
    return await horseDao.getAll();
  }

  /// Generate next HorseId (misal "H001")
  Future<String> getNextHorseId() async {
    final list = await horseDao.getAll();
    if (list.isEmpty) return "H001";
    final lastIdNum = list
        .map(
          (h) => int.tryParse(h.horseId.replaceAll(RegExp('[^0-9]'), '')) ?? 0,
        )
        .fold<int>(0, (prev, el) => el > prev ? el : prev);
    final nextNum = lastIdNum + 1;
    return "H${nextNum.toString().padLeft(3, '0')}";
  }

  // Data Halter Device

  late HalterDeviceDao halterDeviceDao;

  void initHalterDeviceDao(Database db) {
    halterDeviceDao = HalterDeviceDao(db);
  }

  Future<void> addHalterDevice(HalterDeviceModel model) async {
    await halterDeviceDao.insert(model);
    await loadHalterDevicesFromDb();
  }

  Future<void> loadHalterDevicesFromDb() async {
    final allDevices = await halterDeviceDao.getAll();
    halterDeviceList.assignAll(allDevices);
  }

  Future<void> updateHalterDevice(HalterDeviceModel model) async {
    await halterDeviceDao.update(model);
    await loadHalterDevicesFromDb();
  }

  Future<void> deleteHalterDevice(String deviceId) async {
    await halterDeviceDao.delete(deviceId);
    await loadHalterDevicesFromDb();
  }

  // Data Node Room
  late NodeRoomDao nodeRoomDao;

  void initNodeRoomDao(Database db) {
    nodeRoomDao = NodeRoomDao(db);
  }

  Future<void> loadNodeRoomsFromDb() async {
    final list = await nodeRoomDao.getAll();
    nodeRoomList.assignAll(list);
  }

  Future<void> addNodeRoom(NodeRoomModel model) async {
    await nodeRoomDao.insert(model);
    await loadNodeRoomsFromDb();
  }

  Future<void> updateNodeRoom(NodeRoomModel model) async {
    await nodeRoomDao.update(model);
    await loadNodeRoomsFromDb();
  }

  Future<void> deleteNodeRoom(String nodeId) async {
    await nodeRoomDao.deleteByDeviceId(nodeId);
    await loadNodeRoomsFromDb();
  }

  Future<void> assignNodeToRoom(String nodeDeviceId, String roomId) async {
    // 1. Kosongkan deviceSerial di semua room yang deviceSerial == nodeDeviceId
    await roomDao.clearDeviceSerialInRooms(nodeDeviceId);

    // 2. Set deviceSerial di room yang dipilih
    await roomDao.updateDeviceSerial(roomId, nodeDeviceId);

    // 3. Refresh list
    await loadRoomsFromDb();
  }

  Future<void> detachNodeFromRoom(String nodeDeviceId) async {
    // Kosongkan deviceSerial di semua room yang deviceSerial == nodeDeviceId
    await roomDao.clearDeviceSerialInRooms(nodeDeviceId);
    await loadRoomsFromDb();
  }

  // Data Cctv

  late CctvDao cctvDao;

  void initCctvDao(Database db) {
    cctvDao = CctvDao(db);
  }

  Future<void> loadCctvsFromDb() async {
    final list = await cctvDao.getAll();
    cctvList.assignAll(list);
  }

  Future<void> addCctv(CctvModel model) async {
    await cctvDao.insert(model);
    await loadCctvsFromDb();
  }

  Future<void> updateCctv(CctvModel model) async {
    await cctvDao.update(model);
    await loadCctvsFromDb();
  }

  Future<void> deleteCctv(String cctvId) async {
    await cctvDao.delete(cctvId);
    await loadCctvsFromDb();
  }

  // Data Detail Halter

  late HalterDeviceDetailDao halterDeviceDetailDao;

  void initHalterDeviceDetailDao(Database db) {
    halterDeviceDetailDao = HalterDeviceDetailDao(db);
  }

  Future<void> addHalterDeviceDetail(HalterDeviceDetailModel detail) async {
    await halterDeviceDetailDao.insertDetail(detail);
    // if (detailHistory.length > 1000) {
    //   detailHistory.removeLast();
    // }
    await loadAllHalterDeviceDetails();
  }

  Future<void> updateHalterDeviceDetail(HalterDeviceDetailModel detail) async {
    await halterDeviceDetailDao.updateDetail(detail);
    final index = detailHistory.indexWhere(
      (d) => d.detailId == detail.detailId,
    );
    if (index != -1) {
      detailHistory[index] = detail;
    }
  }

  Future<void> deleteHalterDeviceDetail(int detailId) async {
    await halterDeviceDetailDao.deleteDetail(detailId);
    detailHistory.removeWhere((d) => d.detailId == detailId);
  }

  Future<void> loadAllHalterDeviceDetails() async {
    final all = await halterDeviceDetailDao.getAllDetails();
    detailHistory.assignAll(all);
  }

  Future<void> clearAllHalterDeviceDetails() async {
    await halterDeviceDetailDao.clearAll();
    detailHistory.clear();
  }
}
