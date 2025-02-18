import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClassificaScreen extends StatefulWidget {
  @override
  _ClassificaScreenState createState() => _ClassificaScreenState();
}

class _ClassificaScreenState extends State<ClassificaScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> classifica = [];

  @override
  void initState() {
    super.initState();
    fetchClassifica();
  }

  Future<void> fetchClassifica() async {
    try {
      final data = await apiService.getClassifica();
      setState(() {
        classifica = data;
      });
    } catch (e) {
      print("Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Classifica Piloti")),
      body: classifica.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: classifica.length,
              itemBuilder: (context, index) {
                final pilota = classifica[index];
                return ListTile(
                  leading: CircleAvatar(child: Text("${index + 1}")),
                  title: Text("${pilota['nome']} ${pilota['cognome']}"),
                  subtitle: Text("Punti: ${pilota['punti']}"),
                );
              },
            ),
    );
  }
}
