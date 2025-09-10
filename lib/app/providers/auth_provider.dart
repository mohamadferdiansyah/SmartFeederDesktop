import 'package:smart_feeder_desktop/app/services/api_service.dart';

class AuthProvider {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        '/Auth/Login',
        body: {"username": username, "password": password},
      );
      return response; // sukses, body JSON diparsing
    } catch (e) {
      // Kalau error dari api_service, misal status code 400/401
      // Pastikan api_service tetap return body, bukan throw Exception
      if (e is Map<String, dynamic>) {
        return e; // bisa ambil Error-nya di controller
      }
      return {"Error": "Terjadi kesalahan jaringan/server"};
    }
  }
}
