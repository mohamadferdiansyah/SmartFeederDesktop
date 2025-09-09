import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/table/halter_table_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterLayoutController extends GetxController {
  var currentPage = Rx<Widget>(HalterDashboardPage());
  var currentMenuTitle = 'Dashboard'.obs;
  var currentDateTime = ''.obs;
  var currentTime = ''.obs;
  var currentDate = ''.obs;
  Timer? _timer;
  final DataController dataController = Get.find<DataController>();
  final HalterDashboardController dashboardController =
      Get.find<HalterDashboardController>();
  final HalterSettingController settingController =
      Get.find<HalterSettingController>();
  final HalterSerialService serialService = Get.find<HalterSerialService>();
  final HalterTableRuleEngineController tableRuleEngineController = Get.find<HalterTableRuleEngineController>();

  @override
  void onInit() {
    super.onInit();
    _startRealTimeClock();
    dataController.initAllDaosAndLoadAll().then((_) async {
      // Setelah semua data di-load, bisa melakukan inisialisasi lain jika perlu
      await dashboardController.refreshStableList();
      await dashboardController.refreshRoomList();
      await tableRuleEngineController.loadDefaultIfEmpty();

      serialService.pairingDevice();

      // Pastikan stableList sudah terisi
      if (dashboardController.stableList.isNotEmpty) {
        dashboardController.selectedStableId.value =
            dashboardController.stableList.first.stableId;
        dashboardController.selectedRoomIndex.value = 0;
      }
    });

    if (settingController.availablePorts.isNotEmpty &&
        settingController.setting.value.loraPort.isEmpty) {
      settingController.updateLora(
        port: settingController.availablePorts.first,
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setPage(Widget page, String menuTitle) {
    currentPage.value = page;
    currentMenuTitle.value = menuTitle;
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
}
