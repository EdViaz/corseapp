import 'dart:convert';
import 'package:corseapp/services/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/f1_models.dart';

class AdminService {
  // Base URL for the PHP API
  final String baseUrl = url;

  // Store the JWT tokens after login
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  
  String? get accessToken => _accessToken;
  
  // Token storage keys
  static const String _accessTokenKey = 'admin_access_token';
  static const String _refreshTokenKey = 'admin_refresh_token';
  static const String _tokenExpiryKey = 'admin_token_expiry';
  
  // Constructor - load tokens from storage
  AdminService() {
    _loadTokensFromStorage();
  }
  
  // Load tokens from SharedPreferences
  Future<void> _loadTokensFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.parse(expiryStr);
    }
  }
  
  // Save tokens to SharedPreferences
  Future<void> _saveTokensToStorage(String accessToken, String? refreshToken, int expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = expiry;
    
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }
  
  // Check if token is expired
  bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(Duration(minutes: 5))); // 5 min buffer
  }
  
  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh_token.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': _refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _saveTokensToStorage(
            data['access_token'],
            data['refresh_token'] ?? _refreshToken,
            data['expires_in'] ?? 3600,
          );
          return true;
        }
      }
    } catch (e) {
      print('Error refreshing admin token: $e');
    }
    
    // Se il refresh fallisce, pulisci i token
    await _clearTokens();
    return false;
  }
  
  // Get valid access token
  Future<String?> _getValidAccessToken() async {
    if (_accessToken == null) return null;
    
    if (_isTokenExpired()) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) return null;
    }
    
    return _accessToken;
  }
  
  // Clear all tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
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
        // Save JWT tokens
        await _saveTokensToStorage(
          data['access_token'],
          data['refresh_token'],
          data['expires_in'] ?? 3600,
        );
        
        return {
          'success': true,
          'message': data['message'],
          'username': data['user']['username'],
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Call logout endpoint if we have a valid token
      final token = await _getValidAccessToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout.php'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Ignore network errors during logout
    } finally {
      // Always clear local tokens
      await _clearTokens();
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _accessToken != null && !_isTokenExpired();
  }

  // Ensure token is loaded (useful when app starts)
  Future<bool> ensureLoggedIn() async {
    if (_accessToken == null) {
      await _loadTokensFromStorage();
    }
    return isLoggedIn();
  }

  // CRUD operations for News
  Future<Map<String, dynamic>> createOrUpdateNews(News news) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'news',
          'action': news.id > 0 ? 'update' : 'create',
          if (news.id > 0) 'id': news.id,
          'title': news.title,
          'content': news.content,
          'image_url': news.imageUrl,
          'publish_date': news.publishDate.toIso8601String(),
          'additional_images': news.additionalImages,
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

  // Delete News
  Future<Map<String, dynamic>> deleteNews(int id) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'news',
          'action': 'delete',
          'id': id,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
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
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'drivers',
          'action': driver.id > 0 ? 'update' : 'create',
          if (driver.id > 0) 'id': driver.id,
          'name': driver.name,
          'surname': driver.surname,
          'team_id': driver.teamId,
          'points': driver.points,
          'image_url': driver.imageUrl,
          'position': driver.position,
          'nationality': driver.nationality,
          'number': driver.number,
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

  // Delete Driver
  Future<Map<String, dynamic>> deleteDriver(int id) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'drivers',
          'action': 'delete',
          'id': id,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
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
  Future<Map<String, dynamic>> createOrUpdateConstructor(Constructor constructor) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'constructors',
          'action': constructor.id > 0 ? 'update' : 'create',
          if (constructor.id > 0) 'id': constructor.id,
          'name': constructor.name,
          'points': constructor.points,
          'logo_url': constructor.logoUrl,
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

  // Delete Constructor
  Future<Map<String, dynamic>> deleteConstructor(int id) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'constructors',
          'action': 'delete',
          'id': id,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
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
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'races',
          'action': race.id > 0 ? 'update' : 'create',
          if (race.id > 0) 'id': race.id,
          'name': race.name,
          'circuit': race.circuit,
          'date': race.date.toIso8601String().split('T')[0],
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

  // Delete Race
  Future<Map<String, dynamic>> deleteRace(int id) async {
    final token = await _getValidAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entity_type': 'races',
          'action': 'delete',
          'id': id,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
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
