import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pilota.dart';
import '../models/f1_models.dart';
import 'driver_detail_screen.dart';

class ClassificaScreen extends StatefulWidget {
  @override
  _ClassificaScreenState createState() => _ClassificaScreenState();
}

class _ClassificaScreenState extends State<ClassificaScreen> {
  final ApiService apiService = ApiService();
  List<Pilota> classifica = [];

  @override
  void initState() {
    super.initState();
    fetchClassifica();
  }

  Future<void> fetchClassifica() async {
    try {
      final data = await apiService.getDriverStandings();
      final piloti =
          data
              .map(
                (driver) => Pilota(
                  nome: driver.name.split(' ').first,
                  cognome: driver.name.split(' ').last,
                  punti: driver.points,
                ),
              )
              .toList();
      setState(() {
        classifica = piloti;
      });
    } catch (e) {
      print("Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Image.asset("images/f1logo.png", width: 120)),
        backgroundColor: Colors.red,
      ),
      body:
          classifica.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: classifica.length,
                itemBuilder: (context, index) {
                  final pilota = classifica[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      title: Text(
                        '${pilota.nome} ${pilota.cognome}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Punti: ${pilota.punti}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Recupera l'ID del pilota dalla lista originale di Driver
                          // Questo è un esempio, in un'implementazione reale dovresti
                          // avere un modo più diretto per ottenere l'ID
                          apiService.getDriverStandings().then((drivers) {
                            final matchingDriver = drivers.firstWhere(
                              (driver) => driver.name.contains(pilota.cognome),
                              orElse:
                                  () =>
                                      drivers[index], // Fallback all'indice corrente
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DriverDetailScreen(
                                      driverId: matchingDriver.id,
                                    ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
