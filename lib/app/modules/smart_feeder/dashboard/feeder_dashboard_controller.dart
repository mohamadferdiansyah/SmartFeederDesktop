import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/history_entry.dart';
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

  final RxList<StableModel> stableList = <StableModel>[
    StableModel(
      stableName: 'Kandang 1',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Penjadwalan',
      isActive: true,
      remainingWater: 4.2,
      remainingFeed: 38.0,
      lastFeedText: '2 jam yang lalu',
    ),
    StableModel(
      stableName: 'Kandang 2',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: false,
      remainingWater: 1.5,
      remainingFeed: 12.0,
      lastFeedText: '1 jam yang lalu',
    ),
    StableModel(
      stableName: 'Kandang 3',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: true,
      remainingWater: 0.8,
      remainingFeed: 5.5,
      lastFeedText: '30 menit yang lalu',
    ),
    StableModel(
      stableName: 'Kandang 4',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Otomatis',
      isActive: true,
      remainingWater: 5.0,
      remainingFeed: 49.0,
      lastFeedText: '10 menit yang lalu',
    ),
    StableModel(
      stableName: 'Kandang 5',
      imageAsset: 'assets/images/stable.jpg',
      scheduleText: 'Manual',
      isActive: false,
      remainingWater: 0.2,
      remainingFeed: 0.0,
      lastFeedText: '3 jam yang lalu',
    ),
  ].obs;

  final RxList<HistoryEntryModel> historyList = <HistoryEntryModel>[
    // Kandang 0
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
    // Kandang 1
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
    // Kandang 2
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 18, 14, 45),
      water: 1.0,
      feed: 10.0,
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
    // Kandang 3
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 20, 13, 30),
      water: 4.8,
      feed: 47.0,
      scheduleText: 'Penjadwalan',
    ),
    // Kandang 4
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
