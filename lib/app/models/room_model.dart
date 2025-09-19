import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RoomModel {
  final String roomId;
  final String name;
  final String? deviceSerial;
  final String status;
  final List<String>? cctvId; // Simpan sebagai string. Jika ingin array, simpan JSON string.
  final String stableId;
  final String? horseId;
  final double remainingWater;
  final double remainingFeed;
  final Rxn<DateTime> lastFeedText;
  final RxnInt waterScheduleIntervalHour;
  final RxnInt feedScheduleIntervalHour;

  RoomModel({
    required this.roomId,
    required this.name,
    required this.deviceSerial,
    required this.status,
    required this.cctvId,
    required this.stableId,
    this.horseId,
    required this.remainingWater,
    required this.remainingFeed,
    DateTime? lastFeedText,
    int? waterScheduleIntervalHour,
    int? feedScheduleIntervalHour,
  })  : waterScheduleIntervalHour = RxnInt(waterScheduleIntervalHour),
        feedScheduleIntervalHour = RxnInt(feedScheduleIntervalHour),
        lastFeedText = Rxn<DateTime>(lastFeedText);


  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(
        roomId: map['room_id'],
        name: map['name'],
        deviceSerial: map['device_serial'],
        status: map['status'],
        cctvId: map['cctv_id'] ?? '',
        stableId: map['stable_id'],
        horseId: map['horse_id'],
        remainingWater: (map['remaining_water'] ?? 0).toDouble(),
        remainingFeed: (map['remaining_feed'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'room_id': roomId,
        'name': name,
        'device_serial': deviceSerial,
        'status': status,
        'cctv_id': cctvId,
        'stable_id': stableId,
        'horse_id': horseId,
        'remaining_water': remainingWater,
        'remaining_feed': remainingFeed,
      };
}