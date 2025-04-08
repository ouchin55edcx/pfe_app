import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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
}
