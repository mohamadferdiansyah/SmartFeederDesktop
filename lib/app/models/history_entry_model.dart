class HistoryEntryModel {
  final int stableIndex; // atau String stableId, sesuaikan dengan model stable kamu
  final DateTime datetime;
  final double water;
  final double feed;
  final String scheduleText;

  HistoryEntryModel({
    required this.stableIndex,
    required this.datetime,
    required this.water,
    required this.feed,
    required this.scheduleText,
  });

  factory HistoryEntryModel.fromMap(Map<String, dynamic> map) {
    return HistoryEntryModel(
      stableIndex: map['stableIndex'],
      datetime: map['datetime'],
      water: map['water'],
      feed: map['feed'],
      scheduleText: map['scheduleText'],
    );
  }
}