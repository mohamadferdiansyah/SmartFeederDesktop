import 'package:get/get.dart';

class StableModel {
  final String stableName;
  final String imageAsset;
  final String scheduleText;
  final bool isActive;
  final RxDouble remainingWater;
  final RxDouble remainingFeed;
  final String lastFeedText;

  StableModel({
    required this.stableName,
    required this.imageAsset,
    required this.scheduleText,
    required this.isActive,
    required double remainingWater,
    required double remainingFeed,
    required this.lastFeedText,
  })  : remainingWater = remainingWater.obs,
        remainingFeed = remainingFeed.obs;
}