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
        content: Obx(() {
          // Global guard untuk semua akses list/index
          if (controller.selectedRoomIndex.value < 0 ||
              controller.filteredRoomList.isEmpty ||
              feederController.roomList.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada data ruangan atau kandang tersedia',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          // Jaminan: setelah ini semua akses index aman
          // (misal: controller.filteredRoomList[controller.selectedRoomIndex.value] pasti ada)

          final selectedRoom = controller.selectedRoom;
          final room =
              feederController.roomList[controller.selectedRoomIndex.value];
          final horseId = selectedRoom.horseId;
          final horse = horseId != null && horseId.isNotEmpty
              ? controller.getHorseById(horseId)
              : null;

          return Stack(
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
                                height: 245,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                        selectedRoom.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedRoom.status == 'used'
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          selectedRoom.status == 'used'
                                              ? 'Aktif'
                                              : 'Tidak Aktif',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                                              selectedRoom,
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
                                  height: 245,
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
                                              // Tidak perlu pengecekan list lagi di sini, sudah dicek di atas
                                              Column(
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
                                                        ? '${room.remainingWater.toStringAsFixed(1)} $satuan'
                                                        : '${room.remainingFeed.toStringAsFixed(1)} $satuan',
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
                                                        ? '${(controller.maxWater - room.remainingWater).clamp(0, controller.maxWater).toStringAsFixed(1)} $satuan'
                                                        : '${(controller.maxFeed - room.remainingFeed).clamp(0, controller.maxFeed).toStringAsFixed(1)} $satuan',
                                                    style: TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colorMain,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 20),
                                              if (horse == null)
                                                Text(
                                                  'Tidak ada kuda di kandang ini',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              else
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
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: horse.name,
                                                            style: TextStyle(
                                                              color: colorMain,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 30,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                ' (${horse.horseId})',
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .black54,
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
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                '${horse.age} tahun',
                                                            style: TextStyle(
                                                              color: colorMain,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                horse.type ==
                                                                    "local"
                                                                ? "Lokal"
                                                                : "Crossbred",
                                                            style: TextStyle(
                                                              color: colorMain,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 30,
                                                            ),
                                                          ),
                                                          const TextSpan(
                                                            text:
                                                                '  |  Kelamin: ',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                horse.gender ==
                                                                    "male"
                                                                ? "Jantan"
                                                                : "Betina",
                                                            style: TextStyle(
                                                              color: colorMain,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: controller
                                                                .getHorseHealthStatusById(
                                                                  horse.horseId,
                                                                ),
                                                            style: TextStyle(
                                                              color:
                                                                  controller.getHorseHealthStatusById(
                                                                        horse
                                                                            .horseId,
                                                                      ) ==
                                                                      "Sehat"
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                          () => selectedMode =
                                              val ?? "Penjadwalan",
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: colorMain.withOpacity(
                                            0.07,
                                          ),
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
                                                  child: Text(
                                                    '${index + 1} jam',
                                                  ),
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
                                                fillColor: colorMain
                                                    .withOpacity(0.07),
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
                                        final modeValue = selectedMode
                                            .toLowerCase(); // <-- pastikan lowercase
                                        if (_selectedTab == 0) {
                                          controller.updateRoomScheduleFlexible(
                                            selectedRoom,
                                            isWater: true,
                                            scheduleType: modeValue,
                                            intervalJam:
                                                modeValue == "penjadwalan"
                                                ? intervalJam
                                                : null,
                                          );
                                          print(modeValue);
                                        } else {
                                          controller.updateRoomScheduleFlexible(
                                            selectedRoom,
                                            isWater: false,
                                            scheduleType: modeValue,
                                            intervalJam:
                                                modeValue == "penjadwalan"
                                                ? intervalJam
                                                : null,
                                          );
                                          print(modeValue);
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
          );
        }),
      ),
    );
  }
}
