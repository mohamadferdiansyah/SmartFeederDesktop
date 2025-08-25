import 'package:smart_feeder_desktop/app/services/api_service.dart';

class AuthProvider {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await apiService.post('/Auth/Login', body: {
      "username": username,
      "password": password,
    });
    return response;
  }
}