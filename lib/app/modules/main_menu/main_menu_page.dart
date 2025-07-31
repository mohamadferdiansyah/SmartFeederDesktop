import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_main_menu_card.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_main.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo row
                Container(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ipb.png',
                        height: 100,
                        width: 100,
                      ),
                      SizedBox(width: 16),
                      Image.asset(
                        'assets/images/biofarma.png',
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(width: 16),
                      Image.asset(
                        'assets/images/lpdp.png',
                        height: 200,
                        width: 200,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  width: MediaQuery.of(context).size.width * 0.62,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Smart Horse App',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pilih Menu Terlebih Dahulu',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // ganti SingleChildScrollView + Row dengan ini:
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: CustomMainMenuCard(
                              title: 'Smart Halter',
                              description:
                                  'Pantau kesehatan dan posisi kuda secara realtime.',
                              imageAsset: 'assets/images/smart_halter.jpg',
                              onTap: () {
                                Get.toNamed('/smart-halter');
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: CustomMainMenuCard(
                              title: 'Smart Feeder',
                              description:
                                  'Atur pemberian pakan & air otomatis untuk kuda.',
                              imageAsset: 'assets/images/smart_feeder.jpg',
                              onTap: () {
                                Get.toNamed('/smart-feeder');
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: CustomMainMenuCard(
                              title: 'Horse Walker',
                              description:
                                  'Kontrol dan monitor aktivitas berjalan kuda.',
                              imageAsset: 'assets/images/horse_walker.jpg',
                              onTap: () {
                                Get.toNamed('/horse-walker');
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: CustomMainMenuCard(
                              title: 'Room Monitoring',
                              description: 'Monitor Ruangan Kuda.',
                              imageAsset: 'assets/images/monitoring.jpg',
                              onTap: () {
                                Get.toNamed('/monitoring-room');
                              },
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
          Positioned(
            right: 40,
            bottom: 51,
            child: SizedBox(
              width: 200,
              height: 50,
              child: CustomButton(
                text: 'Logout',
                onPressed: () {
                  showCustomDialog(
                    context: context,
                    title: 'Konfirmasi Logout',
                    message: 'Apakah kamu yakin ingin logout?',
                    confirmText: 'Keluar',
                    cancelText: 'Batal',
                    icon: Icons.logout,
                    iconColor: AppColors.primary,
                    onConfirm: () {
                      Get.offAllNamed('/login');
                    },
                  );
                },
                width: 200,
                height: 60,
                fontSize: 20,
                iconSize: 24,
                icon: Icons.logout,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            height: 50,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Copyright IPB University © 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Versi 2.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
