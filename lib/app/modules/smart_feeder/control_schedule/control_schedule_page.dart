import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:toastification/toastification.dart';

class ControlSchedulePage extends StatefulWidget {
  final int roomSelected;

  const ControlSchedulePage({super.key, this.roomSelected = 0});

  @override
  State<ControlSchedulePage> createState() => _ControlSchedulePageState();
}

class _ControlSchedulePageState extends State<ControlSchedulePage> {
  final ControlScheduleController controller = Get.find();
  final FeederDashboardController feederController = Get.find();

  int _selectedTab = 0; // 0: Air, 1: Pakan
  String selectedMode = "Penjadwalan";
  int intervalJam = 2; // default 2 jam

  @override
  void initState() {
    super.initState();
    controller.selectedRoomIndex.value = widget.roomSelected;
  }

  @override
  Widget build(BuildContext context) {
    final isAir = _selectedTab == 0;
    final colorMain = isAir ? Colors.blue : Colors.deepOrange;
    final satuan = isAir ? "Liter" : "Gram";

    Color airBg = isAir ? Colors.blue : Colors.blue.withOpacity(0.1);
    Color airText = isAir ? Colors.white : Colors.blue;
    Color airBorder = isAir ? Colors.transparent : Colors.blue;
    Color pakanBg = !isAir
        ? Colors.deepOrange
        : Colors.deepOrange.withOpacity(0.1);
    Color pakanText = !isAir ? Colors.white : Colors.deepOrange;
    Color pakanBorder = !isAir ? Colors.transparent : Colors.deepOrange;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        withExpanded: false,
        title: 'Kontrol Penjadwalan',
        content: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Ruangan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Dropdown Pilih Kandang di atas
                SizedBox(
                  width: 350,
                  child: DropdownButtonFormField<RoomModel>(
                    value: controller.selectedRoom,
                    items: controller.filteredRoomList
                        .map(
                          (kandang) => DropdownMenuItem(
                            value: kandang,
                            child: Text(kandang.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          controller.selectedRoomIndex.value = controller
                              .roomList
                              .indexOf(val);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Pilih Kandang",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pilih Menu Kontrol',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CustomButton(
                      text: 'Air',
                      width: 150,
                      onPressed: () {
                        setState(() => _selectedTab = 0);
                      },
                      backgroundColor: airBg,
                      textColor: airText,
                      borderColor: airBorder,
                      fontSize: 26,
                      height: 60,
                      borderRadius: 12,
                      hasShadow: false,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      width: 150,
                      text: 'Pakan',
                      onPressed: () {
                        setState(() => _selectedTab = 1);
                      },
                      backgroundColor: pakanBg,
                      textColor: pakanText,
                      fontSize: 26,
                      height: 60,
                      borderRadius: 12,
                      hasShadow: false,
                      borderColor: pakanBorder,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.63,
                  child: CustomCard(
                    withExpanded: false,
                    title: 'Atur Jadwal',
                    scrollable: false,
                    titleFontSize: 20,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informasi Kandang & Sisa
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container Kandang Info
                            SizedBox(
                              width: 280,
                              height: 210,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.25),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/stable.jpg',
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          controller.selectedRoom.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                controller
                                                        .selectedRoom
                                                        .status ==
                                                    'used'
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            controller.selectedRoom.status ==
                                                    'used'
                                                ? 'Aktif'
                                                : 'Tidak Aktif',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Terakhir: ',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          controller.getLastFeedText(
                                            controller.selectedRoom,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Flexible(
                              child: SizedBox(
                                height: 210,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorMain.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorMain),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Obx(() {
                                              final room =
                                                  feederController
                                                      .roomList[controller
                                                      .selectedRoomIndex
                                                      .value];
                                              final lessContent = isAir
                                                  ? controller.maxWater -
                                                        room
                                                            .remainingWater
                                                            .value
                                                  : controller.maxFeed -
                                                        room
                                                            .remainingFeed
                                                            .value;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Tersedia ${isAir ? "Air" : "Pakan"} di Kandang:',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    isAir
                                                        ? '${room.remainingWater.value.toStringAsFixed(1)} $satuan'
                                                        : '${room.remainingFeed.value.toStringAsFixed(1)} $satuan',
                                                    style: TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorMain,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Kebutuhan Isi Tempat:',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    isAir
                                                        ? '${lessContent.clamp(0, controller.maxWater).toStringAsFixed(1)} $satuan'
                                                        : '${lessContent.clamp(0, controller.maxFeed).toStringAsFixed(1)} $satuan',
                                                    // '${kurangIsi.clamp(0, isAir ? controller.maxWater : controller.maxFeed).toStringAsFixed(1)} ',
                                                    style: TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorMain,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                            const SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Kuda: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: controller
                                                            .getHorseById(
                                                              controller
                                                                  .selectedRoom
                                                                  .horseId!,
                                                            )
                                                            .name,
                                                        style: TextStyle(
                                                          color: colorMain,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' (${controller.getHorseById(controller.selectedRoom.horseId!).horseId})',
                                                        style: const TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Umur: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: controller
                                                            .getHorseById(
                                                              controller
                                                                  .selectedRoom
                                                                  .horseId!,
                                                            )
                                                            .age,
                                                        style: TextStyle(
                                                          color: colorMain,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      const TextSpan(
                                                        text: 'Jenis: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            controller
                                                                    .getHorseById(
                                                                      controller
                                                                          .selectedRoom
                                                                          .horseId!,
                                                                    )
                                                                    .type ==
                                                                "local"
                                                            ? "Lokal"
                                                            : "Crossbred",
                                                        style: TextStyle(
                                                          color: colorMain,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: '  |  Kelamin: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            controller
                                                                    .getHorseById(
                                                                      controller
                                                                          .selectedRoom
                                                                          .horseId!,
                                                                    )
                                                                    .gender ==
                                                                "male"
                                                            ? "Jantan"
                                                            : "Betina",
                                                        style: TextStyle(
                                                          color: colorMain,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Kesehatan: ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: controller
                                                            .getHorseHealthStatusById(
                                                              controller
                                                                  .selectedRoom
                                                                  .horseId!,
                                                            ),
                                                        style: TextStyle(
                                                          color:
                                                              controller.getHorseHealthStatusById(
                                                                    controller
                                                                        .selectedRoom
                                                                        .horseId!,
                                                                  ) ==
                                                                  "Sehat"
                                                              ? Colors.green
                                                              : Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 24),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: double.infinity,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Mode Penjadwalan:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 300,
                                    child: DropdownButtonFormField<String>(
                                      value: selectedMode,
                                      items: [
                                        DropdownMenuItem(
                                          value: "Penjadwalan",
                                          child: Text("Penjadwalan"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Otomatis",
                                          child: Text("Otomatis"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Manual",
                                          child: Text("Manual"),
                                        ),
                                      ],
                                      onChanged: (val) => setState(
                                        () =>
                                            selectedMode = val ?? "Penjadwalan",
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: colorMain.withOpacity(0.07),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Input interval: dropdown angka 1-24
                                  if (selectedMode == "Penjadwalan")
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Interval Penjadwalan (berapa jam sekali):',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 300,
                                          child: DropdownButtonFormField<int>(
                                            value: intervalJam,
                                            items: List.generate(
                                              24,
                                              (index) => DropdownMenuItem(
                                                value: index + 1,
                                                child: Text('${index + 1} jam'),
                                              ),
                                            ),
                                            onChanged: (val) {
                                              setState(
                                                () => intervalJam = val ?? 2,
                                              );
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: colorMain.withOpacity(
                                                0.07,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  CustomButton(
                                    text: 'Simpan Jadwal',
                                    width: 350,
                                    onPressed: () {
                                      toastification.show(
                                        context: context,
                                        title: const Text(
                                          'Jadwal Tersimpan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        type: ToastificationType.success,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        alignment: Alignment.topCenter,
                                        autoCloseDuration: const Duration(
                                          seconds: 2,
                                        ),
                                      );
                                      if (_selectedTab == 0) {
                                        controller.updateRoomSchedule(
                                          room: controller.selectedRoom,
                                          isWater: true,
                                          scheduleType: selectedMode,
                                          intervalJam:
                                              selectedMode == "Penjadwalan"
                                              ? intervalJam
                                              : null,
                                        );
                                      } else {
                                        controller.updateRoomSchedule(
                                          room: controller.selectedRoom,
                                          isWater: false,
                                          scheduleType: selectedMode,
                                          intervalJam:
                                              selectedMode == "Penjadwalan"
                                              ? intervalJam
                                              : null,
                                        );
                                      }
                                    },
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 20,
                                    height: 60,
                                    borderRadius: 16,
                                    icon: Icons.save,
                                    iconSize: 24,
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
