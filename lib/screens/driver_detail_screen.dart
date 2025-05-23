import 'package:flutter/material.dart';
import '../models/driver_details.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';

// Schermata che mostra i dettagli completi di un pilota di Formula 1
// Visualizza informazioni personali, statistiche e contenuti multimediali
// organizzati in diverse tab per una migliore esperienza utente

class DriverDetailScreen extends StatefulWidget {
  final int driverId;

  const DriverDetailScreen({Key? key, required this.driverId})
    : super(key: key);

  @override
  _DriverDetailScreenState createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen>
    with SingleTickerProviderStateMixin {
  // Controller per gestire le tab (Profilo, Statistiche)
  late TabController _tabController;
  // Future per i dati dettagliati del pilota
  late Future<DriverDetails> _driverDetailsFuture;
  // Servizio per le chiamate API
  final ApiService _apiService = ApiService();
  // Servizio per la gestione delle preferenze
  final PreferencesService _preferencesService = PreferencesService();
  // Stato per indicare se il pilota è tra i preferiti
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller con 2 tab (Profilo, Statistiche)
    _tabController = TabController(length: 2, vsync: this);
    // Carica i dettagli del pilota all'avvio della schermata
    _loadDriverDetails();
  }

  // Carica i dettagli del pilota dal servizio API
  void _loadDriverDetails() {
    // Richiede i dettagli del pilota usando l'ID fornito
    _driverDetailsFuture = _apiService.getDriverDetails(widget.driverId);
    // Aggiorna lo stato dei preferiti quando i dati sono disponibili
    _driverDetailsFuture.then((details) {
      setState(() {
        _isFavorite = details.isFavorite;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Aggiunge o rimuove il pilota dai preferiti
  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      await _preferencesService.addFavoriteDriver(widget.driverId);
    } else {
      await _preferencesService.removeFavoriteDriver(widget.driverId);
    }
    // Non fare pop e push! Aggiorna solo lo stato locale.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Pilota'),
        backgroundColor: Colors.red,
        // RIMOSSO: pulsante dark mode
        // actions: [
        //   IconButton(
        //     icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
        //     onPressed: _toggleTheme,
        //   ),
        // ],
      ),
      body: FutureBuilder<DriverDetails>(
        future: _driverDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: [${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          final driver = snapshot.data!;
          return Column(
            children: [
              _buildDriverHeader(driver),
              TabBar(
                controller: _tabController,
                labelColor: Colors.red,
                tabs: const [
                  Tab(text: 'Profilo'),
                  Tab(text: 'Statistiche'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(driver),
                    _buildStatsTab(driver),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDriverHeader(DriverDetails driver) {
    return FutureBuilder<List<Constructor>>(
      future: ApiService().getConstructorStandings(),
      builder: (context, snapshot) {
        String teamName = '';
        if (snapshot.hasData) {
          final team = snapshot.data!.firstWhere(
            (c) => c.id == driver.teamId,
            orElse: () => Constructor(id: 0, name: '-', points: 0, logoUrl: '', position: 0),
          );
          teamName = team.name;
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          teamName = 'Caricamento...';
        } else {
          teamName = '-';
        }
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.red,
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(driver.imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${driver.name} ${driver.surname}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      teamName,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      'Posizione: ${driver.position} | Punti: ${driver.points}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(DriverDetails driver) {
    return FutureBuilder<List<Constructor>>(
      future: ApiService().getConstructorStandings(),
      builder: (context, snapshot) {
        String teamName = '';
        if (snapshot.hasData) {
          final team = snapshot.data!.firstWhere(
            (c) => c.id == driver.teamId,
            orElse: () => Constructor(id: 0, name: '-', points: 0, logoUrl: '', position: 0),
          );
          teamName = team.name;
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          teamName = 'Caricamento...';
        } else {
          teamName = '-';
        }
        return SingleChildScrollView(
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
                        'Informazioni Personali',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      _infoRow('Nazionalità', driver.nationality),
                      _infoRow('Numero', driver.number.toString()),
                      _infoRow('Team', teamName),
                      _infoRow('Posizione', driver.position.toString()),
                      _infoRow('Punti', driver.points.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biografia',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Text(driver.biography),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(DriverDetails driver) {
    return SingleChildScrollView(
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
                    'Statistiche Stagione',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildStatBar('Vittorie', driver.statistics['wins'] ?? 0, 20),
                  _buildStatBar('Podi', driver.statistics['podiums'] ?? 0, 30),
                  _buildStatBar(
                    'Pole Position',
                    driver.statistics['poles'] ?? 0,
                    20,
                  ),
                  _buildStatBar(
                    'Giri Veloci',
                    driver.statistics['fastestLaps'] ?? 0,
                    20,
                  ),
                  _buildStatBar('Punti', driver.points, 400),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confronto con il Compagno di Squadra',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildComparisonBar(
                    'Qualifiche',
                    driver.statistics['qualifyingWins'] ?? 0,
                    driver.statistics['teammateQualifyingWins'] ?? 0,
                  ),
                  _buildComparisonBar(
                    'Gare',
                    driver.statistics['raceWins'] ?? 0,
                    driver.statistics['teammateRaceWins'] ?? 0,
                  ),
                  _buildComparisonBar(
                    'Punti',
                    driver.points,
                    driver.statistics['teammatePoints'] ?? 0,
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

  Widget _buildStatBar(String label, int value, int maxValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text(value.toString())],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / maxValue,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String label, int driverValue, int teammateValue) {
    final total = driverValue + teammateValue;
    final driverRatio = total > 0 ? driverValue / total : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('$label: $driverValue'), Text('$teammateValue')],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: driverRatio,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
