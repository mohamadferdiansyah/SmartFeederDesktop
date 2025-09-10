import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  var isLoading = false.obs;
  var error = ''.obs;

  // Untuk handling Remember Me, simpan di controller
  var rememberMe = false.obs;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _repo.login(username, password);
      if (result['jwt'] != null) {
        // Sukses login, bisa navigasi ke main menu
        return true;
      } else {
        // Ambil pesan error dari response jika ada
        error.value = result['Error'] ?? 'Login gagal, response tidak valid.';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _repo.logout();
    Get.offAllNamed('/login'); // Navigasi ke login, hapus stack
  }
}
