class HorseModel {
  final String horseId;
  final String name;
  final String category;
  final String type;
  final String gender;
  final int age;
  final String? roomId;

  HorseModel({
    required this.horseId,
    required this.name,
    required this.category,
    required this.type,
    required this.gender,
    required this.age,
    this.roomId,
  });

  factory HorseModel.fromMap(Map<String, dynamic> map) => HorseModel(
        horseId: map['horse_id'],
        name: map['name'],
        category: map['category'],
        type: map['type'],
        gender: map['gender'],
        age: map['age'] ?? 0,
        roomId: map['room_id'],
      );

  Map<String, dynamic> toMap() => {
        'horse_id': horseId,
        'name': name,
        'category': category,
        'type': type,
        'gender': gender,
        'age': age,
        'room_id': roomId,
      };
}