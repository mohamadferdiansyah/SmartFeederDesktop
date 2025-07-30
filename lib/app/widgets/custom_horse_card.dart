import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_battery_indicator.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';

class CustomHorseCard extends StatelessWidget {
  final String horseName;
  final String horseId;
  final String horseRoom;
  final bool isRoomFilled;
  final int batteryPercent;
  final String deviceActive;
  final bool cctvActive;
  final VoidCallback? onSelectHorse;
  final VoidCallback? onTapCctv;

  const CustomHorseCard({
    super.key,
    required this.horseName,
    required this.isRoomFilled,
    required this.batteryPercent,
    required this.deviceActive,
    required this.horseId,
    required this.horseRoom,
    required this.cctvActive,
    this.onSelectHorse,
    this.onTapCctv,
  });

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    horseName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(' | '),
                  Text(
                    horseId,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(' | '),
                  Text(
                    horseRoom,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Tooltip(
                    message: isRoomFilled
                        ? 'Kuda Di Kandang'
                        : 'Kuda Tidak Di Kandang',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isRoomFilled ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRoomFilled
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Baterai Device',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: batteryPercent > 20 ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomBatteryIndicator(
                        percent: batteryPercent,
                        iconSize: 20,
                        iconColor: Colors.white,
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
                        color: deviceActive == "Aktif"
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.power_settings_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deviceActive,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 16),
          Row(
            children: [
              // Tombol utama
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: CustomButton(
                    text: 'Pilih Kuda',
                    onPressed: onSelectHorse ?? () {},
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
                message: cctvActive ? 'CCTV Aktif' : 'CCTV Tidak Aktif',
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: Material(
                    color: cctvActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onTapCctv,
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
