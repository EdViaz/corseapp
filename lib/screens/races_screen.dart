import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';
import 'race_detail_screen.dart';

// Schermata che mostra il calendario delle gare di Formula 1
// Divisa in due tab: gare future e gare passate
// Visualizza informazioni dettagliate su ogni gara con immagini dei circuiti

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> with SingleTickerProviderStateMixin {
  // Servizio per le chiamate API
  final ApiService _apiService = ApiService();
  // Future per i dati delle gare
  late Future<List<Race>> _racesFuture;
  // Controller per gestire le tab (Gare future e Gare passate)
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller con 2 tab (Gare future e Gare passate)
    _tabController = TabController(length: 2, vsync: this);
    // Carica i dati delle gare all'avvio della schermata
    _racesFuture = _apiService.getRaces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshRaces() async {
    setState(() {
      _racesFuture = _apiService.getRaces();
    });
    await _racesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con TabBar per navigare tra gare future e passate
      appBar: AppBar(
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Prossime'),
            Tab(text: 'Passate'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: FutureBuilder<List<Race>>(
        future: _racesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Non ci sono gare disponibili'));
          } else {
            final races = snapshot.data!;
            final upcomingRaces = races.where((race) => !race.isPast).toList();
            final pastRaces = races.where((race) => race.isPast).toList();
            
            return TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Races Tab
                RefreshIndicator(
                  onRefresh: _refreshRaces,
                  child: _buildRacesList(upcomingRaces, isUpcoming: true),
                ),
                
                // Past Races Tab
                RefreshIndicator(
                  onRefresh: _refreshRaces,
                  child: _buildRacesList(pastRaces, isUpcoming: false),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRacesList(List<Race> races, {required bool isUpcoming}) {
    if (races.isEmpty) {
      return Center(
        child: Text(isUpcoming ? 'Nessuna gara futura disponibile' : 'Nessuna gara passata disponibile'),
      );
    }
    
    return ListView.builder(
      itemCount: races.length,
      itemBuilder: (context, index) {
        final race = races[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: race.flagUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      race.flagUrl,
                      width: 48,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.flag, size: 40);
                      },
                    ),
                  )
                : const Icon(Icons.flag, size: 40),
            title: Text(
              race.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(race.circuit),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${race.date.day}/${race.date.month}/${race.date.year}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.green : Colors.grey,
                  ),
                ),
                Text(race.country),
              ],
            ),
            onTap: () {
              // Naviga alla schermata di dettaglio gara
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceDetailScreen(race: race),
                ),
              );
            },
          ),
        );
      },
    );
  }
}