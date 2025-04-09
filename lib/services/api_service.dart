import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proprietaire.dart';
import '../models/reunion.dart';
import '../services/storage_service.dart';
import '../models/invited_proprietaire.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Helper method to create headers with token
  static Map<String, String> _createAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _createAuthHeaders(token),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Request failed');
      }

      return data;
    } catch (e) {
      throw Exception('Error making GET request: $e');
    }
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/proprietaire/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Make sure to store the proprietaire token
        if (data['token'] != null) {
          print('Saving proprietaire token: ${data['token']}'); // Debug log
          await StorageService.saveToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
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
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['proprietaires'] as List)
              .map((prop) => Proprietaire.fromJson(prop))
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to fetch proprietaires');
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
          return (data['appartements'] as List)
              .map((apt) => Map<String, dynamic>.from(apt))
              .toList();
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

  static Future<void> deleteProprietaire(String proprietaireId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/proprietaires/$proprietaireId'),
        headers: _createAuthHeaders(token),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete proprietaire');
      }
    } catch (e) {
      throw Exception('Error deleting proprietaire: $e');
    }
  }

  static Future<Proprietaire> updateProprietaire(String proprietaireId, Map<String, dynamic> updateData) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/proprietaires/$proprietaireId'),
        headers: _createAuthHeaders(token),
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Proprietaire.fromJson(data['proprietaire']);
        }
        throw Exception(data['message'] ?? 'Failed to update proprietaire');
      }
      throw Exception('Failed to update proprietaire');
    } catch (e) {
      throw Exception('Error updating proprietaire: $e');
    }
  }

  static Future<List<Reunion>> getMyReunions() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reunions'),
        headers: _createAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['reunions'] as List)
              .map((reunion) => Reunion.fromJson(reunion))
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to fetch reunions');
      }
      throw Exception('Failed to fetch reunions');
    } catch (e) {
      throw Exception('Error fetching reunions: $e');
    }
  }

  static Future<Reunion> createReunion(Map<String, dynamic> reunionData) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reunions'),
        headers: _createAuthHeaders(token),
        body: jsonEncode(reunionData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Reunion.fromJson(data['reunion']);
        }
        throw Exception(data['message'] ?? 'Failed to create reunion');
      }
      throw Exception('Failed to create reunion');
    } catch (e) {
      throw Exception('Error creating reunion: $e');
    }
  }

  static Future<void> inviteToReunion(String reunionId, List<String> proprietaireIds) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reunions/$reunionId/invite'),
        headers: _createAuthHeaders(token),
        body: jsonEncode({
          'proprietaireIds': proprietaireIds,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to invite proprietaires');
      }
    } catch (e) {
      throw Exception('Error inviting proprietaires: $e');
    }
  }

  static Future<List<InvitedProprietaire>> getReunionInvitees(String reunionId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reunions/$reunionId/invited'),
        headers: _createAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['invitedProprietaires'] as List)
              .map((prop) => InvitedProprietaire.fromJson(prop))
              .toList();
        }
        throw Exception(data['message'] ?? 'Failed to fetch invited proprietaires');
      }
      throw Exception('Failed to fetch invited proprietaires');
    } catch (e) {
      throw Exception('Error fetching invited proprietaires: $e');
    }
  }

  static Future<void> updateAttendance(String reunionId, String proprietaireId, String attendance) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/reunions/$reunionId/attendance/$proprietaireId'),
        headers: _createAuthHeaders(token),
        body: jsonEncode({
          'attendance': attendance,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update attendance');
      }
    } catch (e) {
      throw Exception('Error updating attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> createCharge(Map<String, dynamic> chargeData) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/charges'),
        headers: _createAuthHeaders(token),
        body: jsonEncode(chargeData),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to create charge');
      }

      return data;
    } catch (e) {
      throw Exception('Error creating charge: $e');
    }
  }

  static Future<void> confirmPayment(String paymentId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/payments/$paymentId/confirm'),
        headers: _createAuthHeaders(token),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to confirm payment');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }

  static Future<Proprietaire> getProprietaireProfile() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Using token for profile request: $token'); // Debug log

      final response = await http.get(
        Uri.parse('$baseUrl/proprietaires/profile/update'), // Updated endpoint
        headers: _createAuthHeaders(token),
      );

      print('Profile response status: ${response.statusCode}'); // Debug log
      print('Profile response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // The proprietaire data is now directly under the 'proprietaire' key
          return Proprietaire.fromJson(data['proprietaire']);
        }
        throw Exception(data['message'] ?? 'Failed to fetch proprietaire profile');
      }
      throw Exception('Failed to fetch proprietaire profile: ${response.body}');
    } catch (e) {
      throw Exception('Error fetching proprietaire profile: $e');
    }
  }

  static Future<Proprietaire> updateProprietaireProfile(Map<String, dynamic> updateData) async {
    try {
      final token = await StorageService.getToken();
      final userRole = await StorageService.getUserRole();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      if (userRole != 'proprietaire') {
        throw Exception('Only proprietaires can update their profile');
      }

      final response = await http.put( // Changed from POST to PUT
        Uri.parse('$baseUrl/proprietaires/profile/update'),
        headers: _createAuthHeaders(token),
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Proprietaire.fromJson(data['proprietaire']);
        }
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
      throw Exception('Failed to update profile: ${response.body}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
