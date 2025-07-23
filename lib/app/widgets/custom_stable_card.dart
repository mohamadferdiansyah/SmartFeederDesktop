import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'custom_button.dart';

class CustomStableCard extends StatelessWidget {
  final String stableName;
  final String imageAsset;
  final String scheduleText;
  final bool isActive;
  final RxDouble remainingWater; // <-- RxDouble
  final RxDouble remainingFeed; // <-- RxDouble
  final String lastFeedText;
  final VoidCallback onSelect;
  final Color? primaryColor;

  const CustomStableCard({
    Key? key,
    required this.stableName,
    required this.imageAsset,
    required this.scheduleText,
    required this.isActive,
    required this.remainingWater,
    required this.remainingFeed,
    required this.lastFeedText,
    required this.onSelect,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color activeColor = isActive ? Colors.green : Colors.red;
    final String activeText = isActive ? 'Aktif' : 'Mati';

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
              imageAsset,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                stableName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheduleText == 'Penjadwalan'
                      ? Colors.teal
                      : scheduleText == 'Otomatis'
                      ? Colors.blue
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scheduleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // === Obx untuk Air ===
          Obx(
            () => RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'Tersedia Air: '),
                  TextSpan(
                    text: '${remainingWater.value.toStringAsFixed(1)}L',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: primaryColor ?? Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // === Obx untuk Pakan ===
          Obx(
            () => RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'Tersedia Pakan: '),
                  TextSpan(
                    text: '${remainingFeed.value.toStringAsFixed(1)}g',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Pemberian Terakhir: $lastFeedText',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Pilih Ruangan',
            onPressed: onSelect,
            backgroundColor: primaryColor ?? AppColors.primary,
            textColor: Colors.white,
            borderRadius: 10,
            icon: Icons.house_siding_rounded,
          ),
        ],
      ),
    );
  }
}
