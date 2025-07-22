class FeedModel {
  final String id;
  final String feedName;
  final int quantity; // satuan: Kg
  final DateTime dateIn;
  final String status; // misal: "Masuk", "Keluar", "Rusak", etc

  FeedModel({
    required this.id,
    required this.feedName,
    required this.quantity,
    required this.dateIn,
    required this.status,
  });
}