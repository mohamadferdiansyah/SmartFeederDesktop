import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/walker/walker_history_model.dart';

class WalkerHistoryController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<WalkerHistoryModel> get walkerHistoryList => dataController.walkerHistoryList;
  RxList<HorseModel> get horseList => dataController.horseList;

  // Filter berdasarkan device ID
  List<WalkerHistoryModel> getHistoryByDevice(String deviceId) {
    return walkerHistoryList.where((h) => h.deviceId == deviceId).toList()
      ..sort((a, b) => b.timeStart.compareTo(a.timeStart));
  }

  // Get recent history (5 terakhir)
  List<WalkerHistoryModel> getRecentHistory([int limit = 5]) {
    final sorted = List<WalkerHistoryModel>.from(walkerHistoryList)
      ..sort((a, b) => b.timeStart.compareTo(a.timeStart));
    return sorted.take(limit).toList();
  }

  // Get history by date range
  List<WalkerHistoryModel> getHistoryByDateRange(DateTime start, DateTime end) {
    return walkerHistoryList.where((h) {
      return h.timeStart.isAfter(start) && h.timeStart.isBefore(end);
    }).toList()
      ..sort((a, b) => b.timeStart.compareTo(a.timeStart));
  }

  // Add new history
  Future<void> addHistory(WalkerHistoryModel history) async {
    await dataController.addWalkerHistory(history);
  }

  // Update history (untuk menambahkan timeStop)
  Future<void> updateHistory(WalkerHistoryModel history) async {
    await dataController.updateWalkerHistory(history);
  }

  // Clear all history
  void clearHistory() {
    walkerHistoryList.clear();
  }

  // Update method getStatusStatistics
Map<String, int> getStatusStatistics() {
  final stats = <String, int>{};
  for (final history in walkerHistoryList) {
    stats[history.status] = (stats[history.status] ?? 0) + 1;
  }
  return stats;
}

// Tambah method untuk statistik yang lebih detail
Map<String, int> getDetailedStatistics() {
  final stats = <String, int>{
    'TOTAL': walkerHistoryList.length,
    'SEDANG_BERJALAN': walkerHistoryList.where((h) => h.timeStop == null).length,
    'SELESAI': walkerHistoryList.where((h) => h.status == 'SELESAI').length,
    'DIHENTIKAN': walkerHistoryList.where((h) => h.status == 'DIHENTIKAN').length,
  };
  return stats;
}

  // Get horse name by ID
  String getHorseNameById(String horseId) {
    final horse = horseList.firstWhereOrNull((h) => h.horseId == horseId);
    return horse?.name ?? 'Kuda tidak ditemukan';
  }

  // Get multiple horse names
  List<String> getHorseNamesByIds(List<String> horseIds) {
    return horseIds.map((id) => getHorseNameById(id)).toList();
  }

  // Find running history by device ID (history yang belum ada timeStop)
  WalkerHistoryModel? getRunningHistoryByDevice(String deviceId) {
    try {
      return walkerHistoryList.firstWhere(
        (h) => h.deviceId == deviceId && h.timeStop == null,
      );
    } catch (e) {
      return null;
    }
  }
}