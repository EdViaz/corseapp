import 'package:flutter/material.dart';
import '../models/f1_models.dart';

class ConstructorDetailScreen extends StatelessWidget {
  final Constructor constructor;
  const ConstructorDetailScreen({super.key, required this.constructor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Team'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          // HEADER stile pilota
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                if (constructor.logoUrl.isNotEmpty)
                  Hero(
                    tag: 'team-image-${constructor.id}',
                    child: CircleAvatar(
                      radius: 38,
                      backgroundImage: NetworkImage(constructor.logoUrl),
                      backgroundColor: Colors.white,
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        constructor.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Posizione: ${constructor.position} | Punti: ${constructor.points}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informazioni Team',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _infoRow('Nome', constructor.name),
                          _infoRow('Posizione', constructor.position.toString()),
                          _infoRow('Punti', constructor.points.toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Placeholder per statistiche o dettagli aggiuntivi
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Statistiche Team',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          Text('Statistiche dettagliate non disponibili.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
