import 'dart:convert';
import 'package:corseapp/services/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';

class AuthService {

  //per far funzionare docker

  final String baseUrl = url;
  final bool debugMode = true;

  // Chiavi per memorizzare i dati nelle SharedPreferences
  static const String userKey = 'user_data';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  
  // Token attuale in memoria
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  // Registrazione utente
  Future<User> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {'username': username, 'password': password},
      );

      if (debugMode) {
        print('Register API Response Status: ${response.statusCode}');
        print('Register API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data['user']);
          
          // Salva i token JWT se presenti
          if (data['access_token'] != null) {
            await _saveTokens(
              data['access_token'],
              data['refresh_token'],
              data['expires_in'] ?? 3600,
            );
          }
          
          await _saveUserLocally(user);
          return user;
        } else {
          throw Exception(data['message'] ?? 'Registrazione fallita');
        }
      } else {
        throw Exception(
          'Errore durante la registrazione: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di rete: ${e.toString()}');
    }
  }
  // Login utente
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'username': username, 'password': password},
      );

      if (debugMode) {
        print('Login API Response Status: ${response.statusCode}');
        print('Login API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data['user']);
          
          // Salva i token JWT
          if (data['access_token'] != null) {
            await _saveTokens(
              data['access_token'],
              data['refresh_token'],
              data['expires_in'] ?? 3600,
            );
          }
          
          await _saveUserLocally(user);
          return user;
        } else {
          throw Exception(data['message'] ?? 'Login fallito');
        }
      } else {
        throw Exception('Errore durante il login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore di rete: ${e.toString()}');
    }
    throw Exception('Login fallito per un motivo sconosciuto');
  }
  // Logout utente
  Future<void> logout() async {
    try {
      // Chiama l'endpoint di logout se abbiamo un token valido
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$baseUrl/logout.php'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        );
      }
    } catch (e) {
      // Ignora errori di rete durante il logout
    } finally {
      // Pulisci sempre i dati locali
      await _clearAllTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userKey);
    }  }

  // === GESTIONE TOKEN JWT ===
  
  // Salva i token JWT nelle SharedPreferences
  Future<void> _saveTokens(String accessToken, String? refreshToken, int expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = expiry;
    
    await prefs.setString(accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }
    await prefs.setString(tokenExpiryKey, expiry.toIso8601String());
  }
  
  // Carica i token dalle SharedPreferences
  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(accessTokenKey);
    _refreshToken = prefs.getString(refreshTokenKey);
    
    final expiryStr = prefs.getString(tokenExpiryKey);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.parse(expiryStr);
    }
  }
  
  // Pulisce tutti i token
  Future<void> _clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(tokenExpiryKey);
  }
  
  // Verifica se il token è scaduto
  bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }
  
  // Ottiene il token di accesso valido (refresh automatico se necessario)
  Future<String?> getValidAccessToken() async {
    if (_accessToken == null) {
      await _loadTokens();
    }
    
    if (_accessToken != null && !_isTokenExpired()) {
      return _accessToken;
    }
    
    // Prova a fare refresh del token
    if (_refreshToken != null) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return _accessToken;
      }
    }
    
    return null;
  }
  
  // Refresh del token di accesso
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
          await _saveTokens(
            data['access_token'],
            data['refresh_token'] ?? _refreshToken,
            data['expires_in'] ?? 3600,
          );
          return true;
        }
      }
    } catch (e) {
      if (debugMode) {
        print('Error refreshing token: $e');
      }
    }
    
    // Se il refresh fallisce, pulisci i token
    await _clearAllTokens();
    return false;
  }

  // Verifica se l'utente è loggato
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  // Salva l'utente nelle SharedPreferences
  Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  // Ottieni i commenti per una notizia
  Future<List<Comment>> getComments(int newsId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments.php?news_id=$newsId'),
      );

      if (debugMode) {
        print('Comments API Response Status: ${response.statusCode}');
        print('Comments API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception(
          'Impossibile caricare i commenti: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di rete: ${e.toString()}');
    }
  }

  // Aggiungi un commento
  Future<Comment> addComment(int newsId, String content) async {
    try {
      // Ottieni un access token valido
      final token = await getValidAccessToken();
      if (token == null) {
        throw Exception('Devi effettuare il login per commentare');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add_comment.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'news_id': newsId.toString(),
          'content': content,
        },
      );

      if (debugMode) {
        print('Add Comment API Response Status: \\${response.statusCode}');
        print('Add Comment API Response Body: \\${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Comment.fromJson(data['comment']);
        } else {
          throw Exception(
            data['message'] ?? 'Impossibile aggiungere il commento',
          );
        }
      } else {
        throw Exception(
          'Errore durante l\'aggiunta del commento: \\${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di rete: \\${e.toString()}');
    }
  }
}
