import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/f1_models.dart';
import '../models/driver_details.dart';
import '../services/preferences_service.dart';

class ApiService {
  // Base URL for the PHP API
  // For web browser testing, we need to use the correct URL format

  final String baseUrl = 'http://localhost/backend/api';

  //final String baseUrl = 'http://192.168.0.30/backend/api';

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
          List<Driver> drivers = data.map((json) => Driver.fromJson(json)).toList();
          
          // Ordina i piloti in base ai punti e vittorie (dal più alto al più basso)
          drivers.sort((a, b) {
            // Prima confronta i punti
            int pointsComparison = b.points.compareTo(a.points);
            // Se i punti sono uguali, confronta le vittorie
            if (pointsComparison == 0) {
              return b.victories.compareTo(a.victories);
            }
            return pointsComparison;
          });
          
          // Assegna la posizione in base all'ordinamento
          for (int i = 0; i < drivers.length; i++) {
            final driver = drivers[i];
            // Crea un nuovo oggetto Driver con la posizione aggiornata
            drivers[i] = Driver(
              id: driver.id,
              name: driver.name,
              team: driver.team,
              points: driver.points,
              imageUrl: driver.imageUrl,
              position: i + 1, // La posizione è l'indice + 1
              victories: driver.victories // Mantiene il numero di vittorie
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
          List<Constructor> constructors = data.map((json) => Constructor.fromJson(json)).toList();
          
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
              //victories: driver.victories // Mantiene il numero di vittorie
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
          driverData['biography'] = driverData['biography'] ?? 
              'Biografia del pilota. Questo è un testo di esempio che descrive la carriera e la vita del pilota.';
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
          
          // Correggi le URL delle immagini per Norris e Sainz
          if (driverId == 4) { // Lando Norris
            driverData['image_url'] = 'https://www.formula1.com/content/dam/fom-website/drivers/L/LANNOR01_Lando_Norris/lannor01.png.transform/2col/image.png';
          } else if (driverId == 55) { // Carlos Sainz
            driverData['image_url'] = 'https://www.formula1.com/content/dam/fom-website/drivers/C/CARSAI01_Carlos_Sainz/carsai01.png.transform/2col/image.png';
          }
          
          driverData['media_gallery'] = [
            'https://www.formula1.com/content/dam/fom-website/drivers/2023Drivers/leclerc.jpg.img.1920.medium.jpg',
            'https://www.formula1.com/content/dam/fom-website/manual/Misc/2019carlossainz/Monaco/sainz-monaco-2019-race.jpg.transform/9col/image.jpg',
            'https://www.formula1.com/content/dam/fom-website/sutton/2022/Italy/Sunday/1422823534.jpg.transform/9col/image.jpg',
            'https://www.formula1.com/content/dam/fom-website/sutton/2022/Italy/Sunday/1422823534.jpg.transform/9col/image.jpg',
          ];
          
          // Imposta lo stato dei preferiti
          driverData['is_favorite'] = isFavorite;

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
}
