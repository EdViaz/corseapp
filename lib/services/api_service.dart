import 'dart:convert';
import 'package:corseapp/services/config.dart';
import 'package:http/http.dart' as http;
import '../models/f1_models.dart';
import '../models/driver_details.dart';
import '../services/preferences_service.dart';
import '../models/user_models.dart';

class ApiService {
  // Base URL for the PHP API
  // For web browser testing, we need to use the correct URL format

  //per far funzionare docker
  final String baseUrl = url;


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
          List<Driver> drivers =
              data.map((json) => Driver.fromJson(json)).toList();

          // Ordina i piloti in base ai punti (dal più alto al più basso)
          drivers.sort((a, b) => b.points.compareTo(a.points));

          // Assegna la posizione in base all'ordinamento
          for (int i = 0; i < drivers.length; i++) {
            final driver = drivers[i];
            // Crea un nuovo oggetto Driver con la posizione aggiornata
            drivers[i] = Driver(
              id: driver.id,
              name: driver.name,
              surname: driver.surname,
              teamId: driver.teamId, // Cambiato da team a teamId
              points: driver.points,
              imageUrl: driver.imageUrl,
              position: i + 1, // La posizione è l'indice + 1
              victories: driver.victories,
              nationality: driver.nationality,
              number: driver.number,
            );
          }

          return drivers;
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

  // Recupera i commenti di un utente specifico
  Future<List<Comment>> getUserComments(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user_comments.php?user_id=$userId'));

      if (debugMode) {
        print('User Comments API Response Status: ${response.statusCode}');
        print('User Comments API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            return []; // Restituisce una lista vuota se non ci sono commenti
          }

          List<dynamic> data = json.decode(response.body);
          return data.map((json) => Comment.fromJson(json)).toList();
        } catch (e) {
          throw Exception(
            'Risposta JSON non valida: ${e.toString()}\nCorpo della risposta: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}',
          );
        }
      } else {
        throw Exception(
          'Impossibile caricare i commenti dell\'utente: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di rete: ${e.toString()}');
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
          List<Constructor> constructors =
              data.map((json) => Constructor.fromJson(json)).toList();

          // Ordina i team in base ai punti (dal più alto al più basso)
          constructors.sort((a, b) => b.points.compareTo(a.points));

          // Assegna la posizione in base all'ordinamento
          for (int i = 0; i < constructors.length; i++) {
            final constructor = constructors[i];
            // Crea un nuovo oggetto Constructor con la posizione aggiornata
            constructors[i] = Constructor(
              id: constructor.id,
              name: constructor.name,
              points: constructor.points,
              logoUrl: constructor.logoUrl,
              position: i + 1, // La posizione è l'indice + 1
            );
          }

          return constructors;
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

  // Fetch detailed driver information
  Future<DriverDetails> getDriverDetails(int driverId) async {
    try {
      // Ottieni lo stato dei preferiti
      final preferencesService = PreferencesService();
      final isFavorite = await preferencesService.isDriverFavorite(driverId);

      // In una implementazione reale, questo endpoint dovrebbe esistere nel backend
      final response = await http.get(
        Uri.parse('$baseUrl/drivers.php?id=$driverId'),
      );

      if (debugMode) {
        print('Driver Details API Response Status: ${response.statusCode}');
        print('Driver Details API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }

          // Poiché l'API attuale potrebbe non supportare dettagli avanzati,
          // creiamo dati di esempio per la dimostrazione
          List<dynamic> data = json.decode(response.body);
          var driverData = data.firstWhere(
            (driver) =>
                driver['id'] == driverId ||
                int.parse(driver['id'].toString()) == driverId,
            orElse: () => throw Exception('Driver not found'),
          );

          // Aggiungiamo dati fittizi per la dimostrazione
          driverData['nationality'] = driverData['nationality'] ?? 'Italia';
          driverData['number'] = driverData['number'] ?? 16;
          driverData['biography'] = driverData['description'] ?? driverData['biography'] ?? '';
          driverData['statistics'] = {
            'wins': 5,
            'podiums': 15,
            'poles': 8,
            'fastestLaps': 7,
            'qualifyingWins': 12,
            'teammateQualifyingWins': 8,
            'raceWins': 14,
            'teammateRaceWins': 6,
            'teammatePoints': 120,
          };

          driverData['media_gallery'] = [
            'https://www.formula1.com/content/dam/fom-website/drivers/2023Drivers/leclerc.jpg.img.1920.medium.jpg',
            'https://www.formula1.com/content/dam/fom-website/manual/Misc/2019carlossainz/Monaco/sainz-monaco-2019-race.jpg.transform/9col/image.jpg',
            'https://www.formula1.com/content/dam/fom-website/sutton/2022/Italy/Sunday/1422823534.jpg.transform/9col/image.jpg',
            'https://www.formula1.com/content/dam/fom-website/sutton/2022/Italy/Sunday/1422823534.jpg.transform/9col/image.jpg',
          ];

          // Imposta lo stato dei preferiti
          driverData['is_favorite'] = isFavorite;

          // Adatta il campo team_id per DriverDetails
          driverData['team_id'] = driverData['team_id'] is int ? driverData['team_id'] : int.tryParse(driverData['team_id']?.toString() ?? '0') ?? 0;

          return DriverDetails.fromJson(driverData);
        } catch (e) {
          throw Exception(
            'Invalid JSON response or driver not found: ${e.toString()}',
          );
        }
      } else {
        throw Exception(
          'Failed to load driver details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Recupera una notizia tramite il suo id
  Future<News?> getNewsById(int newsId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news.php'));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        List<dynamic> data = json.decode(response.body);
        final newsJson = data.firstWhere(
          (n) => n['id'] == newsId || int.tryParse(n['id'].toString()) == newsId,
          orElse: () => null,
        );
        if (newsJson == null) return null;
        return News.fromJson(newsJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
