// ignore_for_file: unrelated_type_equality_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/layout/feeder_layout_controller.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_battery_indicator.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_feeder_history_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_history_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_tank_card.dart';
import 'package:toastification/toastification.dart';

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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
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
                    onPressed: () {
                      Get.back();
                    },
                    fontSize: 20,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 16), // jarak antar tombol
                Expanded(
                  child: CustomButton(
                    text: 'Isi',
                    onPressed: () {
                      final input = double.tryParse(feedController.text) ?? 0.0;
                      final maxFeed = 50.0; // kapasitas maksimal tempat makan
                      final remainingFeed =
                          controller.selectedRoom.remainingFeed;
                      if (input <= 0) {
                        showAppToast(
                          context: context,
                          type: ToastificationType.error,
                          title: 'Input Tidak Valid',
                          description: 'Jumlah pakan harus lebih dari 0.',
                        );
                        return;
                      }
                      if (input + remainingFeed > maxFeed) {
                        showAppToast(
                          context: context,
                          type: ToastificationType.error,
                          title: 'Kapasitas Melebihi Batas',
                          description:
                              'Total pakan (${(input + remainingFeed).toStringAsFixed(1)}g) melebihi kapasitas maksimal ($maxFeed g).',
                        );
                        return;
                      }
                      // mqtt.publishDeliveryRequest(
                      //   deviceId: controller.getFeederDevice()!.deviceId,
                      //   destination: controller.selectedRoom.roomId,
                      //   amount: double.tryParse(feedController.text) ?? 0.0,
                      // );
                      showAppToast(
                        context: context,
                        type: ToastificationType.success,
                        title: 'Tempat Pakan Di isi',
                        description: 'Pakan Segera Di isi Sebanyak ($input g).',
                      );
                      Get.back();
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

  // Future<void> showFillWaterDialog({
  //   required BuildContext context,
  //   required String stableName,
  //   required double mainTankWater,
  //   required Function(double water) onSubmit,
  // }) async {
  //   final TextEditingController waterController = TextEditingController();

  //   await showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         title: Container(
  //           height: 70,
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.blue.withOpacity(0.2),
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(color: Colors.blue, width: 1),
  //           ),
  //           child: Center(
  //             child: Text(
  //               'Isi Air Ruangan',
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.blue,
  //               ),
  //             ),
  //           ),
  //         ),
  //         content: SizedBox(
  //           width: 400,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // Nama Kandang
  //               Row(
  //                 children: [
  //                   const Text(
  //                     'Ruangan:',
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 20,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Text(
  //                     stableName,
  //                     style: const TextStyle(
  //                       fontSize: 24,
  //                       color: AppColors.primary,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 14),
  //               CustomInput(
  //                 label: 'Jumlah Air yang akan diisi (liter)',
  //                 fontSize: 18,
  //                 controller: waterController,
  //                 hint: 'Masukkan jumlah air',
  //                 icon: Icons.water,
  //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
  //               ),
  //               const SizedBox(height: 6),
  //               Row(
  //                 children: [
  //                   const Text(
  //                     'Sisa air tanki utama: ',
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                   Text(
  //                     '${mainTankWater.round()} Liter',
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.blue,
  //                       fontSize: 20,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: CustomButton(
  //                   text: 'Batal',
  //                   hasShadow: false,
  //                   onPressed: () {
  //                     Get.back();
  //                   },
  //                   fontSize: 20,
  //                   borderColor: Colors.red,
  //                   backgroundColor: Colors.transparent,
  //                   textColor: Colors.red,
  //                 ),
  //               ),
  //               SizedBox(width: 16), // jarak antar tombol
  //               Expanded(
  //                 child: CustomButton(
  //                   text: 'Isi',
  //                   onPressed: () {
  //                     print(controller.selectedRoom.roomId);
  //                     mqtt.publishDeliveryRequest(
  //                       destination: controller.selectedRoom.roomId,
  //                       amount: double.tryParse(waterController.text) ?? 0.0,
  //                     );
  //                   },
  //                   fontSize: 20,
  //                   backgroundColor: Colors.green,
  //                   textColor: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                  trailing: Obx(() {
                    if (controller.selectedRoomIndex.value < 0 ||
                        controller.filteredRoomList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return Row(
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
                        // SizedBox(width: 8),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 16,
                        //     vertical: 8,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color:
                        //         controller.getDeviceStatusByRoom(
                        //               controller.selectedRoom.roomId,
                        //             ) ==
                        //             "Aktif"
                        //         ? Colors.green.withOpacity(0.2)
                        //         : Colors.red.withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(8),
                        //     border: Border.all(
                        //       color:
                        //           controller.getDeviceStatusByRoom(
                        //                 controller.selectedRoom.roomId,
                        //               ) ==
                        //               "Aktif"
                        //           ? Colors.green
                        //           : Colors.red,
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: Text(
                        //     controller.getDeviceStatusByRoom(
                        //               controller.selectedRoom.roomId,
                        //             ) ==
                        //             "Aktif"
                        //         ? 'Aktif'
                        //         : 'Tidak Aktif',
                        //     style: TextStyle(
                        //       color:
                        //           controller.getDeviceStatusByRoom(
                        //                 controller.selectedRoom.roomId,
                        //               ) ==
                        //               "Aktif"
                        //           ? Colors.green
                        //           : Colors.red,
                        //       fontSize: 20,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  }),
                  titleFontSize: 20,
                  headerHeight: 70,
                  content: Obx(() {
                    if (controller.filteredRoomList.isEmpty ||
                        controller.selectedRoomIndex.value < 0 ||
                        controller.selectedRoomIndex.value >=
                            controller.filteredRoomList.length) {
                      return Center(
                        child: Text(
                          'Tidak ada data ruangan',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
                    // final room = controller
                    //     .filteredRoomList[controller.selectedRoomIndex.value];

                    final selectedRoom = controller.selectedRoom;
                    final device = controller.feederDeviceList.firstWhereOrNull(
                      (d) => d.stableId == selectedRoom.stableId,
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.26,
                          child: Column(
                            children: [
                              CustomStableTankCard(
                                isWater: true,
                                current:
                                    controller
                                        .getDevicesByRoomId(selectedRoom.roomId)
                                        ?.waterRemaining ??
                                    'kosong',
                                max: 5,
                                lastText: controller.getLastWaterFromHistory(
                                  selectedRoom,
                                ),
                                getTankImageAsset:
                                    controller.getStableTankImageAsset,
                              ),
                              SizedBox(height: 16),
                              CustomStableTankCard(
                                isWater: false,
                                current: selectedRoom.remainingFeed,
                                max: 50,
                                lastText: controller.getLastFeedFromHistory(
                                  selectedRoom,
                                ),
                                getTankImageAsset:
                                    controller.getStableTankImageAsset,
                              ),
                              SizedBox(height: 8),
                              // if (controller.selectedRoom.waterScheduleType ==
                              //         'penjadwalan' ||
                              //     controller.selectedRoom.waterScheduleType ==
                              //         'auto') ...[
                              //   SizedBox(height: 16),
                              //   Tooltip(
                              //     message: 'Isi auto Air Dalam Waktu',
                              //     child: Container(
                              //       height: 70,
                              //       padding: const EdgeInsets.all(16),
                              //       decoration: BoxDecoration(
                              //         color: Colors.blue.withOpacity(0.2),
                              //         borderRadius: BorderRadius.circular(12),
                              //         border: Border.all(
                              //           color: Colors.blue,
                              //           width: 1,
                              //         ),
                              //       ),
                              //       child: Center(
                              //         child: Obx(
                              //           () => Text(
                              //             controller.formatDuration(
                              //               controller
                              //                   .getWaterSecondsUntilNextAutoFeed(
                              //                     controller.selectedRoom,
                              //                   ),
                              //             ),
                              //             style: TextStyle(
                              //               fontSize: 24,
                              //               fontWeight: FontWeight.bold,
                              //               color: Colors.blue,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ],
                              // if (controller.selectedRoom.waterScheduleType ==
                              //         'manual' ||
                              //     controller.selectedRoom.waterScheduleType ==
                              //         '') ...[
                              //   SizedBox(height: 16),
                              //   CustomButton(
                              //     text: 'Isi Air',
                              //     onPressed: () {
                              //       showFillWaterDialog(
                              //         context: context,
                              //         stableName: controller.selectedRoom.name,
                              //         mainTankWater:
                              //             controller.airTankCurrent.value,
                              //         onSubmit: (water) {},
                              //       );
                              //     },
                              //     fontSize: 24,
                              //     iconSize: 30,
                              //     height: 70,
                              //     backgroundColor: Colors.blue,
                              //     textColor: Colors.white,
                              //     borderRadius: 10,
                              //     icon: Icons.water_drop_rounded,
                              //   ),
                              // ],
                              if (device?.scheduleType == 'penjadwalan') ...[
                                SizedBox(height: 16),
                                Tooltip(
                                  message: 'Isi auto Pakan Dalam Waktu',
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
                              if (device?.scheduleType == 'manual' ||
                                  device?.scheduleType == '') ...[
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
                              CustomCard(
                                title: 'Riwayat Pengisian',
                                headerHeight: 50,
                                titleFontSize: 20,
                                content: SizedBox(
                                  height: 540,
                                  child: DefaultTabController(
                                    length: 2,
                                    child: Column(
                                      children: [
                                        TabBar(
                                          labelColor: AppColors.primary,
                                          unselectedLabelColor: Colors.black54,
                                          indicatorColor: AppColors.primary,
                                          tabs: const [
                                            Tab(
                                              text: 'Pakan',
                                              icon: Icon(
                                                Icons.restaurant_rounded,
                                              ),
                                            ),
                                            Tab(
                                              text: 'Air',
                                              icon: Icon(
                                                Icons.water_drop_rounded,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: TabBarView(
                                            children: [
                                              // === TAB PAKAN ===
                                              Obx(() {
                                                final selectedIndex = controller
                                                    .selectedRoomIndex
                                                    .value;
                                                if (controller
                                                    .filteredRoomList
                                                    .isEmpty) {
                                                  return Center(
                                                    child: Text(
                                                      'Tidak Ada Ruangan',
                                                      style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                final selectedRoomId = controller
                                                    .filteredRoomList[selectedIndex]
                                                    .roomId;
                                                final selectedHistory =
                                                    controller
                                                        .feederDeviceHistoryList
                                                        .where(
                                                          (item) =>
                                                              item.roomId ==
                                                              selectedRoomId,
                                                        )
                                                        .where(
                                                          (item) =>
                                                              item.type ==
                                                              'feed',
                                                        )
                                                        .toList();

                                                if (selectedHistory.isEmpty) {
                                                  return Center(
                                                    child: Text(
                                                      'Belum Ada Riwayat Pakan',
                                                      style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                final showMax = 10;
                                                final showSelengkapnya =
                                                    selectedHistory.length >
                                                    showMax;
                                                final displayHistory =
                                                    showSelengkapnya
                                                    ? selectedHistory.sublist(
                                                        0,
                                                        showMax,
                                                      )
                                                    : selectedHistory;

                                                return Column(
                                                  children: [
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount:
                                                            displayHistory
                                                                .length,
                                                        itemBuilder: (context, index) {
                                                          final item =
                                                              displayHistory[index];
                                                          return CustomFeederHistoryCard(
                                                            type: 'feed',
                                                            amount: item.amount,
                                                            timestamp:
                                                                item.timestamp,
                                                            mode: item.mode,
                                                            deviceId:
                                                                item.deviceId,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    if (showSelengkapnya)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 4,
                                                            ),
                                                        child: CustomButton(
                                                          text: 'Selengkapnya',
                                                          backgroundColor:
                                                              AppColors.primary,
                                                          textColor:
                                                              Colors.white,
                                                          icon: Icons.list,
                                                          onPressed: () {
                                                            // TODO: tampilkan halaman/modal riwayat lengkap
                                                          },
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              }),
                                              // === TAB AIR ===
                                              Obx(() {
                                                final selectedIndex = controller
                                                    .selectedRoomIndex
                                                    .value;
                                                if (controller
                                                    .filteredRoomList
                                                    .isEmpty) {
                                                  return Center(
                                                    child: Text(
                                                      'Tidak Ada Ruangan',
                                                      style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                final selectedRoomId = controller
                                                    .filteredRoomList[selectedIndex]
                                                    .roomId;
                                                final selectedHistory =
                                                    controller
                                                        .feederDeviceHistoryList
                                                        .where(
                                                          (item) =>
                                                              item.roomId ==
                                                              selectedRoomId,
                                                        )
                                                        .where(
                                                          (item) =>
                                                              item.type ==
                                                              'water',
                                                        )
                                                        .toList();

                                                if (selectedHistory.isEmpty) {
                                                  return Center(
                                                    child: Text(
                                                      'Belum Ada Riwayat Pakan',
                                                      style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                final showMax = 10;
                                                final showSelengkapnya =
                                                    selectedHistory.length >
                                                    showMax;
                                                final displayHistory =
                                                    showSelengkapnya
                                                    ? selectedHistory.sublist(
                                                        0,
                                                        showMax,
                                                      )
                                                    : selectedHistory;

                                                return Column(
                                                  children: [
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount:
                                                            displayHistory
                                                                .length,
                                                        itemBuilder: (context, index) {
                                                          final item =
                                                              displayHistory[index];
                                                          return CustomFeederHistoryCard(
                                                            type: 'water',
                                                            status: item.status,
                                                            timestamp:
                                                                item.timestamp,
                                                            mode: item.mode,
                                                            deviceId:
                                                                item.deviceId,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    if (showSelengkapnya)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 4,
                                                            ),
                                                        child: CustomButton(
                                                          text: 'Selengkapnya',
                                                          backgroundColor:
                                                              AppColors.primary,
                                                          textColor:
                                                              Colors.white,
                                                          icon: Icons.list,
                                                          onPressed: () {
                                                            // TODO: tampilkan halaman/modal riwayat lengkap
                                                          },
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              }),
                                              // Untuk tab air, ganti dengan list history air jika sudah ada model/datanya
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                  height: 289,
                  child: CustomCard(
                    title: 'Status Feeder Device',
                    trailing: Obx(() {
                      if (controller.filteredRoomList.isEmpty ||
                          controller.selectedRoomIndex.value < 0 ||
                          controller.selectedRoomIndex.value >=
                              controller.filteredRoomList.length) {
                        return Container(
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
                            '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      final selectedRoom = controller.selectedRoom;
                      // Cari device yang stableId-nya sama dengan stableId ruangan yang dipilih
                      final device = controller.feederDeviceList
                          .firstWhereOrNull(
                            (d) => d.stableId == selectedRoom.stableId,
                          );
                      return Container(
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
                          device?.deviceId ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                    headerHeight: 50,
                    withExpanded: false,
                    titleFontSize: 20,
                    scrollable: false,
                    content: Obx(() {
                      if (controller.filteredRoomList.isEmpty ||
                          controller.selectedRoomIndex.value < 0 ||
                          controller.selectedRoomIndex.value >=
                              controller.filteredRoomList.length) {
                        return Center(
                          child: Text(
                            'Tidak ada data ruangan',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }
                      final selectedRoom = controller.selectedRoom;
                      final device = controller.feederDeviceList
                          .firstWhereOrNull(
                            (d) => d.stableId == selectedRoom.stableId,
                          );

                      // Ambil detail dari deviceId
                      final detail = controller.feederDeviceDetailList
                          .firstWhereOrNull(
                            (det) => det.deviceId == device?.deviceId,
                          );

                      final scheduleType = device?.scheduleType;
                      final batteryPercent = detail?.batteryPercent ?? 0;
                      final status = detail?.status ?? 'off';

                      String textStatus = '';
                      if (detail != null) {
                        switch (detail.status) {
                          case 'delivery':
                            textStatus =
                                'Feeder Mengantar Ke ${detail.destination?.toUpperCase() ?? "-"}'
                                '${(detail.amount != null && detail.amount! > 0) ? " (${detail.amount} g)" : ""}';
                            break;
                          case 'arrived':
                            textStatus =
                                'Feeder Sampai Di ${detail.destination?.toUpperCase() ?? "-"}';
                            break;
                          case 'process':
                            textStatus =
                                'Feeder Mengisi ${detail.destination?.toUpperCase() ?? "-"}';
                            break;
                          case 'done':
                            textStatus =
                                'Feeder Selesai mengisi ${detail.destination?.toUpperCase() ?? "-"}';
                            break;
                          case 'return':
                            textStatus = detail.destination == 'home'
                                ? 'Feeder Kembali ke Home'
                                : 'Feeder Kembali ke ${detail.destination?.toUpperCase() ?? "-"}';
                            break;
                          case 'ready':
                            textStatus = 'Feeder Di Home';
                            break;
                          case 'off':
                            textStatus = 'Feeder Tidak Aktif';
                            break;
                          default:
                            textStatus = 'Status Tidak Diketahui';
                        }
                      } else {
                        textStatus = 'Status Tidak Diketahui';
                      }

                      IconData getStatusIcon(String status) {
                        switch (status) {
                          case 'delivery':
                            return Icons.local_shipping_rounded; // pengiriman
                          case 'arrived':
                            return Icons
                                .inventory_2_rounded; // sudah tiba / diterima
                          case 'process':
                            return Icons.settings_rounded; // sedang diproses
                          case 'done':
                            return Icons.check_circle_rounded; // selesai
                          case 'return':
                            return Icons.undo_rounded; // retur / kembali
                          case 'ready':
                            return Icons
                                .house_siding_rounded; // siap diambil / ready
                          case 'off':
                            return Icons
                                .power_settings_new_rounded; // mati / nonaktif
                          default:
                            return Icons.help_outline_rounded; // tidak dikenal
                        }
                      }

                      Color statusColor = status != 'off'
                          ? Colors.green
                          : Colors.red;

                      Color statusColorWithOpacity = status != 'off'
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3);

                      String statusLabel = status != 'off' ? 'Aktif' : 'Mati';

                      return Column(
                        children: [
                          Row(
                            children: [
                              // Baterai
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 77,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: batteryPercent < 20
                                        ? Colors.red.withOpacity(0.3)
                                        : Colors.green.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: batteryPercent < 20
                                          ? Colors.red
                                          : Colors.green,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        batteryPercent < 20
                                            ? Icons.battery_alert
                                            : Icons.battery_full,
                                        color: batteryPercent < 20
                                            ? Colors.red
                                            : Colors.green,
                                        size: 30,
                                      ),
                                      Text(
                                        '$batteryPercent%',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: batteryPercent < 20
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 77,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheduleType == 'penjadwalan'
                                        ? Colors.teal.withOpacity(0.15)
                                        : scheduleType == 'auto'
                                        ? Colors.blue.withOpacity(0.15)
                                        : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: scheduleType == 'penjadwalan'
                                          ? Colors.teal
                                          : scheduleType == 'auto'
                                          ? Colors.blue
                                          : Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        scheduleType == 'auto'
                                            ? Icons.autorenew_rounded
                                            : scheduleType == 'penjadwalan'
                                            ? Icons.schedule_rounded
                                            : scheduleType == 'manual'
                                            ? Icons.settings_rounded
                                            : Icons.help_outline,
                                        color: scheduleType == 'penjadwalan'
                                            ? Colors.teal
                                            : scheduleType == 'auto'
                                            ? Colors.blue
                                            : Colors.orange[800],
                                        size: 30,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        scheduleType == 'penjadwalan'
                                            ? 'Penjadwalan'
                                            : scheduleType == 'auto'
                                            ? 'Otomatis'
                                            : scheduleType == 'manual'
                                            ? 'Manual'
                                            : '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: scheduleType == 'penjadwalan'
                                              ? Colors.teal
                                              : scheduleType == 'auto'
                                              ? Colors.blue
                                              : Colors.orange[800],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Status Aktif
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 77,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColorWithOpacity,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: statusColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.power_settings_new_rounded,
                                            color: statusColor,
                                            size: 30,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // if (status == 'delivery' && destination != null && destination != '')
                          SizedBox(height: 8),
                          // if (status == 'delivery' && destination != null && destination != '')
                          // Expanded(
                          //   child: Container(
                          //     width: double.infinity,
                          //     padding: EdgeInsets.symmetric(
                          //       horizontal: 14,
                          //       vertical: 12,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: scheduleType == 'penjadwalan'
                          //           ? Colors.teal.withOpacity(0.15)
                          //           : scheduleType == 'auto'
                          //           ? Colors.blue.withOpacity(0.15)
                          //           : Colors.orange.withOpacity(0.15),
                          //       borderRadius: BorderRadius.circular(14),
                          //       border: Border.all(
                          //         color: scheduleType == 'penjadwalan'
                          //             ? Colors.teal
                          //             : scheduleType == 'auto'
                          //             ? Colors.blue
                          //             : Colors.orange,
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Icon(
                          //           scheduleType == 'auto'
                          //               ? Icons.local_shipping
                          //               : scheduleType == 'penjadwalan'
                          //               ? Icons.settings
                          //               : scheduleType == 'manual'
                          //               ? Icons.check_circle_outline
                          //               : Icons.help_outline,
                          //           color: scheduleType == 'penjadwalan'
                          //               ? Colors.teal
                          //               : scheduleType == 'auto'
                          //               ? Colors.blue
                          //               : Colors.orange,
                          //           size: 30,
                          //         ),
                          //         SizedBox(width: 10),
                          //         Text(
                          //           'Mode Operasi: ${scheduleType?[0].toUpperCase()}${scheduleType?.substring(1)}',
                          //           style: TextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.bold,
                          //             color: scheduleType == 'penjadwalan'
                          //                 ? Colors.teal
                          //                 : scheduleType == 'auto'
                          //                 ? Colors.blue
                          //                 : Colors.orange,
                          //           ),
                          //           maxLines: 1,
                          //           overflow: TextOverflow.ellipsis,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    getStatusIcon(status),
                                    color: Colors.orange,
                                    size: 60,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    textStatus,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
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
                    height: MediaQuery.of(context).size.height * 0.58,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: Obx(() {
                        return ListView.builder(
                          itemCount: controller.filteredRoomList.length,
                          itemBuilder: (context, index) {
                            final room = controller.filteredRoomList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 8,
                              ),
                              child: Obx(
                                () => CustomStableCard(
                                  stableName: room.name,
                                  stableId: room.roomId,
                                  imageAsset: 'assets/images/stable.jpg',
                                  isActive:
                                      controller.getDeviceStatusByRoom(
                                        room.roomId,
                                      ) ==
                                      "Aktif",
                                  remainingWater:
                                      (controller
                                                  .getDevicesByRoomId(
                                                    room.roomId,
                                                  )
                                                  ?.waterRemaining ??
                                              'kosong')
                                          .toString()
                                          .replaceFirstMapped(
                                            RegExp(r'^[a-zA-Z]'),
                                            (match) =>
                                                match.group(0)!.toUpperCase(),
                                          ),
                                  remainingFeed: room.remainingFeed.obs,
                                  lastFeedText: controller
                                      .getLastFeedFromHistory(room),
                                  onSelect: () {
                                    controller.selectedRoomIndex.value = index;
                                  },
                                  primaryColor: AppColors.primary,
                                  isSelected:
                                      controller.selectedRoomIndex.value ==
                                      index,
                                ),
                              ),
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
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'delivery':
        return 'Sedang Perjalanan';
      case 'process':
        return 'Sedang Mengisi';
      case 'return':
        return 'Kembali ke Home';
      case 'ready':
        return 'Siap Digunakan';
      case 'on':
        return 'Idle';
      case 'done':
        return 'Selesai Mengisi';
      case 'off':
        return 'Tidak Aktif';
      default:
        return 'Status Tidak Diketahui';
    }
  }
}
