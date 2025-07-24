class DataSerialModel {
  final int no;
  final String data; // data raw/mentah seperti dari serial monitor
  final String tanggal; // format: yyyy-MM-dd
  final String waktu; // format: HH:mm:ss

  DataSerialModel({
    required this.no,
    required this.data,
    required this.tanggal,
    required this.waktu,
  });
}