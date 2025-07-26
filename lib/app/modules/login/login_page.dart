import 'dart:io'; // <-- Tambahkan ini
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';

import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
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
                          SizedBox(height: 32),
                          CustomButton(
                            text: 'Login',
                            onPressed: () {
                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Username dan Password tidak boleh kosong',
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.offAndToNamed('/main-menu');
                              }
                            },
                            backgroundColor: AppColors.primary,
                            iconTrailing: Icons.login,
                          ),
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
                            height: 200,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Dibiayai dengan Hibah Riset Inovatif Produktif (RISPRO), LPDP Tahun II dengan nomor kontrak PRJ-31/LPDP/2021",
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
                    onConfirm: () {
                      exit(0);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
