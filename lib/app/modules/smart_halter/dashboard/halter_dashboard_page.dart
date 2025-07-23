import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashbboard_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_horse_card.dart';

class HalterDashboardPage extends StatefulWidget {
  const HalterDashboardPage({super.key});

  @override
  State<HalterDashboardPage> createState() => HalterDashboardPageState();
}

class HalterDashboardPageState extends State<HalterDashboardPage> {
  final controller = Get.find<HalterDashboardController>();
  int selectedTab = 0; // 0: Detail Kuda, 1: Detail Ruangan

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Dashboard',
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 320),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Text(
                              'Daftar Kuda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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
                              batteryPercent: 86,
                              cctvActive: controller.isCctvActive(room.roomId),
                              deviceActive: controller.isHalterDeviceActive(
                                room.roomId,
                              ),
                              horseName: controller.getHorseNameByRoomId(
                                room.roomId,
                              ),
                              isRoomFilled: controller.isRoomFilled(
                                room.roomId,
                              ),
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kartu Pie 1
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 2.7).clamp(
                        180,
                        260,
                      ),
                      child: _PieInfoCard(
                        pie: _PieRuangKandangChart(),
                        title: 'Ruangan Kandang A',
                        subtitle: 'Total Ruang: 6',
                        legend: [
                          _LegendItem(color: Colors.blue, label: 'Terisi : 6'),
                          _LegendItem(color: Colors.red, label: 'Kosong : 0'),
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
                        pie: _PieKudaChart(),
                        title: 'Kuda',
                        subtitle: null,
                        legend: [
                          _LegendItem(color: Colors.blue, label: 'Sehat : 5'),
                          _LegendItem(color: Colors.orange, label: 'Sakit : 1'),
                          _LegendItem(
                            color: Colors.yellow,
                            label: 'Diperiksa : 0',
                          ),
                          _LegendItem(
                            color: Colors.red,
                            label: 'Meninggal : 0',
                          ),
                        ],
                        bottomText: 'Total Kuda : 80 Ekor',
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
                        pie: _PiePerangkatIoTChart(aktif: 2, tidakAktif: 6),
                        title: 'Perangkat IoT Smart Halter',
                        subtitle: null,
                        legend: [
                          _LegendItem(color: Colors.blue, label: 'Aktif : 2'),
                          _LegendItem(
                            color: Colors.red.shade400,
                            label: 'Tidak Aktif : 6',
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
                            height: 40,
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
                                        fontSize: 16,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                        '192.168.1.1',
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
                                        'Status LoRa :',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Spacer(),
                                      Text(
                                        'Terhubung',
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
                                        'Port :',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Spacer(),
                                      Text(
                                        'COM3',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
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
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  'Detail Kandang dan Kuda',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 6,
            color: Colors.blue,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: 0,
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
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 5,
            color: Colors.blue,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: 1,
            color: Colors.orange,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: 0,
            color: Colors.yellow,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: 0,
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
  final int aktif;
  final int tidakAktif;

  const _PiePerangkatIoTChart({
    super.key,
    required this.aktif,
    required this.tidakAktif,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: aktif.toDouble(),
            color: Colors.blue,
            title: '',
            radius: 32,
          ),
          PieChartSectionData(
            value: tidakAktif.toDouble(),
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
              Row(
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
                        const Text('Id Perangkat -\nTegangan -\nRSSI -'),
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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [Text('-'), Text('-'), Text('-')],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [Text('-'), Text('-'), Text('-')],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Gambar Kuda & Status
                  Expanded(
                    flex: 3,
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
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text("Sehat"),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                height: 170,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: const Text("Biometrik Chart Placeholder"),
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1.2),
              // LEGEND BIOMETRIK
              _BiometrikLegendList(),
              const SizedBox(height: 12),
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Postur Kuda",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                          children: const [
                            Text(
                              "Berdiri Kepala Tegak",
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    color: Colors.grey[100],
                    alignment: Alignment.center,
                    child: const Text("Chart Persentase Baterai Placeholder"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// KONTEN TAB "DETAIL RUANGAN"
class _DetailRuanganView extends StatelessWidget {
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
                height: 120,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: const Text("Chart Kondisi Lingkungan Placeholder"),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1.2),

              // LEGEND LINGKUNGAN
              _LingkunganLegendList(),

              const SizedBox(height: 16),
              // Divider
              Container(height: 4, color: Colors.blue[100]),
              const SizedBox(height: 8),
              const Text(
                "Pakan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Pakan List
              _PakanBar(
                label: "Rumput",
                valueLabel: "30 kg dari 100",
                percent: 0.3,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _PakanBar(
                label: "Vitamin",
                valueLabel: "10 kg dari 40",
                percent: 0.25,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _PakanBar(
                label: "Air",
                valueLabel: "43 Liter dari 100",
                percent: 0.43,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Legend Lingkungan
class _LingkunganLegendList extends StatelessWidget {
  final List<_LingkunganLegend> items = const [
    _LingkunganLegend(color: Color(0xFF23272F), label: "Suhu (°C)", value: "0"),
    _LingkunganLegend(
      color: Color(0xFFD34B40),
      label: "Kelembapan (%)",
      value: "0",
    ),
    _LingkunganLegend(
      color: Color(0xFF6A7891),
      label: "Kualitas Udara",
      value: "0",
    ),
    _LingkunganLegend(
      color: Color(0xFF2F3E53),
      label: "Indeks Cahaya (Lux)",
      value: "0",
    ),
  ];

  const _LingkunganLegendList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}

class _LingkunganLegend {
  final Color color;
  final String label;
  final String value;
  const _LingkunganLegend({
    required this.color,
    required this.label,
    required this.value,
  });
}

// Widget Bar Pakan
class _PakanBar extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double percent; // 0.0 - 1.0
  final Color color;

  const _PakanBar({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.23 * percent,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: Text(
            valueLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _BiometrikLegendList extends StatelessWidget {
  final List<_BiometrikLegend> items = const [
    _BiometrikLegend(
      color: Color(0xFF23272F),
      label: "Detak Jantung (BPM)",
      value: "0",
    ),
    _BiometrikLegend(
      color: Color(0xFFD34B40),
      label: "Suhu Badan (°C)",
      value: "0",
    ),
    _BiometrikLegend(
      color: Color(0xFF6A7891),
      label: "Kadar Oksigen Dalam Darah (%)",
      value: "0",
    ),
    _BiometrikLegend(
      color: Color(0xFFE28B1B),
      label: "Respirasi (BPM)",
      value: "0",
    ),
  ];

  const _BiometrikLegendList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}

class _BiometrikLegend {
  final Color color;
  final String label;
  final String value;
  const _BiometrikLegend({
    required this.color,
    required this.label,
    required this.value,
  });
}
