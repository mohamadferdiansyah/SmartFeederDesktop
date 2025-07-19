import 'package:get/get.dart';
import 'dart:async';

class DashboardController extends GetxController {
  // Dummy: countdown 90 detik (bisa ganti dengan menit/jam)
  RxInt secondsRemaining = 9390.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startCountdown();
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
}
