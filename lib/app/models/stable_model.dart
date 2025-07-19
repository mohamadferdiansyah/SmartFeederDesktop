class StableModel {
  final String stableName;
  final String imageAsset;
  final String scheduleText; // Penjadwalan, Otomatis, Manual
  final bool isActive;
  final double remainingWater; // Liter
  final double remainingFeed;  // Gram
  final String lastFeedText;

  StableModel({
    required this.stableName,
    required this.imageAsset,
    required this.scheduleText,
    required this.isActive,
    required this.remainingWater,
    required this.remainingFeed,
    required this.lastFeedText,
  });

  factory StableModel.fromMap(Map<String, dynamic> map) {
    return StableModel(
      stableName: map['stableName'],
      imageAsset: map['imageAsset'],
      scheduleText: map['scheduleText'],
      isActive: map['isActive'],
      remainingWater: map['remainingWater'],
      remainingFeed: map['remainingFeed'],
      lastFeedText: map['lastFeedText'],
    );
  }
}