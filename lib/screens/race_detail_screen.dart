import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';

class RaceDetailScreen extends StatefulWidget {
  final Race race;

  const RaceDetailScreen({Key? key, required this.race}) : super(key: key);

  @override
  _RaceDetailScreenState createState() => _RaceDetailScreenState();
}

class _RaceDetailScreenState extends State<RaceDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _raceDetails;

  @override
  void initState() {
    super.initState();
    _loadRaceDetails();
  }

  Future<void> _loadRaceDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In una implementazione reale, questo dovrebbe chiamare un metodo specifico
      // dell'API service per ottenere i dettagli della gara
      // Per ora, simuliamo alcuni dati di esempio
      await Future.delayed(const Duration(seconds: 1)); // Simula il caricamento
      
      setState(() {
        _raceDetails = {
          'circuitLength': '5.303 km',
          'laps': 53,
          'distance': '307.573 km',
          'lapRecord': {
            'time': '1:18.887',
            'driver': 'Max Verstappen',
            'year': 2021
          },
          'sessions': [
            {
              'name': 'Prove Libere 1',
              'date': DateTime.now().add(const Duration(days: -3)),
              'time': '14:30 - 15:30',
            },
            {
              'name': 'Prove Libere 2',
              'date': DateTime.now().add(const Duration(days: -3)),
              'time': '18:00 - 19:00',
            },
            {
              'name': 'Prove Libere 3',
              'date': DateTime.now().add(const Duration(days: -2)),
              'time': '13:30 - 14:30',
            },
            {
              'name': 'Qualifiche',
              'date': DateTime.now().add(const Duration(days: -2)),
              'time': '17:00 - 18:00',
            },
            {
              'name': 'Gara',
              'date': widget.race.date,
              'time': '15:00 - 17:00',
            },
          ],
          'results': widget.race.isPast ? [
            {'position': 1, 'driver': 'Max Verstappen', 'team': 'Red Bull Racing', 'time': '1:30:27.345'},
            {'position': 2, 'driver': 'Lewis Hamilton', 'team': 'Mercedes', 'time': '+5.856s'},
            {'position': 3, 'driver': 'Charles Leclerc', 'team': 'Ferrari', 'time': '+7.124s'},
          ] : null,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento dei dettagli: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.race.name),
        backgroundColor: Colors.red.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRaceDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRaceHeader(),
                      const SizedBox(height: 24),
                      _buildCircuitInfo(),
                      const SizedBox(height: 24),
                      _buildSessionsSchedule(),
                      if (widget.race.isPast && _raceDetails != null && _raceDetails!['results'] != null) ...[  
                        const SizedBox(height: 24),
                        _buildRaceResults(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRaceHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.race.flagUrl.isNotEmpty)
                  Image.network(
                    widget.race.flagUrl,
                    height: 30,
                    width: 45,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.flag, size: 30);
                    },
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.race.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Circuito: ${widget.race.circuit}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Paese: ${widget.race.country}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${widget.race.date.day}/${widget.race.date.month}/${widget.race.date.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.race.isPast ? 'Gara completata' : 'Gara futura',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.race.isPast ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircuitInfo() {
    if (_raceDetails == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informazioni Circuito',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _infoRow('Lunghezza', _raceDetails!['circuitLength']),
            _infoRow('Giri', _raceDetails!['laps'].toString()),
            _infoRow('Distanza totale', _raceDetails!['distance']),
            const SizedBox(height: 12),
            const Text(
              'Record del circuito:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoRow('Tempo', _raceDetails!['lapRecord']['time']),
            _infoRow('Pilota', _raceDetails!['lapRecord']['driver']),
            _infoRow('Anno', _raceDetails!['lapRecord']['year'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsSchedule() {
    if (_raceDetails == null || _raceDetails!['sessions'] == null) {
      return const SizedBox.shrink();
    }
    
    final sessions = _raceDetails!['sessions'] as List;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Programma del Weekend',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sessions.map((session) {
              final date = session['date'] as DateTime;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        session['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${date.day}/${date.month}/${date.year}'),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(session['time']),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRaceResults() {
    final results = _raceDetails!['results'] as List;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risultati della Gara',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(flex: 1, child: Text('Pos', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Pilota', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Tempo', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            ...results.map((result) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        result['position'].toString(),
                        style: TextStyle(
                          fontWeight: result['position'] <= 3 ? FontWeight.bold : FontWeight.normal,
                          color: result['position'] == 1 ? Colors.amber : null,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: Text(result['driver'])),
                    Expanded(flex: 3, child: Text(result['team'])),
                    Expanded(flex: 2, child: Text(result['time'])),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}