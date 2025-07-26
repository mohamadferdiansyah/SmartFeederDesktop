import 'package:get/get.dart';

class RoomModel {
  final String roomId;
  final String name;
  final String deviceSerial;
  final String status;
  final List<String> cctvIds;
  final String stableId;
  final String? horseId;
  final RxDouble remainingWater;
  final RxDouble remainingFeed;
  RxString waterScheduleType;
  RxString feedScheduleType;
  final Rxn<DateTime> lastFeedText;
  final RxnInt waterScheduleIntervalHour;
  final RxnInt feedScheduleIntervalHour;

  RoomModel({
    required this.roomId,
    required this.name,
    required this.deviceSerial,
    required this.status,
    required this.cctvIds,
    required this.stableId,
    this.horseId,
    int? waterScheduleIntervalHour,
    int? feedScheduleIntervalHour,
    required double remainingWater,
    required double remainingFeed,
    required String waterScheduleType,
    required String feedScheduleType,
    DateTime? lastFeedText,
  })  : waterScheduleType = waterScheduleType.obs,
        feedScheduleType = feedScheduleType.obs,
        remainingWater = remainingWater.obs,
        remainingFeed = remainingFeed.obs,
        waterScheduleIntervalHour = RxnInt(waterScheduleIntervalHour),
        feedScheduleIntervalHour = RxnInt(feedScheduleIntervalHour),
        lastFeedText = Rxn<DateTime>(lastFeedText);
}