class HistoryEntryModel {
  final String historyId;
  final String stableId;
  final String roomId;
  final DateTime date;
  final String type;
  final double feed;  // kg
  final double water; // liter

  HistoryEntryModel({
    required this.historyId,
    required this.stableId,
    required this.roomId,
    required this.date,
    required this.type,
    required this.feed,
    required this.water,
  });

}
