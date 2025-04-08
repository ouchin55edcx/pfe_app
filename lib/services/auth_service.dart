import 'dart:convert';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends GetxController {
  static AuthService get to => Get.find();

  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxString _token = RxString('');
  final RxString _userRole = RxString('');

  User? get currentUser => _currentUser.value;
  String get token => _token.value;
  String get userRole => _userRole.value;

  bool get isLoggedIn => _token.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Load user data from storage
  Future<void> loadUserData() async {
    final token = await StorageService.getToken();
    final role = await StorageService.getUserRole();
    final userData = await StorageService.getUserData();

    if (token != null && role != null && userData != null) {
      _token.value = token;
      _userRole.value = role;

      final userMap = jsonDecode(userData);
      if (role == 'syndic') {
        _currentUser.value = SyndicUser.fromJson(userMap);
      } else if (role == 'proprietaire') {
        _currentUser.value = ProprietaireUser.fromJson(userMap);
      }
    }
  }

  // Login as Syndic
  Future<bool> loginAsSyndic(String email, String password) async {
    try {
      final response = await ApiService.loginAsSyndic(email, password);

      if (response['success'] == true) {
        final userData = response['user'];
        _currentUser.value = SyndicUser.fromJson(userData);
        _token.value = response['token'];
        _userRole.value = 'syndic';

        // Save to storage
        await StorageService.saveToken(response['token']);
        await StorageService.saveUserRole('syndic');
        await StorageService.saveUserData(jsonEncode(userData));

        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Login as Proprietaire
  Future<bool> loginAsProprietaire(String email, String password) async {
    try {
      final response = await ApiService.loginAsProprietaire(email, password);

      if (response['success'] == true) {
        final userData = response['user'];
        _currentUser.value = ProprietaireUser.fromJson(userData);
        _token.value = response['token'];
        _userRole.value = 'proprietaire';

        // Save to storage
        await StorageService.saveToken(response['token']);
        await StorageService.saveUserRole('proprietaire');
        await StorageService.saveUserData(jsonEncode(userData));

        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser.value = null;
    _token.value = '';
    _userRole.value = '';

    // Clear storage
    await StorageService.clearAll();
  }
}
