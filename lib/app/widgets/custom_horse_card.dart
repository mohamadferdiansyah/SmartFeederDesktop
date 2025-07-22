import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';

class CustomHorseCard extends StatelessWidget {
  const CustomHorseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
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
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Kuda 1',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Ruangan Terisi Kuda',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Baterai Device',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '87%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Status Device',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aktif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Tombol utama
              Expanded(
                child: SizedBox(
                  height: 48, // tinggi konsisten
                  child: CustomButton(
                    text: 'Pilih Kuda',
                    onPressed: () {},
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    borderRadius: 10,
                    icon: Icons.house_siding_rounded,
                    iconSize: 24,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol icon kamera
              Tooltip(
                message: 'CCTV Aktif',
                child: SizedBox(
                  height: 48, // samakan tinggi
                  width: 48, // biar kotak
                  child: Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {},
                      child: Center(
                        child: Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
