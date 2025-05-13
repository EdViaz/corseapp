// Models for F1 app

import 'dart:convert';

class News {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime publishDate;
  final List<String> additionalImages;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishDate,
    required this.additionalImages,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    List<String> parseAdditionalImages(dynamic images) {
      if (images == null) return [];
      if (images is List) return images.map((e) => e.toString()).toList();
      if (images is String) {
        if (images.isEmpty) return [];
        try {
          final parsed = jsonDecode(images);
          if (parsed is List) return parsed.map((e) => e.toString()).toList();
          return [];
        } catch (_) {
          return [images]; // Se non è JSON, considera come singola immagine
        }
      }
      return [];
    }
    
    return News(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? '',
      publishDate: DateTime.tryParse(json['publish_date'] ?? '') ?? DateTime.now(),
      additionalImages: parseAdditionalImages(json['additional_images']),
    );
  }
}

class Driver {
  final int id;
  final String name;
  final String surname;
  final String team;
  final int points;
  final String imageUrl;
  final int position;
  final int victories; // Numero di vittorie per gestire i casi di parità

  Driver({
    required this.id,
    required this.name,
    required this.surname,
    required this.team,
    required this.points,
    required this.imageUrl,
    required this.position,
    this.victories = 0, // Valore predefinito a 0
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      team: json['team'] ?? '',
      points:
          json['points'] is int
              ? json['points']
              : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'] ?? '',
      position:
          json['position'] is int
              ? json['position']
              : int.tryParse(json['position']?.toString() ?? '0') ?? 0,
      victories:
          json['victories'] is int
              ? json['victories']
              : int.tryParse(json['victories']?.toString() ?? '0') ?? 0,
    );
  }
}

class Constructor {
  final int id;
  final String name;
  final int points;
  final String logoUrl;
  final int position;

  Constructor({
    required this.id,
    required this.name,
    required this.points,
    required this.logoUrl,
    required this.position,
  });

  factory Constructor.fromJson(Map<String, dynamic> json) {
    return Constructor(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      points:
          json['points'] is int
              ? json['points']
              : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      logoUrl: json['logo_url'] ?? '',
      position:
          json['position'] is int
              ? json['position']
              : int.tryParse(json['position']?.toString() ?? '0') ?? 0,
    );
  }


}

class Race {
  final int id;
  final String name;
  final String circuit;
  final DateTime date;
  final String country;
  final String flagUrl;
  final bool isPast;

  Race({
    required this.id,
    required this.name,
    required this.circuit,
    required this.date,
    required this.country,
    required this.flagUrl,
    required this.isPast,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      circuit: json['circuit'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      country: json['country'] ?? '',
      flagUrl: json['flag_url'] ?? '',
      isPast: json['is_past'] == 1,
    );
  }
}
