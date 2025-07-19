class HistoryEntryModel {
  final DateTime datetime;
  final double water;
  final double feed;
  final String scheduleText;

  HistoryEntryModel({
    required this.datetime,
    required this.water,
    required this.feed,
    required this.scheduleText,
  });

  factory HistoryEntryModel.fromMap(Map<String, dynamic> map) {
    return HistoryEntryModel(
      datetime: map['datetime'],
      water: map['water'],
      feed: map['feed'],
      scheduleText: map['scheduleText'],
    );
  }
}