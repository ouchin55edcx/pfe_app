import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    print('Token saved: $token'); // Debug log
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    print('Retrieved token: $token'); // Debug log
    return token;
  }

  // Save user role
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userRoleKey, role);
    print('User role saved: $role'); // Debug log
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(userRoleKey);
    print('Retrieved user role: $role'); // Debug log
    return role;
  }

  // Save user data
  static Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, userData);
  }

  // Get user data
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userDataKey);
  }

  // Clear all stored data (for logout)
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All storage cleared successfully'); // Debug log
    } catch (e) {
      print('Error clearing storage: $e'); // Debug log
      throw Exception('Failed to clear storage: $e');
    }
  }
}
