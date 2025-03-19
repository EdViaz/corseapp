import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pilota.dart';

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
      appBar: AppBar(  title: Center(
          child: Image.asset("images/f1logo.png", width: 120),
        ),
        backgroundColor: Colors.red,
      ),
      body:
          classifica.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: classifica.length,
                itemBuilder: (context, index) {
                  final pilota = classifica[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Text("${pilota.nome} ${pilota.cognome}"),
                    subtitle: Text("Punti: ${pilota.punti}"),
                  );
                },
              ),
    );
  }
}
