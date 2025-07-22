import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/history_entry_model.dart';

class FeederHistoryController extends GetxController {
  
  final RxList<HistoryEntryModel> historyList = <HistoryEntryModel>[
    // Data dummy diperbanyak
    HistoryEntryModel(
      stableIndex: 0,
      datetime: DateTime(2025, 7, 18, 8, 30),
      water: 4.2,
      feed: 38.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 0,
      datetime: DateTime(2025, 7, 20, 7, 45),
      water: 2.8,
      feed: 25.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 18, 12, 15),
      water: 2.5,
      feed: 21.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 19, 11, 30),
      water: 1.8,
      feed: 15.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 20, 9, 15),
      water: 3.0,
      feed: 20.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 18, 14, 45),
      water: 1.0,
      feed: 10.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 19, 13, 15),
      water: 0.5,
      feed: 8.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 2,
      datetime: DateTime(2025, 7, 20, 12, 0),
      water: 2.4,
      feed: 18.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 20, 13, 30),
      water: 4.8,
      feed: 47.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 21, 8, 15),
      water: 3.2,
      feed: 30.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 21, 10, 0),
      water: 2.0,
      feed: 18.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 21, 17, 0),
      water: 4.5,
      feed: 40.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 22, 7, 30),
      water: 3.8,
      feed: 30.0,
      scheduleText: 'Penjadwalan',
    ),
    // Tambahkan lagi data dummy jika perlu
    HistoryEntryModel(
      stableIndex: 5,
      datetime: DateTime(2025, 7, 21, 9, 10),
      water: 1.2,
      feed: 8.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 6,
      datetime: DateTime(2025, 7, 22, 8, 55),
      water: 2.7,
      feed: 20.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 0,
      datetime: DateTime(2025, 7, 22, 10, 10),
      water: 4.6,
      feed: 40.0,
      scheduleText: 'Penjadwalan',
    ),
    HistoryEntryModel(
      stableIndex: 1,
      datetime: DateTime(2025, 7, 22, 12, 30),
      water: 2.2,
      feed: 18.0,
      scheduleText: 'Manual',
    ),
    HistoryEntryModel(
      stableIndex: 3,
      datetime: DateTime(2025, 7, 22, 16, 0),
      water: 3.3,
      feed: 28.0,
      scheduleText: 'Otomatis',
    ),
    HistoryEntryModel(
      stableIndex: 4,
      datetime: DateTime(2025, 7, 22, 17, 45),
      water: 4.0,
      feed: 39.0,
      scheduleText: 'Otomatis',
    ),
  ].obs;


}