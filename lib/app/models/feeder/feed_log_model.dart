class FeedLogModel {
  final String logId;
  final String feedId;
  final double quantity;
  final DateTime date;

  FeedLogModel({
    required this.logId,
    required this.feedId,
    required this.quantity,
    required this.date,
  });

  factory FeedLogModel.fromMap(Map<String, dynamic> map) => FeedLogModel(
        logId: map['log_id'],
        feedId: map['feed_id'],
        quantity: (map['quantity'] ?? 0.0).toDouble(),
        date: DateTime.parse(map['date']),
      );

  Map<String, dynamic> toMap() => {
        'log_id': logId,
        'feed_id': feedId,
        'quantity': quantity,
        'date': date.toIso8601String(),
      };
}