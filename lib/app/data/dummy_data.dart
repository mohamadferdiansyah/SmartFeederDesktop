import 'package:smart_feeder_desktop/app/models/history_entry.dart';
import '../models/stable_model.dart';

final List<StableModel> stableList = [
  StableModel(
    stableName: 'Kandang 1',
    imageAsset: 'assets/images/stable.jpg',
    scheduleText: 'Penjadwalan',
    isActive: true,
    remainingWater: 4.2,
    remainingFeed: 38.0,
    lastFeedText: '2 jam yang lalu',
  ),
  StableModel(
    stableName: 'Kandang 2',
    imageAsset: 'assets/images/stable.jpg',
    scheduleText: 'Otomatis',
    isActive: false,
    remainingWater: 1.5,
    remainingFeed: 12.0,
    lastFeedText: '1 jam yang lalu',
  ),
  StableModel(
    stableName: 'Kandang 3',
    imageAsset: 'assets/images/stable.jpg',
    scheduleText: 'Manual',
    isActive: true,
    remainingWater: 0.8,
    remainingFeed: 5.5,
    lastFeedText: '30 menit yang lalu',
  ),
  StableModel(
    stableName: 'Kandang 4',
    imageAsset: 'assets/images/stable.jpg',
    scheduleText: 'Otomatis',
    isActive: true,
    remainingWater: 5.0,
    remainingFeed: 49.0,
    lastFeedText: '10 menit yang lalu',
  ),
  StableModel(
    stableName: 'Kandang 5',
    imageAsset: 'assets/images/stable.jpg',
    scheduleText: 'Manual',
    isActive: false,
    remainingWater: 0.2,
    remainingFeed: 0.0,
    lastFeedText: '3 jam yang lalu',
  ),
];

final List<HistoryEntryModel> historyList = [
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 18, 08, 30),
    water: 4.2,
    feed: 38.0,
    scheduleText: 'Penjadwalan',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 18, 12, 15),
    water: 2.5,
    feed: 21.0,
    scheduleText: 'Otomatis',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 18, 16, 45),
    water: 0.8,
    feed: 5.5,
    scheduleText: 'Manual',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 18, 20, 10),
    water: 5.0,
    feed: 49.0,
    scheduleText: 'Otomatis',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 17, 09, 20),
    water: 3.7,
    feed: 30.0,
    scheduleText: 'Penjadwalan',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 17, 13, 00),
    water: 1.2,
    feed: 10.0,
    scheduleText: 'Manual',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 17, 18, 10),
    water: 4.9,
    feed: 44.0,
    scheduleText: 'Penjadwalan',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 17, 22, 45),
    water: 0.5,
    feed: 3.0,
    scheduleText: 'Manual',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 16, 07, 55),
    water: 2.0,
    feed: 18.0,
    scheduleText: 'Otomatis',
  ),
  HistoryEntryModel(
    datetime: DateTime(2025, 7, 16, 15, 30),
    water: 5.0,
    feed: 50.0,
    scheduleText: 'Penjadwalan',
  ),
];