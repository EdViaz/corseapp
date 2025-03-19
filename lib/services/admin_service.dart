import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/f1_models.dart';

class AdminService {
  // Base URL for the PHP API
  final String baseUrl = 'http://192.168.0.30/backend/api';

  // Store the auth token after login
  String? _authToken;
  String? get authToken => _authToken;
  
  // Token storage keys
  static const String _tokenKey = 'auth_token';
  
  // Constructor - load token from storage
  AdminService() {
    _loadTokenFromStorage();
  }
  
  // Load token from SharedPreferences
  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _authToken = data['token'];
        // Save token to SharedPreferences
        await _saveTokenToStorage(_authToken!);
        return {
          'success': true,
          'message': data['message'],
          'username': data['username'],
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
  
  // Save token to SharedPreferences
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Logout method
  Future<void> logout() async {
    _authToken = null;
    // Clear token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _authToken != null;
  }
  
  // Ensure token is loaded (useful when app starts)
  Future<bool> ensureLoggedIn() async {
    if (_authToken == null) {
      await _loadTokenFromStorage();
    }
    return isLoggedIn();
  }

  // CRUD operations for News
  Future<Map<String, dynamic>> createOrUpdateNews(News news) async {
    if (!isLoggedIn()) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_update_news.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          if (news.id > 0) 'id': news.id,
          'title': news.title,
          'content': news.content,
          'image_url': news.imageUrl,
          'publish_date': news.publishDate.toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Operation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // CRUD operations for Drivers
  Future<Map<String, dynamic>> createOrUpdateDriver(Driver driver) async {
    if (!isLoggedIn()) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_update_drivers.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          if (driver.id > 0) 'id': driver.id,
          'name': driver.name,
          'team': driver.team,
          'points': driver.points,
          'image_url': driver.imageUrl,
          'position': driver.position,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Operation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // CRUD operations for Constructors
  Future<Map<String, dynamic>> createOrUpdateConstructor(
    Constructor constructor,
  ) async {
    if (!isLoggedIn()) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_update_constructors.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          if (constructor.id > 0) 'id': constructor.id,
          'name': constructor.name,
          'points': constructor.points,
          'logo_url': constructor.logoUrl,
          'position': constructor.position,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Operation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // CRUD operations for Races
  Future<Map<String, dynamic>> createOrUpdateRace(Race race) async {
    if (!isLoggedIn()) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_update_races.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          if (race.id > 0) 'id': race.id,
          'name': race.name,
          'circuit': race.circuit,
          'date':
              race.date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
          'country': race.country,
          'flag_url': race.flagUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Operation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
