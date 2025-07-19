import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/dashboard/dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/layout/layout_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_history_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_feed_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_stable_water_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dummy data list kandang
  final List<Map<String, dynamic>> stableList = [
    {
      'stableName': 'Kandang 1',
      'imageAsset': 'assets/images/stable.jpg',
      'scheduleText': 'Penjadwalan', // Bisa: Penjadwalan, Otomatis, Manual
      'isActive': true,
      'remainingWater': 4.2, // dari 5 Liter
      'remainingFeed': 38.0, // dari 50 Gram
      'lastFeedText': '2 jam yang lalu',
    },
    {
      'stableName': 'Kandang 2',
      'imageAsset': 'assets/images/stable.jpg',
      'scheduleText': 'Otomatis',
      'isActive': false,
      'remainingWater': 1.5,
      'remainingFeed': 12.0,
      'lastFeedText': '1 jam yang lalu',
    },
    {
      'stableName': 'Kandang 3',
      'imageAsset': 'assets/images/stable.jpg',
      'scheduleText': 'Manual',
      'isActive': true,
      'remainingWater': 0.8,
      'remainingFeed': 5.5,
      'lastFeedText': '30 menit yang lalu',
    },
    {
      'stableName': 'Kandang 4',
      'imageAsset': 'assets/images/stable.jpg',
      'scheduleText': 'Otomatis',
      'isActive': true,
      'remainingWater': 5.0,
      'remainingFeed': 49.0,
      'lastFeedText': '10 menit yang lalu',
    },
    {
      'stableName': 'Kandang 5',
      'imageAsset': 'assets/images/stable.jpg',
      'scheduleText': 'Manual',
      'isActive': false,
      'remainingWater': 0.2,
      'remainingFeed': 0.0,
      'lastFeedText': '3 jam yang lalu',
    },
    // Tambah data dummy lain jika perlu
  ];

  final List<Map<String, dynamic>> historyList = [
    {
      'datetime': DateTime(2025, 7, 18, 08, 30),
      'water': 4.2,
      'feed': 38.0,
      'scheduleText': 'Penjadwalan',
    },
    {
      'datetime': DateTime(2025, 7, 18, 12, 15),
      'water': 2.5,
      'feed': 21.0,
      'scheduleText': 'Otomatis',
    },
    {
      'datetime': DateTime(2025, 7, 18, 16, 45),
      'water': 0.8,
      'feed': 5.5,
      'scheduleText': 'Manual',
    },
    {
      'datetime': DateTime(2025, 7, 18, 20, 10),
      'water': 5.0,
      'feed': 49.0,
      'scheduleText': 'Otomatis',
    },
    {
      'datetime': DateTime(2025, 7, 17, 09, 20),
      'water': 3.7,
      'feed': 30.0,
      'scheduleText': 'Penjadwalan',
    },
    {
      'datetime': DateTime(2025, 7, 17, 13, 00),
      'water': 1.2,
      'feed': 10.0,
      'scheduleText': 'Manual',
    },
    {
      'datetime': DateTime(2025, 7, 17, 18, 10),
      'water': 4.9,
      'feed': 44.0,
      'scheduleText': 'Penjadwalan',
    },
    {
      'datetime': DateTime(2025, 7, 17, 22, 45),
      'water': 0.5,
      'feed': 3.0,
      'scheduleText': 'Manual',
    },
    {
      'datetime': DateTime(2025, 7, 16, 07, 55),
      'water': 2.0,
      'feed': 18.0,
      'scheduleText': 'Otomatis',
    },
    {
      'datetime': DateTime(2025, 7, 16, 15, 30),
      'water': 5.0,
      'feed': 50.0,
      'scheduleText': 'Penjadwalan',
    },
  ];

  final DashboardController controller = Get.find();
  final LayoutController layoutController = Get.find();

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secs';
  }

  Future<void> showFillDialog({
    required BuildContext context,
    required String stableName,
    required double mainTankWater,
    required double mainTankFeed,
    required Function(double water, double feed) onSubmit,
  }) async {
    final TextEditingController waterController = TextEditingController();
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
              color: Colors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal, width: 1),
            ),
            child: Center(
              child: Text(
                'Isi Pakan & Air',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
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
                      'Kandang:',
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
                const SizedBox(height: 12),
                // Input air
                CustomInput(
                  label: 'Jumlah Air yang akan diisi (liter)',
                  fontSize: 18,
                  controller: waterController,
                  hint: 'Masukkan jumlah air',
                  icon: Icons.water_drop,
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
                      '$mainTankWater Liter',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 20,
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
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/fill_tank.png',
                            width: 200,
                            height: 200,
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
                              SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: 'Sisa Air: '),
                                    TextSpan(
                                      text: '512.3L',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: 'Ph Level: '),
                                    TextSpan(
                                      text: '7.2',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
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
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepOrange),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/fill_tank.png',
                            width: 200,
                            height: 200,
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
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: 'Sisa Pakan: '),
                                    TextSpan(
                                      text: '150.5Kg',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
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
                  trailing: const Icon(Icons.more_horiz),
                  titleFontSize: 26,
                  headerHeight: 80,
                  content: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.27,
                        child: Column(
                          children: [
                            CustomStableWaterCard(
                              remainingWater: stableList[0]['remainingWater'],
                              maxWater: 5,
                              phLevel: 7.2,
                              lastWaterText: stableList[0]['lastFeedText'],
                            ),
                            SizedBox(height: 16),
                            CustomStableFeedCard(
                              remainingFeed: 3,
                              maxFeed: 50,
                              lastFeedText: stableList[0]['lastFeedText'],
                            ),
                            SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Isi Otomatis:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 70,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.teal,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        formatDuration(
                                          controller.secondsRemaining.value,
                                        ),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            CustomButton(
                              text: 'Isi Pakan & Air',
                              onPressed: () {
                                showFillDialog(
                                  context: context,
                                  stableName:
                                      stableList[0]['stableName'], // index kandang terpilih
                                  mainTankWater:
                                      512.3, // contoh dummy, dari data tanki utama
                                  mainTankFeed:
                                      150.5, // contoh dummy, dari data tanki utama
                                  onSubmit: (water, feed) {
                                    // lakukan aksi pengisian di sini
                                    print(
                                      'Isi air: $water liter, Isi pakan: $feed gram',
                                    );
                                  },
                                );
                              },
                              fontSize: 32,
                              iconSize: 50,
                              height: 100,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              borderRadius: 10,
                              icon: Icons.restaurant_rounded,
                            ),
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
                                      color: Colors.teal.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.teal,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Penjadwalan',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                SizedBox(
                                  width: 200,
                                  height: 70,
                                  child: CustomButton(
                                    text: 'Ubah Jadwal',
                                    onPressed: () {
                                      layoutController.navigateTo(
                                        ControlSchedulePage(),
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
                              ],
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
                                  child: ListView.builder(
                                    itemCount: historyList.length,
                                    itemBuilder: (context, index) {
                                      final item = historyList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: HistoryEntryCard(
                                          datetime: item['datetime'],
                                          water: item['water'],
                                          feed: item['feed'],
                                          scheduleText: item['scheduleText'],
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
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          CustomCard(
            title: 'Daftar Kandang',
            content: SizedBox(
              height: 1000,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: stableList.length,
                  itemBuilder: (context, index) {
                    final stable = stableList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomStableCard(
                        stableName: stable['stableName'],
                        imageAsset: stable['imageAsset'],
                        scheduleText: stable['scheduleText'],
                        isActive: stable['isActive'],
                        remainingWater: stable['remainingWater'],
                        remainingFeed: stable['remainingFeed'],
                        lastFeedText: stable['lastFeedText'],
                        onSelect: () {
                          // aksi pilih kandang
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
    );
  }
}
