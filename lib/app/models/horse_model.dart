class HorseModel {
  final String horseId;
  final String name;
  final String gender;
  final String type;
  final DateTime dateOfBirth;
  final DateTime dateJoinedStable;
  final String healthStatus; // e.g. "Sehat", "Sakit"
  final String imageAsset;

  HorseModel({
    required this.horseId,
    required this.name,
    required this.gender,
    required this.type,
    required this.dateOfBirth,
    required this.dateJoinedStable,
    required this.healthStatus,
    required this.imageAsset,
  });

  int getAgeInYears() {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years;
  }
}