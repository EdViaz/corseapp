import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';
import 'driver_detail_screen.dart';

class ConstructorDetailScreen extends StatefulWidget {
  final Constructor constructor;
  const ConstructorDetailScreen({super.key, required this.constructor});

  @override
  State<ConstructorDetailScreen> createState() =>
      _ConstructorDetailScreenState();
}

class _ConstructorDetailScreenState extends State<ConstructorDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Driver>> _teamDriversFuture;

  @override
  void initState() {
    super.initState();
    _teamDriversFuture = _apiService.getDriversByTeamId(widget.constructor.id);
  }

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
                if (widget.constructor.logoUrl.isNotEmpty)
                  Hero(
                    tag: 'team-image-${widget.constructor.id}',
                    child: CircleAvatar(
                      radius: 38,
                      backgroundImage: NetworkImage(widget.constructor.logoUrl),
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
                        widget.constructor.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder:
                            (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                        child: Text(
                          'Punti: ${widget.constructor.points}',
                          key: ValueKey(widget.constructor.points),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
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
                          _infoRow('Nome', widget.constructor.name),
                          _infoRow(
                            'Punti',
                            widget.constructor.points.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Piloti della scuderia
                  const Text(
                    'Piloti della Scuderia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Driver>>(
                    future: _teamDriversFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Errore nel caricamento piloti: ${snapshot.error}',
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nessun pilota disponibile per questa scuderia',
                          ),
                        );
                      } else {
                        final drivers = snapshot.data!;
                        return Column(
                          children:
                              drivers
                                  .map((driver) => _buildDriverCard(driver))
                                  .toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverDetailScreen(driverId: driver.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: 'driver-image-${driver.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(driver.imageUrl),
                  backgroundColor: Colors.grey[300],
                  onBackgroundImageError: (_, __) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${driver.name} ${driver.surname}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Numero: ${driver.number}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nazionalità: ${driver.nationality}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'P${driver.position}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${driver.points} pts',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
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
