// ignore_for_file: unrelated_type_equality_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/layout/feeder_layout_controller.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_battery_indicator.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_history_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_tank_card.dart';

// ignore: unrelated_type_equality_checks

class FeederDashboardPage extends StatefulWidget {
  const FeederDashboardPage({super.key});

  @override
  State<FeederDashboardPage> createState() => _FeederDashboardPageState();
}

class _FeederDashboardPageState extends State<FeederDashboardPage> {
  final FeederDashboardController controller = Get.find();
  final FeederLayoutController layoutController = Get.find();
  final mqtt = Get.find<MqttService>();

  Future<void> showFillFeedDialog({
    required BuildContext context,
    required String stableName,
    required double mainTankFeed,
    required Function(double feed) onSubmit,
  }) async {
    final TextEditingController feedController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            height: 70,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange, width: 1),
            ),
            child: Center(
              child: Text(
                'Isi Pakan Ruangan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama Kandang
                Row(
                  children: [
                    const Text(
                      'Ruangan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stableName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomInput(
                  label: 'Jumlah Pakan yang akan diisi (gram)',
                  fontSize: 18,
                  controller: feedController,
                  hint: 'Masukkan jumlah pakan',
                  icon: Icons.food_bank,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Sisa pakan tanki utama: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$mainTankFeed Gram',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Batal',
                    hasShadow: false,
                    onPressed: () {
                      Get.back();
                    },
                    fontSize: 20,
                    borderColor: Colors.red,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.red,
                  ),
                ),
                SizedBox(width: 16), // jarak antar tombol
                Expanded(
                  child: CustomButton(
                    text: 'Isi',
                    onPressed: () {
                      print(controller.selectedRoom.roomId);
                      mqtt.activateDevice(controller.selectedRoom.roomId);
                    },
                    fontSize: 20,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> showFillWaterDialog({
    required BuildContext context,
    required String stableName,
    required double mainTankWater,
    required Function(double water) onSubmit,
  }) async {
    final TextEditingController waterController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            height: 70,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Center(
              child: Text(
                'Isi Air Ruangan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama Kandang
                Row(
                  children: [
                    const Text(
                      'Ruangan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stableName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomInput(
                  label: 'Jumlah Air yang akan diisi (liter)',
                  fontSize: 18,
                  controller: waterController,
                  hint: 'Masukkan jumlah air',
                  icon: Icons.water,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Sisa air tanki utama: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${mainTankWater.round()} Liter',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Batal',
                    hasShadow: false,
                    onPressed: () {
                      Get.back();
                    },
                    fontSize: 20,
                    borderColor: Colors.red,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.red,
                  ),
                ),
                SizedBox(width: 16), // jarak antar tombol
                Expanded(
                  child: CustomButton(
                    text: 'Isi',
                    onPressed: () {
                      print(controller.selectedRoom.roomId);
                      mqtt.activateDevice(controller.selectedRoom.roomId);
                    },
                    fontSize: 20,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.58,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Obx(
                            () => Image.asset(
                              controller.getTankImageAsset(
                                current: controller.airTankCurrent.value,
                                max: controller.tankMax,
                                isWater: true,
                              ),
                              width: 200,
                              height: 200,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanki Air Utama',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Obx(
                                () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tersedia Air:',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          controller.getAirTankCurrentText(),
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          ' / ',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        Text(
                                          controller.getAirTankMaxText(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          '(${controller.getAirTankPercentText()})',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ph Level:',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${controller.phCurrent.value.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepOrange),
                      ),
                      child: Row(
                        children: [
                          Obx(
                            () => Image.asset(
                              controller.getTankImageAsset(
                                current: controller.feedTankCurrent.value,
                                max: controller.tankMax,
                                isWater: false,
                              ),
                              width: 200,
                              height: 200,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanki Pakan Utama',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tesedia Pakan:',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Obx(
                                    () => Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          controller.getFeedTankCurrentText(),
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        Text(
                                          ' / ',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        Text(
                                          controller.getFeedTankMaxText(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          '(${controller.getFeedTankPercentText()})',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: 16),
                CustomCard(
                  scrollable: false,
                  title: 'Informasi Detail',
                  trailing: Obx(
                    () => Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Text(
                            controller.selectedRoom.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                controller.getDeviceStatusByRoom(
                                      controller.selectedRoom.roomId,
                                    ) ==
                                    "Aktif"
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  controller.getDeviceStatusByRoom(
                                        controller.selectedRoom.roomId,
                                      ) ==
                                      "Aktif"
                                  ? Colors.green
                                  : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            controller.getDeviceStatusByRoom(
                                      controller.selectedRoom.roomId,
                                    ) ==
                                    "Aktif"
                                ? 'Aktif'
                                : 'Tidak Aktif',
                            style: TextStyle(
                              color:
                                  controller.getDeviceStatusByRoom(
                                        controller.selectedRoom.roomId,
                                      ) ==
                                      "Aktif"
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  titleFontSize: 20,
                  headerHeight: 70,
                  content: Obx(() {
                    if (controller.filteredRoomList.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada data ruangan',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
                    final room = controller
                        .filteredRoomList[controller.selectedRoomIndex.value];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.27,
                          child: Column(
                            children: [
                              CustomStableTankCard(
                                isWater: true,
                                current: room.remainingWater.value,
                                max: 5,
                                phLevel: 7.2,
                                lastText: controller.getLastFeedText(room),
                                getTankImageAsset:
                                    controller.getStableTankImageAsset,
                              ),
                              SizedBox(height: 16),
                              CustomStableTankCard(
                                isWater: false,
                                current: room.remainingFeed.value,
                                max: 50,
                                lastText: controller.getLastFeedText(room),
                                getTankImageAsset:
                                    controller.getStableTankImageAsset,
                              ),
                              SizedBox(height: 8),
                              if (controller.selectedRoom.waterScheduleType ==
                                      'penjadwalan' ||
                                  controller.selectedRoom.waterScheduleType ==
                                      'otomatis') ...[
                                SizedBox(height: 16),
                                Tooltip(
                                  message: 'Isi Otomatis Air Dalam Waktu',
                                  child: Container(
                                    height: 70,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Obx(
                                        () => Text(
                                          controller.formatDuration(
                                            controller
                                                .getWaterSecondsUntilNextAutoFeed(
                                                  controller.selectedRoom,
                                                ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (controller.selectedRoom.waterScheduleType ==
                                  'manual') ...[
                                SizedBox(height: 16),
                                CustomButton(
                                  text: 'Isi Air',
                                  onPressed: () {
                                    showFillWaterDialog(
                                      context: context,
                                      stableName: controller.selectedRoom.name,
                                      mainTankWater:
                                          controller.airTankCurrent.value,
                                      onSubmit: (water) {},
                                    );
                                  },
                                  fontSize: 24,
                                  iconSize: 30,
                                  height: 70,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  borderRadius: 10,
                                  icon: Icons.water_drop_rounded,
                                ),
                              ],
                              if (controller.selectedRoom.feedScheduleType ==
                                      'penjadwalan' ||
                                  controller.selectedRoom.feedScheduleType ==
                                      'otomatis') ...[
                                SizedBox(height: 16),
                                Tooltip(
                                  message: 'Isi Otomatis Pakan Dalam Waktu',
                                  child: Container(
                                    height: 70,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.deepOrange,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Obx(
                                        () => Text(
                                          controller.formatDuration(
                                            controller
                                                .getFeedSecondsUntilNextAutoFeed(
                                                  controller.selectedRoom,
                                                ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (controller.selectedRoom.feedScheduleType ==
                                  'manual') ...[
                                SizedBox(height: 16),
                                CustomButton(
                                  text: 'Isi Pakan',
                                  onPressed: () {
                                    showFillFeedDialog(
                                      context: context,
                                      stableName: controller.selectedRoom.name,
                                      mainTankFeed:
                                          controller.feedTankCurrent.value,
                                      onSubmit: (water) {},
                                    );
                                  },
                                  fontSize: 24,
                                  iconSize: 30,
                                  height: 70,
                                  backgroundColor: Colors.deepOrange,
                                  textColor: Colors.white,
                                  borderRadius: 10,
                                  icon: Icons.food_bank_rounded,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            width: 2,
                            height: MediaQuery.of(context).size.height * 0.6,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Penjadwalan:',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Container(
                                      height: 70,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            controller
                                                    .selectedRoom
                                                    .feedScheduleType ==
                                                'penjadwalan'
                                            ? Colors.teal.withOpacity(0.2)
                                            : controller
                                                      .selectedRoom
                                                      .feedScheduleType ==
                                                  'otomatis'
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              controller
                                                      .selectedRoom
                                                      .feedScheduleType ==
                                                  'penjadwalan'
                                              ? Colors.teal
                                              : controller
                                                        .selectedRoom
                                                        .feedScheduleType ==
                                                    'otomatis'
                                              ? Colors.blue
                                              : Colors.orange,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Obx(
                                          () => Text(
                                            'Pakan: ${controller.selectedRoom.feedScheduleType == 'penjadwalan'
                                                ? 'Penjadwalan'
                                                : controller.selectedRoom.feedScheduleType == 'otomatis'
                                                ? 'Otomatis'
                                                : 'Manual'}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  controller
                                                          .selectedRoom
                                                          .feedScheduleType ==
                                                      'penjadwalan'
                                                  ? Colors.teal
                                                  : controller
                                                            .selectedRoom
                                                            .feedScheduleType ==
                                                        'otomatis'
                                                  ? Colors.blue
                                                  : Colors.orange,
                                              // color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Flexible(
                                    flex: 2,
                                    child: Container(
                                      height: 70,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            controller
                                                    .selectedRoom
                                                    .waterScheduleType ==
                                                'penjadwalan'
                                            ? Colors.teal.withOpacity(0.2)
                                            : controller
                                                      .selectedRoom
                                                      .waterScheduleType ==
                                                  'otomatis'
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              controller
                                                      .selectedRoom
                                                      .waterScheduleType ==
                                                  'penjadwalan'
                                              ? Colors.teal
                                              : controller
                                                        .selectedRoom
                                                        .waterScheduleType ==
                                                    'otomatis'
                                              ? Colors.blue
                                              : Colors.orange,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Obx(
                                          () => Text(
                                            'Air: ${controller.selectedRoom.waterScheduleType == 'penjadwalan'
                                                ? 'Penjadwalan'
                                                : controller.selectedRoom.waterScheduleType == 'otomatis'
                                                ? 'Otomatis'
                                                : 'Manual'}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  controller
                                                          .selectedRoom
                                                          .waterScheduleType ==
                                                      'penjadwalan'
                                                  ? Colors.teal
                                                  : controller
                                                            .selectedRoom
                                                            .waterScheduleType ==
                                                        'otomatis'
                                                  ? Colors.blue
                                                  : Colors.orange,
                                              // color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: CustomButton(
                                  text: 'Ubah Jadwal',
                                  onPressed: () {
                                    final index =
                                        controller.selectedRoomIndex.value;
                                    controller.selectedRoomIndex.value = index;
                                    print('ini index ke $index');
                                    layoutController.setPage(
                                      ControlSchedulePage(roomSelected: index),
                                      'Kontrol Penjadwalan',
                                    );
                                  },
                                  height: 70,
                                  width: 120,
                                  fontSize: 20,
                                  iconSize: 30,
                                  backgroundColor: AppColors.primary,
                                  textColor: Colors.white,
                                  iconTrailing:
                                      Icons.keyboard_arrow_right_rounded,
                                ),
                              ),
                              SizedBox(height: 16),
                              CustomCard(
                                title: 'Riwayat Pengisian',
                                headerHeight: 50,
                                titleFontSize: 20,
                                content: SizedBox(
                                  height: 500, // Atur tinggi sesuai kebutuhan
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    child: Obx(() {
                                      final selectedIndex =
                                          controller.selectedRoomIndex.value;
                                      if (controller.filteredRoomList.isEmpty) {
                                        return Center(
                                          child: Text('Belum ada ruangan'),
                                        );
                                      }
                                      final selectedRoomId = controller
                                          .filteredRoomList[selectedIndex]
                                          .roomId;
                                      final selectedHistory = controller
                                          .historyEntryList
                                          .where(
                                            (item) =>
                                                item.roomId == selectedRoomId,
                                          )
                                          .toList();
                                      if (selectedHistory.isEmpty) {
                                        return Center(
                                          child: Text('Belum ada riwayat'),
                                        );
                                      }
                                      return ListView.builder(
                                        itemCount: selectedHistory.length,
                                        itemBuilder: (context, index) {
                                          final item = selectedHistory[index];
                                          return HistoryEntryCard(
                                            datetime: item.date,
                                            water: item.water,
                                            feed: item.feed,
                                            scheduleText: item.type,
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 170,
                  child: CustomCard(
                    title: 'Status Feeder Device',
                    headerHeight: 50,
                    titleFontSize: 20,
                    scrollable: false,
                    content: Obx(
                      () => Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Tooltip(
                              message: 'Baterai Device',
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      controller
                                              .getFeederDeviceBatteryPercent() <
                                          20
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.teal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        controller
                                                .getFeederDeviceBatteryPercent() <
                                            20
                                        ? Colors.red
                                        : Colors.teal,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: CustomBatteryIndicator(
                                    percent: controller
                                        .getFeederDeviceBatteryPercent(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Flexible(
                            flex: 2,
                            child: Tooltip(
                              message: 'Koneksi Device',
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    controller.getFeederDeviceStatus() ==
                                            'ready'
                                        ? 'Aktif'
                                        : 'Mati',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                CustomCard(
                  title: 'Daftar Ruangan',
                  trailing: Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        controller.getStableNameById(
                          controller.selectedStableId.value,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  content: SizedBox(
                    height: 1000,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: controller.filteredRoomList.length,
                        itemBuilder: (context, index) {
                          final room = controller.filteredRoomList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CustomStableCard(
                              stableName: room.name,
                              imageAsset: 'assets/images/stable.jpg',
                              feedScheduleText: room.feedScheduleType.value,
                              waterScheduleText: room.waterScheduleType.value,
                              isActive:
                                  controller.getDeviceStatusByRoom(
                                        room.roomId,
                                      ) ==
                                      "Aktif"
                                  ? true
                                  : false,
                              remainingWater: room.remainingWater,
                              remainingFeed: room.remainingFeed,
                              lastFeedText: controller.getLastFeedText(room),
                              onSelect: () {
                                controller.selectedRoomIndex.value = index;
                              },
                              primaryColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
