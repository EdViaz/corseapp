import 'dart:convert';
import 'package:corseapp/services/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';

class AuthService {

  //per far funzionare docker

  final String baseUrl = url;
  final bool debugMode = true;

  // Chiave per memorizzare l'utente nelle SharedPreferences
  static const String userKey = 'user_data';

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
  }

  // Logout utente
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
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
      // Ottieni l'utente corrente
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Devi effettuare il login per commentare');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add_comment.php'),
        body: {
          'news_id': newsId.toString(),
          'user_id': currentUser.id.toString(),
          'content': content,
        },
      );

      if (debugMode) {
        print('Add Comment API Response Status: ${response.statusCode}');
        print('Add Comment API Response Body: ${response.body}');
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
          'Errore durante l\'aggiunta del commento: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di rete: ${e.toString()}');
    }
  }
}
