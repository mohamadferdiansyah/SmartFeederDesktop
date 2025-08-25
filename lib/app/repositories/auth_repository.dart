import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider = AuthProvider();
  final GetStorage _storage = GetStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await _provider.login(username, password);
    // Simpan JWT token ke storage
    if (result['jwt'] != null) {
      await _storage.write('jwt', result['jwt']);
      await _storage.write('user', result['username']);
    }
    return result;
  }

  String? get token => _storage.read('jwt');
  void logout() => _storage.erase();
}