// Models for user authentication and comments

class User {
  final int id;
  final String username;
  final String? password; // Non memorizzato localmente dopo l'autenticazione

  User({
    required this.id,
    required this.username,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      password: null, // Non memorizziamo la password localmente
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}

class Comment {
  final int id;
  final int newsId;
  final int userId;
  final String username;
  final String content;
  final DateTime date;

  Comment({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.username,
    required this.content,
    required this.date,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      newsId: json['news_id'] is int
          ? json['news_id']
          : int.tryParse(json['news_id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? 'Utente anonimo',
      content: json['content'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'news_id': newsId,
      'user_id': userId,
      'username': username,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}