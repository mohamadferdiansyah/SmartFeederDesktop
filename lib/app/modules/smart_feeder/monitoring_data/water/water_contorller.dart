import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/water_model.dart';

class WaterContorller extends GetxController {
  final RxList<WaterModel> waterStocks = <WaterModel>[
    WaterModel(
      id: 'WS001',
      sourceName: 'Tandon Utama',
      volume: 1500.0,
      dateIn: DateTime(2025, 7, 20, 8, 30),
      status: 'Masuk',
    ),
    WaterModel(
      id: 'WS002',
      sourceName: 'Sumur Bor',
      volume: 1000.0,
      dateIn: DateTime(2025, 7, 20, 14, 00),
      status: 'Masuk',
    ),
    WaterModel(
      id: 'WS003',
      sourceName: 'Tandon Utama',
      volume: 500.0,
      dateIn: DateTime(2025, 7, 21, 9, 10),
      status: 'Keluar',
    ),
    WaterModel(
      id: 'WS004',
      sourceName: 'Sumur Bor',
      volume: 800.0,
      dateIn: DateTime(2025, 7, 21, 15, 20),
      status: 'Masuk',
    ),
    WaterModel(
      id: 'WS005',
      sourceName: 'Tandon Cadangan',
      volume: 300.0,
      dateIn: DateTime(2025, 7, 22, 10, 50),
      status: 'Masuk',
    ),
    WaterModel(
      id: 'WS006',
      sourceName: 'Tandon Utama',
      volume: 200.0,
      dateIn: DateTime(2025, 7, 22, 16, 15),
      status: 'Rusak',
    ),
    WaterModel(
      id: 'WS007',
      sourceName: 'Sumur Bor',
      volume: 900.0,
      dateIn: DateTime(2025, 7, 23, 8, 45),
      status: 'Masuk',
    ),
    WaterModel(
      id: 'WS008',
      sourceName: 'Tandon Cadangan',
      volume: 100.0,
      dateIn: DateTime(2025, 7, 23, 17, 00),
      status: 'Keluar',
    ),
    WaterModel(
      id: 'WS009',
      sourceName: 'Tandon Utama',
      volume: 1200.0,
      dateIn: DateTime(2025, 7, 24, 7, 30),
      status: 'Masuk',
    ),
    WaterModel(
      id: 'WS010',
      sourceName: 'Sumur Bor',
      volume: 600.0,
      dateIn: DateTime(2025, 7, 24, 19, 27),
      status: 'Masuk',
    ),
    // Tambahkan lebih banyak data sesuai kebutuhan
  ].obs;
}