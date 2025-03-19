import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/f1_models.dart';

class ApiService {
  // Base URL for the PHP API
  // For web browser testing, we need to use the correct URL format

  //final String baseUrl = 'http://localhost/backend/api';

  final String baseUrl = 'http://192.168.0.30/backend/api';

  final bool debugMode = true;

  // Fetch news from the API
  Future<List<News>> getNews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news.php'));

      if (debugMode) {
        print('News API Response Status: ${response.statusCode}');
        print('News API Response Headers: ${response.headers}');
        print('News API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          // Check if response body is empty
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }

          // Try to decode the JSON
          List<dynamic> data = json.decode(response.body);
          return data.map((json) => News.fromJson(json)).toList();
        } catch (e) {
          // More detailed error message
          throw Exception(
            'Invalid JSON response: ${e.toString()}\nResponse body: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}',
          );
        }
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any network or other errors
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch drivers standings from the API
  Future<List<Driver>> getDriverStandings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/drivers.php'));

      if (debugMode) {
        print('Drivers API Response Status: ${response.statusCode}');
        print('Drivers API Response Headers: ${response.headers}');
        print('Drivers API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }

          List<dynamic> data = json.decode(response.body);
          return data.map((json) => Driver.fromJson(json)).toList();
        } catch (e) {
          throw Exception(
            'Invalid JSON response: ${e.toString()}\nResponse body: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}',
          );
        }
      } else {
        throw Exception(
          'Failed to load driver standings: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch constructors standings from the API
  Future<List<Constructor>> getConstructorStandings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/constructors.php'));

      if (debugMode) {
        print('Constructors API Response Status: ${response.statusCode}');
        print('Constructors API Response Headers: ${response.headers}');
        print('Constructors API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }

          List<dynamic> data = json.decode(response.body);
          return data.map((json) => Constructor.fromJson(json)).toList();
        } catch (e) {
          throw Exception(
            'Invalid JSON response: ${e.toString()}\nResponse body: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}',
          );
        }
      } else {
        throw Exception(
          'Failed to load constructor standings: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch race calendar from the API
  Future<List<Race>> getRaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/races.php'));

      if (debugMode) {
        print('Races API Response Status: ${response.statusCode}');
        print('Races API Response Headers: ${response.headers}');
        print('Races API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }

          List<dynamic> data = json.decode(response.body);
          return data.map((json) => Race.fromJson(json)).toList();
        } catch (e) {
          throw Exception(
            'Invalid JSON response: ${e.toString()}\nResponse body: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}',
          );
        }
      } else {
        throw Exception('Failed to load races: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
