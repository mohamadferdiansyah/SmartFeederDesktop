// import 'models.dart';
// import 'package:get/get.dart';

// final RxList<StableModel> stableList = <StableModel>[
//   StableModel(stableId: 'S1', name: 'Kandang A', address: 'Jl. Kuda No.1'),
//   StableModel(stableId: 'S2', name: 'Kandang B', address: 'Jl. Kuda No.2'),
// ].obs;

// final RxList<CctvModel> cctvList = <CctvModel>[
//   CctvModel(cctvId: 'CCTV1', ipAddress: '172.19.0.193', port: 8000, username: 'admin', password: 'fkh12345'),
//   CctvModel(cctvId: 'CCTV2', ipAddress: '172.19.0.194', port: 8000, username: 'admin', password: 'fkh12345'),
//   CctvModel(cctvId: 'CCTV3', ipAddress: '172.19.0.195', port: 8000, username: 'admin', password: 'fkh12345'),
//   CctvModel(cctvId: 'CCTV4', ipAddress: '172.19.0.196', port: 8000, username: 'admin', password: 'fkh12345'),
// ].obs;

// final RxList<HorseModel> horseList = <HorseModel>[
//   HorseModel(horseId: 'H1', name: 'Farel', type: HorseType.local, gender: HorseGender.male, age: '1,47 tahun', roomId: 'R1'),
//   HorseModel(horseId: 'H2', name: 'Bella', type: HorseType.crossbred, gender: HorseGender.female, age: '2,15 tahun', roomId: null),
// ].obs;

// final RxList<RoomModel> roomList = <RoomModel>[
//   RoomModel(
//     roomId: 'R1',
//     name: 'Ruangan 1',
//     deviceSerial: 'SRIPB1223001',
//     status: RoomStatus.used,
//     cctvIds: ['CCTV1', 'CCTV2'],
//     stableId: 'S1',
//     horseId: 'H1',
//     remainingWater: 43.0,
//     remainingFeed: 30.0,
//     scheduleType: ScheduleType.penjadwalan,
//   ),
//   RoomModel(
//     roomId: 'R2',
//     name: 'Ruangan 2',
//     deviceSerial: 'SRIPB1223002',
//     status: RoomStatus.available,
//     cctvIds: ['CCTV2', 'CCTV3'],
//     stableId: 'S1',
//     horseId: null,
//     remainingWater: 0.0,
//     remainingFeed: 0.0,
//     scheduleType: ScheduleType.otomatis,
//   ),
// ].obs;

// final RxList<HorseHealthModel> horseHealthList = <HorseHealthModel>[
//   HorseHealthModel(
//     healthId: 'HEALTH1',
//     horseId: 'H1',
//     heartRate: 38,
//     bodyTemp: 37.2,
//     oxygen: 98.5,
//     respiration: 18,
//     posture: "Berdiri Kepala Tegak",
//     postureAccuracy: 98.0,
//     batteryPercent: 90,
//   ),
// ].obs;

// final RxList<HalterDeviceModel> halterDeviceList = <HalterDeviceModel>[
//   HalterDeviceModel(deviceId: 'SHIPB1223005', horseId: 'H1', status: HalterDeviceStatus.on),
//   HalterDeviceModel(deviceId: 'SHIPB1223006', horseId: null, status: HalterDeviceStatus.off),
// ].obs;

// final RxList<FeederDeviceModel> feederDeviceList = <FeederDeviceModel>[
//   FeederDeviceModel(deviceId: 'SFIPB1223005', roomId: 'R1', status: FeederDeviceStatus.on, type: FeederDeviceType.actuator),
//   FeederDeviceModel(deviceId: 'SFIPB1223006', roomId: null, status: FeederDeviceStatus.off, type: FeederDeviceType.sensor),
// ].obs;

// final RxList<FeedModel> feedList = <FeedModel>[
//   FeedModel(feedId: 'F1', name: 'Pakan A', type: FeedType.hijauan, stock: 100.0),
//   FeedModel(feedId: 'F2', name: 'Pakan B', type: FeedType.konsentrat, stock: 50.0),
// ].obs;

// final RxList<FeedLogModel> feedLogList = <FeedLogModel>[
//   FeedLogModel(logId: 'LOGF1', feedId: 'F1', quantity: 50.0, date: DateTime.now()),
// ].obs;

// final RxList<WaterModel> waterList = <WaterModel>[
//   WaterModel(waterId: 'W1', name: 'Tandon A', stock: 100.0),
//   WaterModel(waterId: 'W2', name: 'Tandon B', stock: 80.0),
// ].obs;

// final RxList<WaterLogModel> waterLogList = <WaterLogModel>[
//   WaterLogModel(logId: 'LOGW1', waterId: 'W1', quantity: 30.0, date: DateTime.now()),
// ].obs;

// final RxList<HistoryEntryModel> historyEntryList = <HistoryEntryModel>[
//   HistoryEntryModel(
//     historyId: 'HIST1',
//     stableId: 'S1',
//     roomId: 'R1',
//     date: DateTime.now(),
//     type: ScheduleType.penjadwalan,
//     feed: 38.2,
//     water: 4.2,
//   ),
// ].obs;