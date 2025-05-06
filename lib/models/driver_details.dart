class DriverDetails {
  final int id;
  final String name;
  final String team;
  final int points;
  final String imageUrl;
  final int position;
  final String nationality;
  final int number;
  final String biography;
  final Map<String, dynamic> statistics;
  final List<String> mediaGallery;
  final bool isFavorite;

  DriverDetails({
    required this.id,
    required this.name,
    required this.team,
    required this.points,
    required this.imageUrl,
    required this.position,
    required this.nationality,
    required this.number,
    required this.biography,
    required this.statistics,
    required this.mediaGallery,
    this.isFavorite = false,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
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
      nationality: json['nationality'] ?? '',
      number:
          json['number'] is int
              ? json['number']
              : int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      biography: json['biography'] ?? '',
      statistics: json['statistics'] ?? {},
      mediaGallery:
          (json['media_gallery'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  // Crea una copia dell'oggetto con modifiche
  DriverDetails copyWith({
    int? id,
    String? name,
    String? team,
    int? points,
    String? imageUrl,
    int? position,
    String? nationality,
    int? number,
    String? biography,
    Map<String, dynamic>? statistics,
    List<String>? mediaGallery,
    bool? isFavorite,
  }) {
    return DriverDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      team: team ?? this.team,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      position: position ?? this.position,
      nationality: nationality ?? this.nationality,
      number: number ?? this.number,
      biography: biography ?? this.biography,
      statistics: statistics ?? this.statistics,
      mediaGallery: mediaGallery ?? this.mediaGallery,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
