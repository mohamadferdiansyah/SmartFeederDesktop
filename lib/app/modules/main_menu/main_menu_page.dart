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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ipb.png',
                      height: 200,
                      width: 200,
                    ),
                    SizedBox(width: 20),
                    Image.asset(
                      'assets/images/biofarma.png',
                      height: 250,
                      width: 250,
                    ),
                  ],
                ),
                // Title card + Menu Cards (DI DALAM 1 CONTAINER)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                          Spacer(),
                          CustomButton(
                            text: 'Logout',
                            onPressed: () {
                              showConfirmationDialog(
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
                            fontSize: 24,
                            iconSize: 28,
                            icon: Icons.logout,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
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
                              title: 'Monitoring Room',
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
        ],
      ),
    );
  }
}
