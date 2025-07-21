import 'package:get/get.dart';
import 'dart:async';

class FeederDashboardController extends GetxController {
  RxInt secondsRemaining = 9390.obs;

  Timer? _timer;

  var airTankCurrent = 512.3.obs; // RxDouble
  var phCurrent = 7.2.obs; // RxDouble
  var feedTankCurrent = 150.5.obs; // RxDouble

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
}
