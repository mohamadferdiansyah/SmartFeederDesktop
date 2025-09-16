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

  @override
  void initState() {
    super.initState();
    controller.selectedRoomIndex.value = widget.roomSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        withExpanded: false,
        scrollable: false,
        title: 'Kontrol Penjadwalan',
        content: Obx(() {
          if (controller.selectedRoomIndex.value < 0 ||
              controller.filteredRoomList.isEmpty ||
              feederController.roomList.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada data ruangan atau kandang tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final selectedRoom = controller.selectedRoom;
          final room =
              feederController.roomList[controller.selectedRoomIndex.value];
          final horseId = selectedRoom?.horseId;
          final horse = horseId != null && horseId.isNotEmpty
              ? controller.getHorseById(horseId)
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih Ruangan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Dropdown Pilih Ruangan
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Obx(
                  () => DropdownButtonFormField<RoomModel>(
                    value: selectedRoom,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: const Text("Pilih Ruangan"),
                    items: controller.filteredRoomList
                        .map(
                          (room) => DropdownMenuItem<RoomModel>(
                            value: room,
                            child: Text(
                              room.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final idx = controller.filteredRoomList.indexWhere(
                          (r) => r.roomId == val.roomId,
                        );
                        if (idx != -1) {
                          controller.selectedRoomIndex.value = idx;
                        }
                      }
                    },
                  ),
                ),
              ),
              // Tab Kontrol
              DefaultTabController(
                length: 2,
                initialIndex: controller.selectedTab.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: "Air", icon: Icon(Icons.water_drop_rounded)),
                        Tab(text: "Pakan", icon: Icon(Icons.rice_bowl_rounded)),
                      ],
                      onTap: (i) =>
                          setState(() => controller.selectedTab.value = i),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.68,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildScheduleTab(
                            context,
                            isAir: true,
                            room: room,
                            horse: horse,
                          ),
                          _buildScheduleTab(
                            context,
                            isAir: false,
                            room: room,
                            horse: horse,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScheduleTab(
    BuildContext context, {
    required bool isAir,
    required RoomModel room,
    required dynamic horse,
  }) {
    final colorMain = isAir ? Colors.blue : Colors.deepOrange;
    final satuan = isAir ? "Liter" : "Gram";
    final maxValue = isAir ? controller.maxWater : controller.maxFeed;
    final remainingValue = isAir ? room.remainingWater : room.remainingFeed;
    final kebutuhanIsi = (maxValue - remainingValue).clamp(0, maxValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: CustomCard(
        title: 'Status & Penjadwalan ${isAir ? "Air" : "Pakan"}',
        headerColor: AppColors.primary,
        headerHeight: 56,
        borderRadius: 16,
        titleFontSize: 22,
        scrollable: false,
        withExpanded: false,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Cards Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Info Card
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorMain.withOpacity(0.1),
                        border: Border.all(color: colorMain, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with icon and title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorMain.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.house_siding_rounded,
                                  color: colorMain,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Ruangan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Room name and status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  room.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: room.status == 'used'
                                      ? Colors.green.withOpacity(0.9)
                                      : Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (room.status == 'used'
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  room.status == 'used'
                                      ? 'Aktif'
                                      : 'Tidak Aktif',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, thickness: 0.5),
                          const SizedBox(height: 16),

                          // Last feed info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Terakhir diberi",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        controller.getLastFeedText(room),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Resource info cards
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorMain,
                                      width: 1,
                                    ),
                                    color: colorMain.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isAir
                                                ? Icons.water_drop_rounded
                                                : Icons.rice_bowl_rounded,
                                            color: colorMain,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tersedia',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: colorMain.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${remainingValue.toStringAsFixed(1)} $satuan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorMain,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorMain,
                                      width: 1,
                                    ),
                                    color: colorMain.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                            size: 18,
                                            color: colorMain,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Kebutuhan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: colorMain.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${kebutuhanIsi.toStringAsFixed(1)} $satuan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorMain,
                                          fontSize: 16,
                                        ),
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
                  ),
                ),

                const SizedBox(width: 16),

                // Horse Info Card
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorMain.withOpacity(0.1),
                        border: Border.all(color: colorMain, width: 1),
                      ),
                      child: horse == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.pets_rounded,
                                    color: Colors.red.withOpacity(0.7),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tidak ada kuda\ndi kandang ini',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with icon and title
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorMain.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.pets_rounded,
                                        color: colorMain,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Kuda",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Horse name and ID
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorMain,
                                      width: 1,
                                    ),
                                    color: colorMain.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              horse.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: colorMain,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'ID: ${horse.horseId}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Horse details grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.cake_rounded,
                                        label: 'Umur',
                                        value: '${horse.age} tahun',
                                        color: colorMain,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: horse.gender == "male"
                                            ? Icons.male_rounded
                                            : Icons.female_rounded,
                                        label: 'Kelamin',
                                        value: horse.gender == "male"
                                            ? "Jantan"
                                            : "Betina",
                                        color: colorMain,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.category_rounded,
                                        label: 'Jenis',
                                        value: horse.type == "local"
                                            ? "Lokal"
                                            : "Crossbred",
                                        color: colorMain,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildInfoCard(
                                        icon: Icons.category_rounded,
                                        label: 'Kategori',
                                        value: horse.category,
                                        color: colorMain,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Scheduling Card
            Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 1),
                  color: Colors.green.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            color: Colors.green[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Penjadwalan ${isAir ? "Air" : "Pakan"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode Selection
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Operasi:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Obx(
                                  () => DropdownButtonFormField<String>(
                                    value: controller.selectedMode.value,
                                    items: [
                                      DropdownMenuItem(
                                        value: "Penjadwalan",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 18,
                                              color: Colors.green[600],
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("Penjadwalan"),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "Otomatis",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.auto_mode,
                                              size: 18,
                                              color: Colors.blue[600],
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("Otomatis"),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "Manual",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              size: 18,
                                              color: Colors.orange[600],
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("Manual"),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: controller.setSelectedMode,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                              Obx(
                                () =>
                                    controller.selectedMode.value ==
                                        "Penjadwalan"
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          Text(
                                            'Interval Waktu:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Obx(
                                              () => DropdownButtonFormField<int>(
                                                value: controller
                                                    .intervalJam
                                                    .value,
                                                items: List.generate(
                                                  24,
                                                  (index) => DropdownMenuItem(
                                                    value: index + 1,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.timer,
                                                          size: 18,
                                                          color:
                                                              Colors.green[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          '${index + 1} jam',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                onChanged:
                                                    controller.setIntervalJam,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 28),

                        // Save Button
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 28,
                              ), // Add margin if needed, or remove this line
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green[600]!,
                                    Colors.green[700]!,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CustomButton(
                                text: 'Simpan Jadwal',
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
                                  final modeValue = controller
                                      .selectedMode
                                      .value
                                      .toLowerCase();
                                  controller.updateRoomScheduleFlexible(
                                    room,
                                    isWater: isAir,
                                    scheduleType: modeValue,
                                    intervalJam: modeValue == "penjadwalan"
                                        ? controller.intervalJam.value
                                        : null,
                                  );
                                },
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16,
                                height: 56,
                                borderRadius: 16,
                                icon: Icons.save_rounded,
                                iconSize: 20,
                              ),
                            ),
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
      ),
    );
  }

  // Helper method for small info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
