import 'package:flutter/material.dart';
import '../models/f1_models.dart';

class ConstructorDetailScreen extends StatelessWidget {
  final Constructor constructor;
  const ConstructorDetailScreen({Key? key, required this.constructor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(constructor.name),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (constructor.logoUrl.isNotEmpty)
              Center(
                child: Image.network(
                  constructor.logoUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            const SizedBox(height: 16),
            Text('Punti: ${constructor.points}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Posizione: ${constructor.position}', style: const TextStyle(fontSize: 16)),
            // Qui puoi aggiungere altri dettagli del team se disponibili
          ],
        ),
      ),
    );
  }
}
