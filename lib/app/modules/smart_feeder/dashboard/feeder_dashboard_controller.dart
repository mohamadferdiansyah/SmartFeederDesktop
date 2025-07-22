import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'dart:async';

import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class FeederDashboardController extends GetxController {
  RxInt secondsRemaining = 9390.obs;

  Timer? _timer;

  var airTankCurrent = 512.3.obs; // RxDouble
  var phCurrent = 7.2.obs; // RxDouble
  var feedTankCurrent = 150.5.obs; // RxDouble
  RxInt selectedStableIndex = 0.obs;
  StableModel get selectedStable => stableList[selectedStableIndex.value];

  final RxList<HorseModel> horseList = <HorseModel>[
    HorseModel(
      horseId: 'Kuda 001',
      name: 'Thunder',
      gender: 'Jantan',
      type: 'Lokal',
      dateOfBirth: DateTime(2023, 1, 1),
      dateJoinedStable: DateTime(2024, 2, 2),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse1.png',
    ),
    HorseModel(
      horseId: 'Kuda 002',
      name: 'Bella',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2022, 6, 10),
      dateJoinedStable: DateTime(2024, 3, 5),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse2.png',
    ),
    HorseModel(
      horseId: 'Kuda 003',
      name: 'Spirit',
      gender: 'Jantan',
      type: 'Arabian',
      dateOfBirth: DateTime(2021, 4, 15),
      dateJoinedStable: DateTime(2024, 1, 27),
      healthStatus: 'Sakit',
      imageAsset: 'assets/images/horse3.png',
    ),
    HorseModel(
      horseId: 'Kuda 004',
      name: 'Daisy',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2022, 8, 21),
      dateJoinedStable: DateTime(2024, 4, 11),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse4.png',
    ),
    HorseModel(
      horseId: 'Kuda 005',
      name: 'Storm',
      gender: 'Jantan',
      type: 'Quarter',
      dateOfBirth: DateTime(2020, 12, 3),
      dateJoinedStable: DateTime(2024, 2, 15),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse5.png',
    ),
    HorseModel(
      horseId: 'Kuda 006',
      name: 'Molly',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2021, 11, 8),
      dateJoinedStable: DateTime(2024, 5, 1),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse6.png',
    ),
    HorseModel(
      horseId: 'Kuda 007',
      name: 'Rocky',
      gender: 'Jantan',
      type: 'Lokal',
      dateOfBirth: DateTime(2020, 7, 19),
      dateJoinedStable: DateTime(2024, 5, 6),
      healthStatus: 'Sakit',
      imageAsset: 'assets/images/horse7.png',
    ),
    HorseModel(
      horseId: 'Kuda 008',
      name: 'Luna',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2022, 9, 14),
      dateJoinedStable: DateTime(2024, 6, 2),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse8.png',
    ),
    HorseModel(
      horseId: 'Kuda 009',
      name: 'Shadow',
      gender: 'Jantan',
      type: 'Lokal',
      dateOfBirth: DateTime(2023, 3, 8),
      dateJoinedStable: DateTime(2024, 6, 10),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse9.png',
    ),
    HorseModel(
      horseId: 'Kuda 010',
      name: 'Rose',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2021, 5, 30),
      dateJoinedStable: DateTime(2024, 7, 1),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse10.png',
    ),
    HorseModel(
      horseId: 'Kuda 011',
      name: 'Jack',
      gender: 'Jantan',
      type: 'Lokal',
      dateOfBirth: DateTime(2020, 10, 12),
      dateJoinedStable: DateTime(2024, 7, 6),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse11.png',
    ),
    HorseModel(
      horseId: 'Kuda 012',
      name: 'Lily',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2022, 2, 18),
      dateJoinedStable: DateTime(2024, 7, 14),
      healthStatus: 'Sakit',
      imageAsset: 'assets/images/horse12.png',
    ),
    HorseModel(
      horseId: 'Kuda 013',
      name: 'Max',
      gender: 'Jantan',
      type: 'Lokal',
      dateOfBirth: DateTime(2021, 8, 2),
      dateJoinedStable: DateTime(2024, 7, 18),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse13.png',
    ),
    HorseModel(
      horseId: 'Kuda 014',
      name: 'Ruby',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2023, 4, 22),
      dateJoinedStable: DateTime(2024, 7, 20),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse14.png',
    ),
    HorseModel(
      horseId: 'Kuda 015',
      name: 'Leo',
      gender: 'Jantan',
      type: 'Lokal',
      dateOfBirth: DateTime(2020, 6, 9),
      dateJoinedStable: DateTime(2024, 7, 21),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse15.png',
    ),
    HorseModel(
      horseId: 'Kuda 016',
      name: 'Maya',
      gender: 'Betina',
      type: 'Lokal',
      dateOfBirth: DateTime(2021, 3, 17),
      dateJoinedStable: DateTime(2024, 7, 22),
      healthStatus: 'Sehat',
      imageAsset: 'assets/images/horse16.png',
    ),
  ].obs;

  // Data dummy stable/kandang (stableList), relasi 1 kuda per kandang lewat horseId
  final RxList<StableModel> stableList = <StableModel>[
    StableModel(
      stableName: 'Kandang 1',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Penjadwalan',
      isActive: true,
      remainingWater: 4.2,
      remainingFeed: 38.0,
      lastFeedText: '2 jam yang lalu',
      horseId: 'Kuda 001',
    ),
    StableModel(
      stableName: 'Kandang 2',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: false,
      remainingWater: 1.5,
      remainingFeed: 12.0,
      lastFeedText: '1 jam yang lalu',
      horseId: 'Kuda 002',
    ),
    StableModel(
      stableName: 'Kandang 3',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: true,
      remainingWater: 0.8,
      remainingFeed: 5.5,
      lastFeedText: '30 menit yang lalu',
      horseId: 'Kuda 003',
    ),
    StableModel(
      stableName: 'Kandang 4',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: true,
      remainingWater: 5.0,
      remainingFeed: 49.0,
      lastFeedText: '10 menit yang lalu',
      horseId: 'Kuda 004',
    ),
    StableModel(
      stableName: 'Kandang 5',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: false,
      remainingWater: 0.2,
      remainingFeed: 0.0,
      lastFeedText: '3 jam yang lalu',
      horseId: 'Kuda 005',
    ),
    StableModel(
      stableName: 'Kandang 6',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Penjadwalan',
      isActive: true,
      remainingWater: 3.8,
      remainingFeed: 30.0,
      lastFeedText: '2 jam yang lalu',
      horseId: 'Kuda 006',
    ),
    StableModel(
      stableName: 'Kandang 7',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: true,
      remainingWater: 4.0,
      remainingFeed: 25.0,
      lastFeedText: '1 jam yang lalu',
      horseId: 'Kuda 007',
    ),
    StableModel(
      stableName: 'Kandang 8',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: false,
      remainingWater: 2.9,
      remainingFeed: 12.5,
      lastFeedText: '2 jam yang lalu',
      horseId: 'Kuda 008',
    ),
    StableModel(
      stableName: 'Kandang 9',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: true,
      remainingWater: 4.7,
      remainingFeed: 41.0,
      lastFeedText: '15 menit yang lalu',
      horseId: 'Kuda 009',
    ),
    StableModel(
      stableName: 'Kandang 10',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: true,
      remainingWater: 1.6,
      remainingFeed: 8.0,
      lastFeedText: '5 jam yang lalu',
      horseId: 'Kuda 010',
    ),
    StableModel(
      stableName: 'Kandang 11',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Penjadwalan',
      isActive: true,
      remainingWater: 3.0,
      remainingFeed: 28.0,
      lastFeedText: '40 menit yang lalu',
      horseId: 'Kuda 011',
    ),
    StableModel(
      stableName: 'Kandang 12',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: false,
      remainingWater: 0.5,
      remainingFeed: 3.0,
      lastFeedText: '6 jam yang lalu',
      horseId: 'Kuda 012',
    ),
    StableModel(
      stableName: 'Kandang 13',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: true,
      remainingWater: 2.1,
      remainingFeed: 20.0,
      lastFeedText: '1 jam yang lalu',
      horseId: 'Kuda 013',
    ),
    StableModel(
      stableName: 'Kandang 14',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: true,
      remainingWater: 4.9,
      remainingFeed: 45.0,
      lastFeedText: '12 menit yang lalu',
      horseId: 'Kuda 014',
    ),
    StableModel(
      stableName: 'Kandang 15',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: false,
      remainingWater: 0.3,
      remainingFeed: 2.0,
      lastFeedText: '8 jam yang lalu',
      horseId: 'Kuda 015',
    ),
    StableModel(
      stableName: 'Kandang 16',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: true,
      remainingWater: 5.0,
      remainingFeed: 50.0,
      lastFeedText: 'baru saja',
      horseId: 'Kuda 016',
    ),
  ].obs;

  final RxList<HistoryEntryModel> historyList = <HistoryEntryModel>[
    // Data dummy diperbanyak
    HistoryEntryModel(
      stableIndex: 0,
      datetime: DateTime(2025, 7, 18, 8, 30),
      water: 4.2,
      feed: 38.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 0,
      datetime: DateTime(2025, 7, 20, 7, 45),
      water: 2.8,
      feed: 25.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 18, 12, 15),
      water: 2.5,
      feed: 21.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 19, 11, 30),
      water: 1.8,
      feed: 15.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 20, 9, 15),
      water: 3.0,
      feed: 20.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 18, 14, 45),
      water: 1.0,
      feed: 10.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 19, 13, 15),
      water: 0.5,
      feed: 8.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 20, 12, 0),
      water: 2.4,
      feed: 18.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 20, 13, 30),
      water: 4.8,
      feed: 47.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 21, 8, 15),
      water: 3.2,
      feed: 30.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 21, 10, 0),
      water: 2.0,
      feed: 18.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 21, 17, 0),
      water: 4.5,
      feed: 40.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 22, 7, 30),
      water: 3.8,
      feed: 30.0,
      scheduleText: 'Penjadwalan',
    ),
    // Tambahkan lagi data dummy jika perlu
    HistoryEntryModel(
      stableIndex: 5,
      datetime: DateTime(2025, 7, 21, 9, 10),
      water: 1.2,
      feed: 8.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 6,
      datetime: DateTime(2025, 7, 22, 8, 55),
      water: 2.7,
      feed: 20.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 0,
      datetime: DateTime(2025, 7, 22, 10, 10),
      water: 4.6,
      feed: 40.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 22, 12, 30),
      water: 2.2,
      feed: 18.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 22, 16, 0),
      water: 3.3,
      feed: 28.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 22, 17, 45),
      water: 4.0,
      feed: 39.0,
      scheduleText: 'Otomatis',
    ),
  ].obs;

  final double tankMax = 600;

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
      for (final stable in stableList) {
        // Misal air berkurang, pakan bertambah
        stable.remainingWater.value = (stable.remainingWater.value - 0.1).clamp(
          0,
          5,
        ); // jika max 5L
        stable.remainingFeed.value = (stable.remainingFeed.value - 0.5).clamp(
          0,
          50,
        ); // jika max 50Kg
      }
    });
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
}
