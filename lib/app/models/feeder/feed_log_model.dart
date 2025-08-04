class FeedLogModel {
  final String logId;
  final String feedId; // relasi ke FeedModel
  final double quantity; // kilogram
  final DateTime date;

  FeedLogModel({
    required this.logId,
    required this.feedId,
    required this.quantity,
    required this.date,
  });
}