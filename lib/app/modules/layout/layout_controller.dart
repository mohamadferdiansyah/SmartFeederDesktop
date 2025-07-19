import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/dashboard/dashboard_page.dart';
import 'package:intl/intl.dart';

class LayoutController extends GetxController {
  var currentPage = Rx<Widget>(DashboardPage());
  var currentDateTime = ''.obs;
  var currentTime = ''.obs;
  var currentDate = ''.obs;
  var currentPageName = 'Dashboard'.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startRealTimeClock();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void navigateTo(Widget page) {
    currentPage.value = page;
    if (page is DashboardPage) {
      currentPageName.value = 'Dashboard';
    } else if (page.runtimeType.toString() == 'ControlSchedulePage') {
      currentPageName.value = 'Kontrol Jadwal';
    } else if (page.runtimeType.toString() == 'DevicePage') {
      currentPageName.value = 'Data Perangkat';
    } else if (page.runtimeType.toString() == 'FeedPage') {
      currentPageName.value = 'Data Pakan';
    } else if (page.runtimeType.toString() == 'WaterPage') {
      currentPageName.value = 'Data Air';
    } else if (page.runtimeType.toString() == 'DeviceSettingPage') {
      currentPageName.value = 'Pengaturan Perangkat';
    } else if (page.runtimeType.toString() == 'HelpPage') {
      currentPageName.value = 'Bantuan';
    }
  }

  void _startRealTimeClock() {
    _updateDateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();

    // Format lengkap
    final formattedDateTime = DateFormat(
      'EEEE, dd MMMM yyyy - HH:mm:ss',
    ).format(now);
    currentDateTime.value = formattedDateTime;

    // Format waktu saja
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    currentTime.value = formattedTime;

    // Format tanggal saja
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    currentDate.value = formattedDate;
  }

  // Getter methods untuk mendapatkan format yang berbeda (static)
  String get currentTimeStatic => DateFormat('HH:mm:ss').format(DateTime.now());
  String get currentDateStatic =>
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
  String get currentTimeOnly => DateFormat('HH:mm', 'id_ID').format(DateTime.now());
  String get currentDateOnly => DateFormat('dd/MM/yyyy', 'id_ID').format(DateTime.now());
}
