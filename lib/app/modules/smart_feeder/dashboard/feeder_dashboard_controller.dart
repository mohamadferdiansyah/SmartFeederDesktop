import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/models/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'dart:async';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class FeederDashboardController extends GetxController {
  RxInt secondsRemaining = 9390.obs;

  Timer? _timer;

  var airTankCurrent = 512.3.obs; // RxDouble
  var phCurrent = 7.2.obs; // RxDouble
  var feedTankCurrent = 150.5.obs; // RxDouble

  RxString selectedStableId = 'S1'.obs;
  RxInt selectedRoomIndex = 0.obs;
  RoomModel get selectedRoom => filteredRoomList.isNotEmpty
      ? filteredRoomList[selectedRoomIndex.value.clamp(
          0,
          filteredRoomList.length - 1,
        )]
      : roomList[0];

  final double tankMax = 600;

  final RxList<StableModel> stableList = <StableModel>[
    StableModel(
      stableId: 'S1',
      name: 'Kandang Alpha',
      address: 'Jl. Kuda No.1',
    ),
    StableModel(
      stableId: 'S2',
      name: 'Kandang Bravo',
      address: 'Jl. Kuda No.2',
    ),
    StableModel(
      stableId: 'S3',
      name: 'Kandang Charlie',
      address: 'Jl. Kuda No.3',
    ),
  ].obs;

  final RxList<RoomModel> roomList = <RoomModel>[
    // Stable 1
    RoomModel(
      roomId: 'R1',
      name: 'Ruangan 1',
      deviceSerial: 'SRIPB1223001',
      status: 'used',
      cctvIds: ['CCTV1', 'CCTV2'],
      stableId: 'S1',
      horseId: 'H1',
      remainingWater: 43.0,
      remainingFeed: 30.0,
      scheduleType: 'penjadwalan',
    ),
    RoomModel(
      roomId: 'R2',
      name: 'Ruangan 2',
      deviceSerial: 'SRIPB1223002',
      status: 'available',
      cctvIds: ['CCTV3', 'CCTV4'],
      stableId: 'S1',
      horseId: 'H2',
      remainingWater: 21.0,
      remainingFeed: 15.0,
      scheduleType: 'otomatis',
    ),
    RoomModel(
      roomId: 'R3',
      name: 'Ruangan 3',
      deviceSerial: 'SRIPB1223003',
      status: 'used',
      cctvIds: ['CCTV5', 'CCTV6'],
      stableId: 'S1',
      horseId: 'H3',
      remainingWater: 11.0,
      remainingFeed: 12.0,
      scheduleType: 'manual',
    ),
    RoomModel(
      roomId: 'R4',
      name: 'Ruangan 4',
      deviceSerial: 'SRIPB1223004',
      status: 'available',
      cctvIds: ['CCTV7', 'CCTV8'],
      stableId: 'S1',
      horseId: 'H4',
      remainingWater: 50.0,
      remainingFeed: 17.0,
      scheduleType: 'penjadwalan',
    ),
    RoomModel(
      roomId: 'R5',
      name: 'Ruangan 5',
      deviceSerial: 'SRIPB1223005',
      status: 'used',
      cctvIds: ['CCTV9', 'CCTV10'],
      stableId: 'S1',
      horseId: 'H5',
      remainingWater: 18.0,
      remainingFeed: 21.0,
      scheduleType: 'otomatis',
    ),
    RoomModel(
      roomId: 'R6',
      name: 'Ruangan 6',
      deviceSerial: 'SRIPB1223006',
      status: 'available',
      cctvIds: ['CCTV11', 'CCTV12'],
      stableId: 'S1',
      horseId: 'H6',
      remainingWater: 26.0,
      remainingFeed: 7.0,
      scheduleType: 'manual',
    ),
    // Stable 2
    RoomModel(
      roomId: 'R7',
      name: 'Ruangan 7',
      deviceSerial: 'SRIPB1223007',
      status: 'used',
      cctvIds: ['CCTV13', 'CCTV14'],
      stableId: 'S2',
      horseId: 'H7',
      remainingWater: 10.0,
      remainingFeed: 13.0,
      scheduleType: 'penjadwalan',
    ),
    RoomModel(
      roomId: 'R8',
      name: 'Ruangan 8',
      deviceSerial: 'SRIPB1223008',
      status: 'available',
      cctvIds: ['CCTV15', 'CCTV16'],
      stableId: 'S2',
      horseId: 'H8',
      remainingWater: 9.0,
      remainingFeed: 6.5,
      scheduleType: 'otomatis',
    ),
    RoomModel(
      roomId: 'R9',
      name: 'Ruangan 9',
      deviceSerial: 'SRIPB1223009',
      status: 'used',
      cctvIds: ['CCTV17', 'CCTV18'],
      stableId: 'S2',
      horseId: 'H9',
      remainingWater: 31.0,
      remainingFeed: 22.0,
      scheduleType: 'manual',
    ),
    RoomModel(
      roomId: 'R10',
      name: 'Ruangan 10',
      deviceSerial: 'SRIPB1223010',
      status: 'available',
      cctvIds: ['CCTV19', 'CCTV20'],
      stableId: 'S2',
      horseId: 'H10',
      remainingWater: 23.0,
      remainingFeed: 20.0,
      scheduleType: 'penjadwalan',
    ),
    RoomModel(
      roomId: 'R11',
      name: 'Ruangan 11',
      deviceSerial: 'SRIPB1223011',
      status: 'used',
      cctvIds: ['CCTV2', 'CCTV3'],
      stableId: 'S2',
      horseId: 'H11',
      remainingWater: 11.0,
      remainingFeed: 16.0,
      scheduleType: 'otomatis',
    ),
    RoomModel(
      roomId: 'R12',
      name: 'Ruangan 12',
      deviceSerial: 'SRIPB1223012',
      status: 'available',
      cctvIds: ['CCTV4', 'CCTV5'],
      stableId: 'S2',
      horseId: 'H12',
      remainingWater: 41.0,
      remainingFeed: 19.0,
      scheduleType: 'manual',
    ),
    // Stable 3
    RoomModel(
      roomId: 'R13',
      name: 'Ruangan 13',
      deviceSerial: 'SRIPB1223013',
      status: 'used',
      cctvIds: ['CCTV6', 'CCTV7'],
      stableId: 'S3',
      horseId: 'H13',
      remainingWater: 36.0,
      remainingFeed: 3.0,
      scheduleType: 'penjadwalan',
    ),
    RoomModel(
      roomId: 'R14',
      name: 'Ruangan 14',
      deviceSerial: 'SRIPB1223014',
      status: 'available',
      cctvIds: ['CCTV8', 'CCTV9'],
      stableId: 'S3',
      horseId: 'H14',
      remainingWater: 24.0,
      remainingFeed: 10.0,
      scheduleType: 'otomatis',
    ),
    RoomModel(
      roomId: 'R15',
      name: 'Ruangan 15',
      deviceSerial: 'SRIPB1223015',
      status: 'used',
      cctvIds: ['CCTV10', 'CCTV11'],
      stableId: 'S3',
      horseId: 'H15',
      remainingWater: 14.5,
      remainingFeed: 24.0,
      scheduleType: 'manual',
    ),
    RoomModel(
      roomId: 'R16',
      name: 'Ruangan 16',
      deviceSerial: 'SRIPB1223016',
      status: 'available',
      cctvIds: ['CCTV12', 'CCTV13'],
      stableId: 'S3',
      horseId: 'H16',
      remainingWater: 7.0,
      remainingFeed: 16.0,
      scheduleType: 'penjadwalan',
    ),
    RoomModel(
      roomId: 'R17',
      name: 'Ruangan 17',
      deviceSerial: 'SRIPB1223017',
      status: 'used',
      cctvIds: ['CCTV14', 'CCTV15'],
      stableId: 'S3',
      horseId: 'H17',
      remainingWater: 6.0,
      remainingFeed: 2.0,
      scheduleType: 'otomatis',
    ),
    RoomModel(
      roomId: 'R18',
      name: 'Ruangan 18',
      deviceSerial: 'SRIPB1223018',
      status: 'available',
      cctvIds: ['CCTV16', 'CCTV17'],
      stableId: 'S3',
      horseId: 'H18',
      remainingWater: 39.0,
      remainingFeed: 11.0,
      scheduleType: 'manual',
    ),
  ].obs;

  final RxList<HorseModel> horseList = <HorseModel>[
    // Stable 1
    HorseModel(
      horseId: 'H1',
      name: 'Farel',
      type: 'local',
      gender: 'male',
      age: '1,47 tahun',
      roomId: 'R1',
    ),
    HorseModel(
      horseId: 'H2',
      name: 'Bella',
      type: 'crossbred',
      gender: 'female',
      age: '2,15 tahun',
      roomId: 'R2',
    ),
    HorseModel(
      horseId: 'H3',
      name: 'Jupiter',
      type: 'local',
      gender: 'male',
      age: '3,05 tahun',
      roomId: 'R3',
    ),
    HorseModel(
      horseId: 'H4',
      name: 'Mawar',
      type: 'crossbred',
      gender: 'female',
      age: '1,98 tahun',
      roomId: 'R4',
    ),
    HorseModel(
      horseId: 'H5',
      name: 'Tornado',
      type: 'local',
      gender: 'male',
      age: '2,80 tahun',
      roomId: 'R5',
    ),
    HorseModel(
      horseId: 'H6',
      name: 'Dewi',
      type: 'crossbred',
      gender: 'female',
      age: '2,60 tahun',
      roomId: 'R6',
    ),
    // Stable 2
    HorseModel(
      horseId: 'H7',
      name: 'Raja',
      type: 'local',
      gender: 'male',
      age: '3,40 tahun',
      roomId: 'R7',
    ),
    HorseModel(
      horseId: 'H8',
      name: 'Putri',
      type: 'crossbred',
      gender: 'female',
      age: '1,80 tahun',
      roomId: 'R8',
    ),
    HorseModel(
      horseId: 'H9',
      name: 'Guntur',
      type: 'local',
      gender: 'male',
      age: '2,50 tahun',
      roomId: 'R9',
    ),
    HorseModel(
      horseId: 'H10',
      name: 'Bunga',
      type: 'crossbred',
      gender: 'female',
      age: '2,10 tahun',
      roomId: 'R10',
    ),
    HorseModel(
      horseId: 'H11',
      name: 'Bintang',
      type: 'local',
      gender: 'male',
      age: '4,00 tahun',
      roomId: 'R11',
    ),
    HorseModel(
      horseId: 'H12',
      name: 'Melati',
      type: 'crossbred',
      gender: 'female',
      age: '3,20 tahun',
      roomId: 'R12',
    ),
    // Stable 3
    HorseModel(
      horseId: 'H13',
      name: 'Satria',
      type: 'local',
      gender: 'male',
      age: '2,70 tahun',
      roomId: 'R13',
    ),
    HorseModel(
      horseId: 'H14',
      name: 'Citra',
      type: 'crossbred',
      gender: 'female',
      age: '1,60 tahun',
      roomId: 'R14',
    ),
    HorseModel(
      horseId: 'H15',
      name: 'Mega',
      type: 'local',
      gender: 'male',
      age: '3,90 tahun',
      roomId: 'R15',
    ),
    HorseModel(
      horseId: 'H16',
      name: 'Embun',
      type: 'crossbred',
      gender: 'female',
      age: '2,00 tahun',
      roomId: 'R16',
    ),
    HorseModel(
      horseId: 'H17',
      name: 'Petir',
      type: 'local',
      gender: 'male',
      age: '2,30 tahun',
      roomId: 'R17',
    ),
    HorseModel(
      horseId: 'H18',
      name: 'Indah',
      type: 'crossbred',
      gender: 'female',
      age: '2,45 tahun',
      roomId: 'R18',
    ),
  ].obs;

  final RxList<FeederDeviceModel> feederDeviceList = <FeederDeviceModel>[
    FeederDeviceModel(
      deviceId: 'SFIPB1223005',
      roomId: 'R1',
      status: 'on',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223006',
      roomId: 'R2',
      status: 'off',
      type: 'sensor',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223007',
      roomId: 'R3',
      status: 'on',
      type: 'gateway',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223008',
      roomId: 'R4',
      status: 'off',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223009',
      roomId: 'R5',
      status: 'on',
      type: 'sensor',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223010',
      roomId: 'R6',
      status: 'off',
      type: 'gateway',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223011',
      roomId: 'R7',
      status: 'on',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223012',
      roomId: 'R8',
      status: 'off',
      type: 'sensor',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223013',
      roomId: 'R9',
      status: 'on',
      type: 'gateway',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223014',
      roomId: 'R10',
      status: 'off',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223015',
      roomId: 'R11',
      status: 'on',
      type: 'sensor',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223016',
      roomId: 'R12',
      status: 'off',
      type: 'gateway',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223017',
      roomId: 'R13',
      status: 'on',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223018',
      roomId: 'R14',
      status: 'off',
      type: 'sensor',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223019',
      roomId: 'R15',
      status: 'on',
      type: 'gateway',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223020',
      roomId: 'R16',
      status: 'off',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223021',
      roomId: 'R17',
      status: 'on',
      type: 'sensor',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223022',
      roomId: 'R18',
      status: 'off',
      type: 'gateway',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223023',
      roomId: 'R19',
      status: 'on',
      type: 'actuator',
    ),
    FeederDeviceModel(
      deviceId: 'SFIPB1223024',
      roomId: 'R20',
      status: 'off',
      type: 'sensor',
    ),
  ].obs;

  final RxList<HistoryEntryModel> historyEntryList = <HistoryEntryModel>[
    // Stable 1, Room R1-R6
    HistoryEntryModel(
      historyId: 'HIST1',
      stableId: 'S1',
      roomId: 'R1',
      date: DateTime(2025, 7, 1, 8, 0),
      type: 'penjadwalan',
      feed: 38.2,
      water: 4.2,
    ),
    HistoryEntryModel(
      historyId: 'HIST2',
      stableId: 'S1',
      roomId: 'R2',
      date: DateTime(2025, 7, 2, 8, 0),
      type: 'otomatis',
      feed: 40.1,
      water: 3.8,
    ),
    HistoryEntryModel(
      historyId: 'HIST3',
      stableId: 'S1',
      roomId: 'R3',
      date: DateTime(2025, 7, 3, 8, 0),
      type: 'manual',
      feed: 25.7,
      water: 2.6,
    ),
    HistoryEntryModel(
      historyId: 'HIST4',
      stableId: 'S1',
      roomId: 'R4',
      date: DateTime(2025, 7, 4, 8, 0),
      type: 'penjadwalan',
      feed: 22.5,
      water: 1.9,
    ),
    HistoryEntryModel(
      historyId: 'HIST5',
      stableId: 'S1',
      roomId: 'R5',
      date: DateTime(2025, 7, 5, 8, 0),
      type: 'otomatis',
      feed: 18.4,
      water: 4.7,
    ),
    HistoryEntryModel(
      historyId: 'HIST6',
      stableId: 'S1',
      roomId: 'R6',
      date: DateTime(2025, 7, 6, 8, 0),
      type: 'manual',
      feed: 41.9,
      water: 5.5,
    ),

    // Stable 2, Room R7-R12
    HistoryEntryModel(
      historyId: 'HIST7',
      stableId: 'S2',
      roomId: 'R7',
      date: DateTime(2025, 7, 7, 8, 0),
      type: 'penjadwalan',
      feed: 37.4,
      water: 4.8,
    ),
    HistoryEntryModel(
      historyId: 'HIST8',
      stableId: 'S2',
      roomId: 'R8',
      date: DateTime(2025, 7, 8, 8, 0),
      type: 'otomatis',
      feed: 29.5,
      water: 5.1,
    ),
    HistoryEntryModel(
      historyId: 'HIST9',
      stableId: 'S2',
      roomId: 'R9',
      date: DateTime(2025, 7, 9, 8, 0),
      type: 'manual',
      feed: 26.0,
      water: 2.9,
    ),
    HistoryEntryModel(
      historyId: 'HIST10',
      stableId: 'S2',
      roomId: 'R10',
      date: DateTime(2025, 7, 10, 8, 0),
      type: 'penjadwalan',
      feed: 21.1,
      water: 2.1,
    ),
    HistoryEntryModel(
      historyId: 'HIST11',
      stableId: 'S2',
      roomId: 'R11',
      date: DateTime(2025, 7, 11, 8, 0),
      type: 'otomatis',
      feed: 39.8,
      water: 4.0,
    ),
    HistoryEntryModel(
      historyId: 'HIST12',
      stableId: 'S2',
      roomId: 'R12',
      date: DateTime(2025, 7, 12, 8, 0),
      type: 'manual',
      feed: 27.7,
      water: 3.3,
    ),

    // Stable 3, Room R13-R18
    HistoryEntryModel(
      historyId: 'HIST13',
      stableId: 'S3',
      roomId: 'R13',
      date: DateTime(2025, 7, 13, 8, 0),
      type: 'penjadwalan',
      feed: 23.4,
      water: 2.4,
    ),
    HistoryEntryModel(
      historyId: 'HIST14',
      stableId: 'S3',
      roomId: 'R14',
      date: DateTime(2025, 7, 14, 8, 0),
      type: 'otomatis',
      feed: 31.5,
      water: 5.8,
    ),
    HistoryEntryModel(
      historyId: 'HIST15',
      stableId: 'S3',
      roomId: 'R15',
      date: DateTime(2025, 7, 15, 8, 0),
      type: 'manual',
      feed: 35.6,
      water: 4.5,
    ),
    HistoryEntryModel(
      historyId: 'HIST16',
      stableId: 'S3',
      roomId: 'R16',
      date: DateTime(2025, 7, 16, 8, 0),
      type: 'penjadwalan',
      feed: 33.9,
      water: 6.2,
    ),
    HistoryEntryModel(
      historyId: 'HIST17',
      stableId: 'S3',
      roomId: 'R17',
      date: DateTime(2025, 7, 17, 8, 0),
      type: 'otomatis',
      feed: 42.2,
      water: 7.0,
    ),
    HistoryEntryModel(
      historyId: 'HIST18',
      stableId: 'S3',
      roomId: 'R18',
      date: DateTime(2025, 7, 18, 8, 0),
      type: 'manual',
      feed: 19.8,
      water: 2.0,
    ),
  ].obs;

  List<RoomModel> get filteredRoomList => roomList
      .where((room) => room.stableId == selectedStableId.value)
      .toList();

  @override
  void onInit() {
    super.onInit();
    startCountdown();
    // Simulasi update isi tanki tiap detik untuk demo realtime
    Timer.periodic(Duration(seconds: 3), (timer) {
      // Update air tank turun 10, feed naik 15 misal
      phCurrent.value = (phCurrent.value + 0.01).clamp(6.5, 8.5);
      airTankCurrent.value = (airTankCurrent.value - 5).clamp(0, tankMax);
      feedTankCurrent.value = (feedTankCurrent.value + 5).clamp(0, tankMax);
    });

    Timer.periodic(Duration(seconds: 3), (timer) {
      for (final room in roomList) {
        // Misal air berkurang, pakan bertambah
        room.remainingWater.value = (room.remainingWater.value - 0.1).clamp(
          0,
          5,
        ); // jika max 5L
        room.remainingFeed.value = (room.remainingFeed.value - 0.5).clamp(
          0,
          50,
        ); // jika max 50Kg
      }
    });
  }

  void setSelectedStableId(String stableId) {
    selectedStableId.value = stableId;
    selectedRoomIndex.value = 0; // reset index ke 0 saat ganti stable
  }

  void startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secs';
  }

  String getTankImageAsset({
    required double current,
    required double max,
    required bool isWater, // true = air, false = pakan
  }) {
    final folder = isWater ? "water_tank" : "feed_tank";
    if (current <= 0) return "assets/images/$folder/fill_0.png";
    int level = (current / (max / 6)).ceil().clamp(1, 6);
    return "assets/images/$folder/fill_$level.png";
  }

  String getStableTankImageAsset(double current, double max, bool isWater) {
    // Folder: stable_feed atau stable_water
    final folder = isWater ? "stable_water" : "stable_feed";
    int level = 0;
    if (max > 0) {
      level = ((current / max) * 5).clamp(0, 5).round();
    }
    return "assets/images/$folder/fill_$level.png";
  }

  // Di FeederDashboardController

  String getAirTankCurrentText() {
    return "${airTankCurrent.value.toStringAsFixed(1)}L";
  }

  String getAirTankMaxText() {
    return "${tankMax.toStringAsFixed(1)}L";
  }

  String getAirTankPercentText() {
    final percent = (tankMax > 0) ? (airTankCurrent.value / tankMax * 100) : 0;
    return "${percent.toStringAsFixed(0)}%";
  }

  String getFeedTankCurrentText() {
    return "${feedTankCurrent.value.toStringAsFixed(1)}Kg";
  }

  String getFeedTankMaxText() {
    return "${tankMax.toStringAsFixed(1)}Kg";
  }

  String getFeedTankPercentText() {
    final percent = (tankMax > 0) ? (feedTankCurrent.value / tankMax * 100) : 0;
    return "${percent.toStringAsFixed(0)}%";
  }

  String getDeviceStatusByRoom(String roomId) {
    final device = feederDeviceList.firstWhereOrNull((d) => d.roomId == roomId);
    if (device == null) return "Tidak ada perangkat";
    return device.status == 'on' ? "Aktif" : "Nonaktif";
  }

  String getStableNameById(String stableId) {
    final stable = stableList.firstWhereOrNull((s) => s.stableId == stableId);
    return stable?.name ?? "Tidak diketahui";
  }
}
