class Pilota {
  final String nome;
  final String cognome;
  final int punti;

  Pilota({required this.nome, required this.cognome, required this.punti});

  factory Pilota.fromJson(Map<String, dynamic> json) {
    return Pilota(
      nome: json['nome'],
      cognome: json['cognome'],
      punti: json['punti'],
    );
  }
}
