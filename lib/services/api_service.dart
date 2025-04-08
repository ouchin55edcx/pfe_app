import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Helper method to create headers with token
  static Map<String, String> _createAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Adding Bearer prefix
    };
  }

  // Login as Syndic
  static Future<Map<String, dynamic>> loginAsSyndic(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/syndic/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Login as Proprietaire
  static Future<Map<String, dynamic>> loginAsProprietaire(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/proprietaire/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final token = AuthService.to.token;
    print('Using token for dashboard stats: $token'); // Debug log

    if (token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final headers = _createAuthHeaders(token);
    print('Request headers: $headers'); // Debug log

    final response = await http.get(
      Uri.parse('$baseUrl/statistics/dashboard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get dashboard statistics: ${response.body}');
    }
  }
}
