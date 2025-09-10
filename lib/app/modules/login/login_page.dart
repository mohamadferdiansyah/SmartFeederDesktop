import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/modules/login/login_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LoginController loginController = Get.find<LoginController>();

  bool rememberMe = false; // Tambahkan ini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
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

          // Overlay semi-transparan (opsional)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3), // Overlay gelap
          ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
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
                      height: 150,
                      width: 150,
                    ),
                    SizedBox(width: 16),
                    Image.asset(
                      'assets/images/biofarma.png',
                      height: 250,
                      width: 250,
                    ),
                    SizedBox(width: 16),
                    Image.asset(
                      'assets/images/lpdp.png',
                      height: 250,
                      width: 250,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      padding: EdgeInsets.all(32),
                      margin: EdgeInsets.symmetric(horizontal: 32),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Smart Horse App',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Silahkan Login Untuk Melanjutkan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 32),
                          CustomInput(
                            label: 'Username',
                            controller: emailController,
                            hint: 'Masukkan username',
                            icon: Icons.person,
                          ),
                          SizedBox(height: 16),
                          CustomInput(
                            label: 'Password',
                            controller: passwordController,
                            hint: 'Masukkan password',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          // ========== Tambahkan Checkbox Remember Me di sini ==========
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Obx(
                                () => Checkbox(
                                  value: loginController.rememberMe.value,
                                  onChanged: (value) {
                                    loginController.rememberMe.value =
                                        value ?? false;
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              const Text(
                                "Remember Me",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // ===========================================================
                          SizedBox(height: 16),
                          Obx(
                            () => loginController.isLoading.value
                                ? CircularProgressIndicator()
                                : CustomButton(
                                    text: 'Login',
                                    onPressed: () async {
                                      if (emailController.text.isEmpty ||
                                          passwordController.text.isEmpty) {
                                        showAppToast(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: 'Gagal Login!',
                                          description:
                                              'Username Dan Password Tidak Boleh Kosong.',
                                        );
                                        return;
                                      }
                                      final sukses = await loginController
                                          .login(
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );
                                      if (sukses) {
                                        Get.offAndToNamed('/main-menu');
                                        showAppToast(
                                          context: context,
                                          type: ToastificationType.success,
                                          title: 'Berhasil Login!',
                                          description: 'Anda Telah Login.',
                                        );
                                      } else {
                                        showAppToast(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: 'Gagal Login!',
                                          description:
                                              loginController.error.value,
                                        );
                                      }
                                    },
                                    backgroundColor: AppColors.primary,
                                    iconTrailing: Icons.login,
                                  ),
                          ),
                          // Obx(
                          //   () => loginController.error.value.isNotEmpty
                          //       ? Padding(
                          //           padding: const EdgeInsets.only(top: 12),
                          //           child: Text(
                          //             loginController.error.value,
                          //             style: TextStyle(
                          //               color: Colors.red,
                          //               fontWeight: FontWeight.bold,
                          //             ),
                          //           ),
                          //         )
                          //       : SizedBox(),
                          // ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 48,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            spreadRadius: 4,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo CassMaTech
                          Image.asset(
                            'assets/images/lpdp_full.png',
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Dibiayai dengan Hibah Riset Inovatif Produktif (RISPRO) ',
                                ),
                                TextSpan(
                                  text:
                                      '"Sistem Perangkat Cerdas Monitoring dan Klasifikasi Kesehatan Kuda Berbasis AIoT Untuk Mendukung Indonesia 4.0 dalam Pembuatan Antisera"',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      ', Kontrak Nomor PRJ-15/LPDP/LPDP.4/2022 tanggal 7 Oktober 2022', // tambahkan kalimat lanjutan jika ada
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ==== BUTTON KELUAR DI POJOK KANAN BAWAH ====
          Positioned(
            right: 32,
            bottom: 32,
            child: SizedBox(
              width: 150,
              height: 50,
              child: CustomButton(
                text: 'Keluar',
                iconTrailing: Icons.exit_to_app,
                backgroundColor: Colors.red,
                onPressed: () {
                  showCustomDialog(
                    context: context,
                    title: 'Keluar Aplikasi',
                    message: 'Apakah kamu yakin ingin keluar dari aplikasi?',
                    confirmText: 'Keluar',
                    icon: Icons.exit_to_app,
                    iconColor: Colors.red,
                    onConfirm: () async {
                      DataTeamHalter.clearTeam();
                      print('tim :${DataTeamHalter.getTeam()}');
                      await Future.delayed(Duration(milliseconds: 1000));
                      exit(0);
                    },
                  );
                },
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
