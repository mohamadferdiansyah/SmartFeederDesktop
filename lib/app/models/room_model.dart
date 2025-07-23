import 'package:get/get.dart';

class RoomModel {
  final String roomId;
  final String name;
  final String deviceSerial;
  final String status;
  final List<String> cctvIds; // Relasi ke 2 CCTV
  final String stableId;      // Relasi ke StableModel
  final String? horseId;      // Relasi ke HorseModel
  final RxDouble remainingWater;
  final RxDouble remainingFeed;
  final String scheduleType;
  final String? lastFeedText;

  RoomModel({
    required this.roomId,
    required this.name,
    required this.deviceSerial,
    required this.status,
    required this.cctvIds,
    required this.stableId,
    this.horseId,
    required double remainingWater,
    required double remainingFeed,
    required this.scheduleType,
    this.lastFeedText,
  })  : remainingWater = remainingWater.obs,
        remainingFeed = remainingFeed.obs;
}