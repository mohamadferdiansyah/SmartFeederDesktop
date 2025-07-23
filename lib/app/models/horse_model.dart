
class HorseModel {
  final String horseId;
  final String name;
  final String type;
  final String gender;
  final String age;      // Contoh: 1,47 tahun
  final String? roomId;  // Relasi ke RoomModel

  HorseModel({
    required this.horseId,
    required this.name,
    required this.type,
    required this.gender,
    required this.age,
    this.roomId,
  });
  // int getAgeInYears() {
  //   final now = DateTime.now();
  //   int years = now.year - dateOfBirth.year;
  //   if (now.month < dateOfBirth.month ||
  //       (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
  //     years--;
  //   }
  //   return years;
  // }
}