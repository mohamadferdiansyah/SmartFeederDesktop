import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_battery_indicator.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_biometric_chart.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_biometric_legend.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_halter_log_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_horse_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_lingkungan_chart.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_lingkungan_legend.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_movement_chart%20.dart';

class HalterDashboardPage extends StatefulWidget {
  const HalterDashboardPage({super.key});

  @override
  State<HalterDashboardPage> createState() => HalterDashboardPageState();
}

class HalterDashboardPageState extends State<HalterDashboardPage> {
  final HalterDashboardController controller = Get.find();
  final HalterSettingController settingController = Get.find();

  int selectedTab = 0; // 0: Detail Kuda, 1: Detail Ruangan

  // @override
  // void initState() {
  //   super.initState();
  //   Get.find<HalterSerialService>().startDummyData();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Dashboard',
        withExpanded: false,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 335),
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Text(
                              'Daftar Kuda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Obx(
                              () => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: controller.filteredRoomList.length,
                        itemBuilder: (context, index) {
                          final room = controller.filteredRoomList[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CustomHorseCard(
                              batteryPercent: controller
                                  .getBatteryPercentByRoomId(room.roomId),
                              cctvActive: controller.isCctvActive(room.roomId),
                              deviceActive: controller.isHalterDeviceActive(
                                room.horseId ?? '',
                              ),
                              horseName: controller.getHorseNameByRoomId(
                                room.roomId,
                              ),
                              horseId: room.horseId ?? '-',
                              horseRoom: room.roomId,
                              isRoomFilled: controller.isRoomFilled(
                                room.roomId,
                              ),
                              onSelectHorse: () {
                                controller.selectedRoomIndex.value = index;
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kartu Pie 1
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2.7).clamp(
                          180,
                          260,
                        ),
                        child: _PieInfoCard(
                          pie: _PieRuangKandangChart(
                            filledCount: controller.getFilledRoomCount(),
                            emptyCount: controller.getEmptyRoomCount(),
                          ),
                          title: controller.getStableNameById(
                            controller.selectedStableId.value,
                          ),
                          subtitle:
                              'Total Ruang: ${controller.filteredRoomList.length}',
                          legend: [
                            _LegendItem(
                              color: Colors.blue,
                              label:
                                  'Terisi : ${controller.getFilledRoomCount()}',
                            ),
                            _LegendItem(
                              color: Colors.red,
                              label:
                                  'Kosong : ${controller.getEmptyRoomCount()}',
                            ),
                          ],
                          bottomText: 'Sumber Data dari Cloud',
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2.7).clamp(
                          180,
                          260,
                        ),
                        child: _PieInfoCard(
                          pie: _PieKudaChart(
                            healthyCount: controller.getHealthyHorseCount(),
                            sickCount: controller.getSickHorseCount(),
                            checkedCount: 0,
                            deadCount: 0,
                          ),
                          title: 'Data Kuda',
                          subtitle: null,
                          legend: [
                            _LegendItem(
                              color: Colors.blue,
                              label:
                                  'Sehat : ${controller.getHealthyHorseCount()}',
                            ),
                            _LegendItem(
                              color: Colors.orange,
                              label:
                                  'Sakit : ${controller.getSickHorseCount()}',
                            ),
                            _LegendItem(
                              color: Colors.yellow,
                              label: 'Diperiksa : 0',
                            ),
                            _LegendItem(
                              color: Colors.red,
                              label: 'Meninggal : 0',
                            ),
                          ],
                          bottomText:
                              'Total Kuda : ${controller.getFilledRoomCount()} Ekor',
                          bottomBold: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2.7).clamp(
                          120,
                          260,
                        ),
                        child: _PieInfoCard(
                          pie: _PiePerangkatIoTChart(
                            on: controller.getDeviceOnCount(),
                            off: controller.getDeviceOffCount(),
                          ),
                          title: 'Perangkat IoT Smart Halter',
                          subtitle: null,
                          legend: [
                            _LegendItem(
                              color: Colors.blue,
                              label: 'Aktif : ${controller.getDeviceOnCount()}',
                            ),
                            _LegendItem(
                              color: Colors.red.shade400,
                              label:
                                  'Tidak Aktif : ${controller.getDeviceOffCount()}',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        constraints: BoxConstraints(maxWidth: 320),
                        height: 190,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Status Koneksi Ke Cloud & LoRa',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Obx(() {
                                  final setting =
                                      settingController.setting.value;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'IP Server :',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Spacer(),
                                          Text(
                                            setting.cloudUrl.replaceAll(
                                              RegExp(r'https?://'),
                                              '',
                                            ),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Status :',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Spacer(),
                                          Text(
                                            setting.loraPort != ''
                                                ? "Terhubung"
                                                : "Tidak Terhubung",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: setting.loraPort != ''
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Port :',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Spacer(),
                                          Text(
                                            setting.loraPort != ''
                                                ? setting.loraPort
                                                : 'Tidak Terhubung',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.423,
                      height: MediaQuery.of(context).size.height * 0.66,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Informasi Detail Kuda',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Obx(() {
                                      // Cek jika filteredRoomList kosong
                                      if (controller.filteredRoomList.isEmpty) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
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

                                      // Jika tidak kosong, tampilkan nama kuda
                                      final horseName = controller
                                          .getHorseNameByRoomId(
                                            controller.selectedRoom.roomId,
                                          );
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          horseName.isNotEmpty
                                              ? horseName
                                              : '-',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Tab Button
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        setState(() => selectedTab = 0),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedTab == 0
                                          ? AppColors.primary
                                          : Colors.grey[200],
                                      foregroundColor: selectedTab == 0
                                          ? Colors.white
                                          : Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Detail Kuda',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        setState(() => selectedTab = 1),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedTab == 1
                                          ? AppColors.primary
                                          : Colors.grey[200],
                                      foregroundColor: selectedTab == 1
                                          ? Colors.white
                                          : Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Detail Ruangan',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(height: 1, color: Colors.grey[200]),

                          // Content Area (scrollable)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8,
                              ),
                              child: selectedTab == 0
                                  ? _DetailKudaView()
                                  : _DetailRuanganView(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.166,
                      height: MediaQuery.of(context).size.height * 0.66,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Log Kondisi Kuda & Ruangan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16.0,
                                top: 8,
                              ),
                              child: Obx(() {
                                // Cek jika tidak ada ruangan sama sekali
                                if (controller.filteredRoomList.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Tidak ada log untuk kuda ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                final horseId = controller.selectedRoom.horseId;
                                if (horseId == null || horseId.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Tidak ada log untuk kuda ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                final selectedHorse = controller
                                    .halterDeviceList
                                    .firstWhereOrNull(
                                      (d) => d.horseId == horseId,
                                    );
                                final nodeRoomDeviceId =
                                    controller.selectedRoom.deviceSerial;

                                if (selectedHorse == null) {
                                  return Center(
                                    child: Text(
                                      'Tidak ada log untuk kuda ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                final selectedLog = controller
                                    .halterHorseLogList
                                    .where(
                                      (log) =>
                                          log.deviceId ==
                                              selectedHorse.deviceId ||
                                          log.deviceId == nodeRoomDeviceId,
                                    )
                                    .toList();

                                if (selectedLog.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'Tidak ada log untuk kuda ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: selectedLog.length,
                                  itemBuilder: (context, index) {
                                    final log = selectedLog[index];
                                    return CustomHalterLogCard(
                                      horseName: log.deviceId,
                                      roomName: 'ruangan 1',
                                      type: log.type,
                                      logMessage: log.message,
                                      time: log.time ?? DateTime.now(),
                                      isHigh: log.isHigh,
                                    );
                                  },
                                );
                              }),
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
    );
  }
}

// Widget Card
class _PieInfoCard extends StatelessWidget {
  final Widget pie;
  final String title;
  final String? subtitle;
  final List<_LegendItem> legend;
  final String bottomText;
  final bool bottomBold;

  const _PieInfoCard({
    required this.pie,
    required this.title,
    required this.legend,
    this.bottomText = '',
    this.subtitle,
    this.bottomBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      alignment: Alignment.center,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pie & Legend
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 80, height: 80, child: pie),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0, top: 1),
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ...legend.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      width: 0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.label,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 12, thickness: 0.7),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Text(
                  bottomText,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: bottomBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pie chart Ruangan Kandang
class _PieRuangKandangChart extends StatelessWidget {
  final int filledCount;
  final int emptyCount;

  const _PieRuangKandangChart({
    required this.filledCount,
    required this.emptyCount,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: filledCount.toDouble(),
            color: Colors.blue,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: emptyCount.toDouble(),
            color: Colors.red,
            title: '',
            radius: 32,
          ),
        ],
        startDegreeOffset: -90,
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }
}

// Pie chart Kuda
class _PieKudaChart extends StatelessWidget {
  final int healthyCount;
  final int sickCount;
  final int checkedCount;
  final int deadCount;

  const _PieKudaChart({
    required this.healthyCount,
    required this.sickCount,
    required this.checkedCount,
    required this.deadCount,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: healthyCount.toDouble(),
            color: Colors.blue,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: sickCount.toDouble(),
            color: Colors.orange,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: checkedCount.toDouble(),
            color: Colors.yellow,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: deadCount.toDouble(),
            color: Colors.red,
            title: '',
            radius: 32,
          ),
        ],
        startDegreeOffset: -90,
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }
}

// Pie chart khusus perangkat IoT (tanpa judul/legend, hanya chart)
class _PiePerangkatIoTChart extends StatelessWidget {
  final int on;
  final int off;

  const _PiePerangkatIoTChart({required this.on, required this.off});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: on.toDouble(),
            color: Colors.blue,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: off.toDouble(),
            color: Colors.red.shade400,
            title: '',
            radius: 32,
          ),
        ],
        startDegreeOffset: -90,
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }
}

// Legend item helper
class _LegendItem {
  final Color color;
  final String label;
  _LegendItem({required this.color, required this.label});
}

class _DetailKudaView extends StatelessWidget {
  final HalterDashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // IoT Info dan Gambar Kuda
              Obx(() {
                // final detail = controller.serialService.latestDetail.value;

                if (controller.filteredRoomList.isEmpty ||
                    controller.selectedRoom.horseId == null ||
                    controller.selectedRoom.horseId!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data kuda',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final detail = controller.getSelectedHorseDetail();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IoT Info
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'IoT Node Smart Halter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text('Id Perangkat'),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller
                                            .getHalterDeviceByHorseId(
                                              controller.selectedRoom.horseId ??
                                                  '',
                                            )
                                            ?.deviceId ??
                                        '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Tegangan'),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${detail?.voltage ?? 0} mV',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('RSSI'),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${detail?.respiratoryRate ?? 0} dBm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Profil',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Profil List
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text('ID Kuda:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            controller.selectedRoom.horseId ??
                                                '-',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Jenis Kuda:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            controller
                                                        .getHorseById(
                                                          controller
                                                                  .selectedRoom
                                                                  .horseId ??
                                                              '',
                                                        )
                                                        .type ==
                                                    'local'
                                                ? 'Lokal'
                                                : 'Crossbreed',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Umur:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${controller.getHorseById(controller.selectedRoom.horseId ?? '').age} tahun',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Gender:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            controller
                                                        .getHorseById(
                                                          controller
                                                                  .selectedRoom
                                                                  .horseId ??
                                                              '',
                                                        )
                                                        .gender ==
                                                    'male'
                                                ? 'Jantan'
                                                : 'Betina',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text('Tanggal Menetap:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            'NaN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Kesehatan:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            controller.getHorseHealthStatusById(
                                              controller.selectedRoom.horseId ??
                                                  '',
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Posisi:'),
                                          const SizedBox(width: 8),
                                          Text(
                                            controller.getHorseHeadPosture(
                                              detail?.roll ?? 0,
                                              detail?.pitch ?? 0,
                                              detail?.yaw ?? 0,
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
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
                        ],
                      ),
                    ),
                    // Gambar Kuda & Status
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: Image.asset(
                              'assets/images/horse.png', // ganti path sesuai assetmu
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Status Kesehatan Kuda'),
                              const SizedBox(width: 8),
                              Obx(
                                () => ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        controller.getHorseHealthStatusById(
                                              controller.selectedRoom.horseId ??
                                                  '',
                                            ) ==
                                            'Sehat'
                                        ? Colors.green
                                        : Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    controller.getHorseHealthStatusById(
                                      controller.selectedRoom.horseId ?? '',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              // Divider
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              const Text(
                "Biometriks",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Dummy biometrik chart
              Container(
                height: 400,
                width: double.infinity,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: Obx(() {
                  if (controller.filteredRoomList.isEmpty ||
                      controller.selectedRoom.horseId == null ||
                      controller.selectedRoom.horseId!.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada data kuda',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  final data = controller.getSelectedHorseDetailHistory();
                  const maxData = 5;

                  // Ambil hanya 10 data terakhir
                  final displayData = data.length > maxData
                      ? data.sublist(data.length - maxData)
                      : data;

                  // if (displayData.isEmpty) {
                  //   return Center(
                  //     child: Text(
                  //       'Belum ada data biometrik',
                  //       style: TextStyle(color: Colors.grey),
                  //     ),
                  //   );
                  // }

                  List<FlSpot> bpmSpots = [];
                  List<FlSpot> suhuSpots = [];
                  List<FlSpot> spoSpots = [];
                  List<FlSpot> respirasiSpots = [];
                  List<String> timeLabels = [];

                  for (int i = 0; i < displayData.length; i++) {
                    final d = displayData[i];
                    bpmSpots.add(
                      FlSpot(i.toDouble(), (d.heartRate ?? 0).toDouble()),
                    );
                    suhuSpots.add(FlSpot(i.toDouble(), (d.temperature ?? 0)));
                    spoSpots.add(FlSpot(i.toDouble(), (d.spo ?? 0)));
                    respirasiSpots.add(
                      FlSpot(i.toDouble(), (d.respiratoryRate ?? 0)),
                    );

                    final timeStr = d.time
                        .toIso8601String()
                        .split('T')[1]
                        .split('.')[0];
                    timeLabels.add(timeStr);
                  }

                  return BiometricChartTabSection(
                    bpmSpots: bpmSpots,
                    suhuSpots: suhuSpots,
                    spoSpots: spoSpots,
                    respirasiSpots: respirasiSpots,
                    timeLabels: timeLabels,
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1.2),
              Obx(() {
                if (controller.filteredRoomList.isEmpty ||
                    controller.selectedRoom.horseId == null ||
                    controller.selectedRoom.horseId!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data kuda',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final detail = controller.getSelectedHorseDetail();
                return CustomBiometricLegend(
                  items: [
                    BiometrikLegendItem(
                      color: Color(0xFF23272F),
                      label: "Detak Jantung (BPM)",
                      value: detail?.heartRate?.toString() ?? "-",
                    ),
                    BiometrikLegendItem(
                      color: Color(0xFFD34B40),
                      label: "Suhu Badan (°C)",
                      value: detail?.temperature?.toString() ?? "-",
                    ),
                    BiometrikLegendItem(
                      color: Color(0xFF6A7891),
                      label: "Kadar Oksigen Dalam Darah (%)",
                      value: detail?.spo?.toString() ?? "-",
                    ),
                    BiometrikLegendItem(
                      color: Color(0xFFE28B1B),
                      label: "Respirasi (BPM)",
                      value: detail?.respiratoryRate?.toString() ?? "-",
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              const Text(
                "Pergerakan Kuda",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                height: 250,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: CustomMovementChart(),
              ),
              const SizedBox(height: 12),
              Divider(thickness: 1.2),
              Obx(() {
                if (controller.filteredRoomList.isEmpty ||
                    controller.selectedRoom.horseId == null ||
                    controller.selectedRoom.horseId!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data kuda',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final detail = controller.getSelectedHorseDetail();

                return CustomBiometricLegend(
                  items: [
                    BiometrikLegendItem(
                      color: Colors.red,
                      label: "Roll",
                      value: (detail?.roll?.toString() ?? "-"),
                    ),
                    BiometrikLegendItem(
                      color: Colors.green,
                      label: "Pitch",
                      value: (detail?.pitch?.toString() ?? "-"),
                    ),
                    BiometrikLegendItem(
                      color: Colors.blue,
                      label: "Yaw",
                      value: (detail?.yaw?.toString() ?? "-"),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.filteredRoomList.isEmpty ||
                    controller.selectedRoom.horseId == null ||
                    controller.selectedRoom.horseId!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data kuda',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                final detail = controller.getSelectedHorseDetail();
                final posture = detail == null
                    ? "Tidak ada data"
                    : controller.getHorseHeadPosture(
                        detail.roll ?? 0,
                        detail.pitch ?? 0,
                        detail.yaw ?? 0,
                      );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Postur Kuda",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Keterangan Postur
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Postur Kepala Kuda: $posture",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Akurasi : 98%",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        // Gambar kuda
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(right: 24.0),
                            child: Image(
                              image: AssetImage('assets/images/horse.png'),
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(height: 4, color: Colors.blue[100]),
                    const SizedBox(height: 8),
                    const Text(
                      "Persentase Baterai IoT Halter",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      color: Colors.grey[100],
                      alignment: Alignment.center,
                      child: CustomBatteryIndicator(
                        iconSize: 100,
                        percent:
                            controller.getSelectedHorseBatteryPercent() ?? 0,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// KONTEN TAB "DETAIL RUANGAN"
class _DetailRuanganView extends StatelessWidget {
  final HalterDashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Data Aktual Kandang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Preview CCTV
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.videocam, size: 90, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: "Not Connected",
                          items: const [
                            DropdownMenuItem(
                              value: "Not Connected",
                              child: Text("Not Connected"),
                            ),
                            DropdownMenuItem(
                              value: "Connected",
                              child: Text("Connected"),
                            ),
                          ],
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.videocam, size: 90, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: "Not Connected",
                          items: const [
                            DropdownMenuItem(
                              value: "Not Connected",
                              child: Text("Not Connected"),
                            ),
                            DropdownMenuItem(
                              value: "Connected",
                              child: Text("Connected"),
                            ),
                          ],
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Ruangan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  // Profil List
                  Obx(() {
                    if (controller.filteredRoomList.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada data ruangan',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    final room = controller.selectedRoom;

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('ID Ruangan:'),
                                  const SizedBox(width: 8),
                                  Text(
                                    room.roomId,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('No Serial Node:'),
                                  const SizedBox(width: 8),
                                  Text(
                                    room.deviceSerial ?? 'Tidak ada',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Nama Ruangan:'),
                                  const SizedBox(width: 8),
                                  Text(
                                    room.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Di Kandang:'),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller
                                        .getSelectedStableById(room.stableId)
                                        .name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              const Text(
                "Kondisi Lingkungan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Dummy lingkungan chart
              Container(
                height: 400,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: Obx(() {
                  if (controller.filteredRoomList.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada data ruangan',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  final data = controller.getSelectedNodeRoomHistory();
                  const maxData = 5;

                  final displayData = data.length > maxData
                      ? data.sublist(data.length - maxData)
                      : data;

                  List<FlSpot> suhuSpots = [];
                  List<FlSpot> kelembapanSpots = [];
                  List<FlSpot> cahayaSpots = [];
                  List<String> timeLabels = [];

                  for (int i = 0; i < displayData.length; i++) {
                    final d = displayData[i];
                    suhuSpots.add(FlSpot(i.toDouble(), d.temperature));
                    kelembapanSpots.add(FlSpot(i.toDouble(), d.humidity));
                    cahayaSpots.add(FlSpot(i.toDouble(), d.lightIntensity));
                    final timeStr = d.time != null
                        ? d.time!.toIso8601String().split('T')[1].split('.')[0]
                        : '-';
                    timeLabels.add(timeStr);
                  }

                  return LingkunganChartTabSection(
                    suhuSpots: suhuSpots,
                    kelembapanSpots: kelembapanSpots,
                    cahayaSpots: cahayaSpots,
                    timeLabels: timeLabels,
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1.2),

              // LEGEND LINGKUNGAN
              Obx(() {
                if (controller.filteredRoomList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data ruangan',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final nodeRoom = controller.getSelectedNodeRoom(
                  controller.selectedRoom.deviceSerial ?? '',
                );
                return CustomLingkunganLegend(
                  items: [
                    LingkunganLegendItem(
                      color: Color(0xFF23272F),
                      label: "Suhu (°C)",
                      value: nodeRoom?.temperature.toStringAsFixed(1) ?? "-",
                    ),
                    LingkunganLegendItem(
                      color: Color(0xFFD34B40),
                      label: "Kelembapan (%)",
                      value: nodeRoom?.humidity.toStringAsFixed(1) ?? "-",
                    ),
                    LingkunganLegendItem(
                      color: Color(0xFF2F3E53),
                      label: "Indeks Cahaya (Lux)",
                      value: nodeRoom?.lightIntensity.toStringAsFixed(1) ?? "-",
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class BiometricChartTabSection extends StatefulWidget {
  final List<FlSpot> bpmSpots;
  final List<FlSpot> suhuSpots;
  final List<FlSpot> spoSpots;
  final List<FlSpot> respirasiSpots;
  final List<String> timeLabels;

  const BiometricChartTabSection({
    super.key,
    required this.bpmSpots,
    required this.suhuSpots,
    required this.spoSpots,
    required this.respirasiSpots,
    required this.timeLabels,
  });

  @override
  State<BiometricChartTabSection> createState() =>
      _BiometricChartTabSectionState();
}

class _BiometricChartTabSectionState extends State<BiometricChartTabSection> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabList = [
      (
        "Detak Jantung",
        widget.bpmSpots,
        "Detak Jantung (BPM)",
        "Waktu",
        Colors.black,
      ),
      ("Suhu Badan", widget.suhuSpots, "Suhu Badan (°C)", "Waktu", Colors.red),
      (
        "Kadar Oksigen Dalam Darah",
        widget.spoSpots,
        "Kadar Oksigen (%)",
        "Waktu",
        Colors.blue,
      ),
      (
        "Respirasi",
        widget.respirasiSpots,
        "Respirasi (BPM)",
        "Waktu",
        Colors.orange,
      ),
    ];

    final currentTab = tabList[selectedIndex];

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: CustomBiometricChart(
            spots: currentTab.$2, // List<FlSpot>
            timeLabels: widget.timeLabels,
            titleY: currentTab.$3, // String
            titleX: currentTab.$4, // String
            lineColor: currentTab.$5, // Color
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(tabList.length, (i) {
            final isSelected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? tabList[i].$5
                      : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                ),
                onPressed: () => setState(() => selectedIndex = i),
                child: Text(tabList[i].$1),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class LingkunganChartTabSection extends StatefulWidget {
  final List<FlSpot> suhuSpots;
  final List<FlSpot> kelembapanSpots;
  final List<FlSpot> cahayaSpots;
  final List<String> timeLabels;

  const LingkunganChartTabSection({
    super.key,
    required this.suhuSpots,
    required this.kelembapanSpots,
    required this.cahayaSpots,
    required this.timeLabels,
  });

  @override
  State<LingkunganChartTabSection> createState() =>
      _LingkunganChartTabSectionState();
}

class _LingkunganChartTabSectionState extends State<LingkunganChartTabSection> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabList = [
      ("Suhu", widget.suhuSpots, "Suhu (°C)", "Waktu", const Color(0xFF23272F)),
      (
        "Kelembapan",
        widget.kelembapanSpots,
        "Kelembapan (%)",
        "Waktu",
        const Color(0xFFD34B40),
      ),
      (
        "Cahaya",
        widget.cahayaSpots,
        "Indeks Cahaya (Lux)",
        "Waktu",
        const Color(0xFF2F3E53),
      ),
    ];

    final currentTab = tabList[selectedIndex];

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: CustomLingkunganChart(
            spots: currentTab.$2,
            timeLabels: widget.timeLabels,
            titleY: currentTab.$3,
            titleX: currentTab.$4,
            lineColor: currentTab.$5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(tabList.length, (i) {
            final isSelected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? tabList[i].$5
                      : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                ),
                onPressed: () => setState(() => selectedIndex = i),
                child: Text(tabList[i].$1),
              ),
            );
          }),
        ),
      ],
    );
  }
}
