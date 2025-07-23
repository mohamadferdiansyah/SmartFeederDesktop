class FeedModel {
  final String feedId;
  final String name;
  final String type;
  final double stock; // kilogram

  FeedModel({
    required this.feedId,
    required this.name,
    required this.type,
    required this.stock,
  });
}