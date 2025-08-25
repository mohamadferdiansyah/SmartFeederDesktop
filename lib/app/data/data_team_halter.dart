import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/test_team_model.dart';

class DataTeamHalter {
  static final _box = GetStorage();

  static TestTeamModel? getTeam() {
    final map = _box.read('test_team');
    if (map == null) return null;
    return TestTeamModel.fromJson(Map<String, dynamic>.from(map));
  }

  static void saveTeam(TestTeamModel team) {
    _box.write('test_team', team.toJson());
  }

  static void clearTeam() {
    _box.remove('test_team');
  }
}