class HistoryEntryModel {
  final String historyId;
  final String scheduleType;
  final double feed;
  final double water;
  final DateTime time;
  final String stableId;
  final String roomId;

  HistoryEntryModel({
    required this.historyId,
    required this.scheduleType,
    required this.feed,
    required this.water,
    required this.time,
    required this.stableId,
    required this.roomId,
  });

  factory HistoryEntryModel.fromMap(Map<String, dynamic> map) => HistoryEntryModel(
        historyId: map['history_id'],
        scheduleType: map['schedule_type'],
        feed: (map['feed'] ?? 0.0).toDouble(),
        water: (map['water'] ?? 0.0).toDouble(),
        time: map['time'] != null && DateTime.tryParse(map['time']) != null
            ? DateTime.parse(map['time'])
            : DateTime.now(),
        stableId: map['stable_id'],
        roomId: map['room_id'],
      );

  Map<String, dynamic> toMap() => {
        'history_id': historyId,
        'schedule_type': scheduleType,
        'feed': feed,
        'water': water,
        'time': time?.toIso8601String(),
        'stable_id': stableId,
        'room_id': roomId,
      };
}