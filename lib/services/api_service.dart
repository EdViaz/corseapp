import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pilota.dart';

class ApiService {
  static const String url = "";

  Future<List<Pilota>> getClassifica() async {
    final response = await http.get(Uri.parse("$url/classifica"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pilota.fromJson(json)).toList();
    } else {
      throw Exception("Errore nel caricamento della classifica");
    }
  }
}
