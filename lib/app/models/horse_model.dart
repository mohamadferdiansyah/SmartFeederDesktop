class HorseModel {
  final String horseId;
  final String name;
  final String type;
  final String gender;
  final int age;
  final String? roomId;
  final String? category; // Tambahkan ini
  final String? birthPlace; // Tempat Lahir
  final DateTime? birthDate; // Tanggal Lahir (format: yyyy-MM-dd atau DateTime)
  final DateTime?
  settleDate; // Tanggal Menetap (format: yyyy-MM-dd atau string)
  final double? length; // Panjang
  final double? weight; // Berat
  final double? height; // Tinggi
  final double? chestCircum; // Lingkar Dada
  final String? skinColor; // Warna Kulit
  final String? markDesc; // Deskripsi Tanda
  final List<String>? photos;

  HorseModel({
    required this.horseId,
    required this.name,
    required this.type,
    required this.gender,
    required this.age,
    this.roomId,
    this.category, // Tambahkan ini
    this.birthPlace,
    this.birthDate,
    this.settleDate,
    this.length,
    this.weight,
    this.height,
    this.chestCircum,
    this.skinColor,
    this.markDesc,
    this.photos,
  });

  factory HorseModel.fromMap(Map<String, dynamic> map) => HorseModel(
    horseId: map['horse_id'],
    name: map['name'],
    type: map['type'],
    gender: map['gender'],
    age: map['age'] ?? 0,
    roomId: map['room_id'],
    category: map['category'],
    birthPlace: map['birth_place'],
    birthDate: map['birth_date'] != null
        ? DateTime.tryParse(map['birth_date'].toString())
        : null,
    settleDate: map['settle_date'] != null
        ? DateTime.tryParse(map['settle_date'].toString())
        : null,
    length: map['length'] != null
        ? (map['length'] is num
              ? (map['length'] as num).toDouble()
              : double.tryParse(map['length'].toString()))
        : null,
    weight: map['weight'] != null
        ? (map['weight'] is num
              ? (map['weight'] as num).toDouble()
              : double.tryParse(map['weight'].toString()))
        : null,
    height: map['height'] != null
        ? (map['height'] is num
              ? (map['height'] as num).toDouble()
              : double.tryParse(map['height'].toString()))
        : null,
    chestCircum: map['chest_circum'] != null
        ? (map['chest_circum'] is num
              ? (map['chest_circum'] as num).toDouble()
              : double.tryParse(map['chest_circum'].toString()))
        : null,
    skinColor: map['skin_color'],
    markDesc: map['mark_desc'],
    photos: map['photos'] == null
        ? []
        : List<String>.from(
            (map['photos'] is String)
                ? (map['photos'] as String).split(
                    ',',
                  ) // jika disimpan di DB sebagai string dengan koma
                : map['photos'] as List,
          ),
  );

  Map<String, dynamic> toMap() => {
    'horse_id': horseId,
    'name': name,
    'type': type,
    'gender': gender,
    'age': age,
    'room_id': roomId,
    'category': category,
    'birth_place': birthPlace,
    'birth_date': birthDate?.toIso8601String(),
    'settle_date': settleDate?.toIso8601String(),
    'length': length,
    'weight': weight,
    'height': height,
    'chest_circum': chestCircum,
    'skin_color': skinColor,
    'mark_desc': markDesc,
    'photos': photos?.join(','), // simpan ke DB sebagai string dipisah koma
  };
}
