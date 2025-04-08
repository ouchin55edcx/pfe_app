import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proprietaire.dart';
import '../services/storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Helper method to create headers with token
  static Map<String, String> _createAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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
      final data = jsonDecode(response.body);
      // Store the token immediately after successful login
      if (data['success'] == true && data['token'] != null) {
        await StorageService.saveToken(data['token']);
      }
      return data;
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
      final data = jsonDecode(response.body);
      // Store the token immediately after successful login
      if (data['success'] == true && data['token'] != null) {
        await StorageService.saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await StorageService.getToken();
    
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/statistics/dashboard'),
      headers: _createAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get dashboard statistics: ${response.body}');
    }
  }

  static Future<List<Proprietaire>> getAllProprietaires() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/proprietaires'),
        headers: _createAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['proprietaires'] as List)
              .map((json) => Proprietaire.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to fetch proprietaires');
    } catch (e) {
      throw Exception('Error fetching proprietaires: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableApartments() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/appartements'),
        headers: _createAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final apartments = (data['appartements'] as List)
              .where((apt) => apt['proprietaireId'] == null)
              .map((apt) => Map<String, dynamic>.from(apt))
              .toList();
          return apartments;
        }
      }
      throw Exception('Failed to fetch apartments');
    } catch (e) {
      throw Exception('Error fetching apartments: $e');
    }
  }

  static Future<void> createProprietaire(Map<String, dynamic> proprietaireData) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/proprietaires'),
        headers: _createAuthHeaders(token),
        body: jsonEncode(proprietaireData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create proprietaire: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating proprietaire: $e');
    }
  }
}
