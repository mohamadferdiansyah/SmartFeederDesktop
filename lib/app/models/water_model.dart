class WaterModel {
  final String id;
  final String sourceName;
  final double volume; // Satuan: Liter
  final DateTime dateIn;
  final String status; // Contoh: "Masuk", "Keluar", "Rusak", dll

  WaterModel({
    required this.id,
    required this.sourceName,
    required this.volume,
    required this.dateIn,
    required this.status,
  });
}