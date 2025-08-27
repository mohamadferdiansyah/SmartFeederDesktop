import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/dao/cctv_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/halter_device_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/halter_device_detail_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/halter_device_power_log_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/horse_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/node_room_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/room_dao.dart';
import 'package:smart_feeder_desktop/app/data/dao/stable_dao.dart';
import 'package:smart_feeder_desktop/app/data/db/db_helper.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_power_log_model.dart';
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
  final RxList<StableModel> stableList = <StableModel>[].obs;

  // Data Room
  final RxList<RoomModel> roomList = <RoomModel>[].obs;

  // Data Horse
  final RxList<HorseModel> horseList = <HorseModel>[].obs;

  final RxList<NodeRoomModel> nodeRoomList = <NodeRoomModel>[].obs;

  // Data Log Halter
  final RxList<HalterLogModel> halterLogList = <HalterLogModel>[].obs;

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
  final RxList<HorseHealthModel> horseHealthList = <HorseHealthModel>[].obs;

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
  final RxList<HalterDeviceModel> halterDeviceList = <HalterDeviceModel>[].obs;

  // Data CCTV
  final RxList<CctvModel> cctvList = <CctvModel>[].obs;

  final RxList<HalterRawDataModel> rawData = <HalterRawDataModel>[].obs;

  final RxList<HalterDeviceDetailModel> detailHistory =
      <HalterDeviceDetailModel>[].obs;

  final RxList<HalterDeviceDetailModel> rawDetailHistoryList =
      <HalterDeviceDetailModel>[].obs;

  final RxList<HalterBiometricRuleEngineModel> biometricClassificationList =
      <HalterBiometricRuleEngineModel>[].obs;

  final RxList<HalterPositionRuleEngineModel> positionClassificationList =
      <HalterPositionRuleEngineModel>[].obs;

  final RxList<HalterDevicePowerLogModel> halterDeviceLogList =
      <HalterDevicePowerLogModel>[].obs;

  Future<void> initAllDaosAndLoadAll() async {
    final db = await DBHelper.database;
    initNodeRoomDao(db);
    initRoomDao(db);
    initStableDao(db);
    initHorseDao(db);
    initHalterDeviceDao(db);
    initCctvDao(db);
    initHalterDeviceDetailDao(db);
    initHalterDevicePowerLog(db);
    // dst...
    await Future.wait([
      loadNodeRoomsFromDb(),
      loadRoomsFromDb(),
      loadStablesFromDb(),
      loadHorsesFromDb(),
      loadHalterDevicesFromDb(),
      loadCctvsFromDb(),
      loadAllHalterDeviceDetails(),
      loadHalterDevicePowerLogsFromDb(),
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

  // Data Log Power Halter

  late HalterDevicePowerLogDao halterDevicePowerLogDao;

  void initHalterDevicePowerLog(Database db) {
    halterDevicePowerLogDao = HalterDevicePowerLogDao(db);
  }

  Future<void> addHalterDevicePowerLog(HalterDevicePowerLogModel model) async {
    await halterDevicePowerLogDao.insert(model);
    await loadHalterDevicePowerLogsFromDb();
  }

  Future<void> updateHalterDevicePowerLog(
    HalterDevicePowerLogModel model,
  ) async {
    await halterDevicePowerLogDao.update(model);
    await loadHalterDevicePowerLogsFromDb();
  }

  Future<void> loadHalterDevicePowerLogsFromDb() async {
    final list = await halterDevicePowerLogDao.getAll();
    halterDeviceLogList.assignAll(list);
  }
}
