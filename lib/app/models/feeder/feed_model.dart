class FeedModel {
  final String feedId;
  final String name;
  final String type;
  final double stock;

  FeedModel({
    required this.feedId,
    required this.name,
    required this.type,
    required this.stock,
  });

  factory FeedModel.fromMap(Map<String, dynamic> map) => FeedModel(
        feedId: map['feed_id'],
        name: map['name'],
        type: map['type'],
        stock: (map['stock'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'feed_id': feedId,
        'name': name,
        'type': type,
        'stock': stock,
      };
}