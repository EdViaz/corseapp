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

class _RacesScreenState extends State<RacesScreen>
    with SingleTickerProviderStateMixin {
  // Servizio per le chiamate API
  final ApiService _apiService = ApiService();
  // Future per i dati delle gare
  late Future<List<Race>> _racesFuture;
  // Controller per gestire le tab (Gare future e Gare passate)
  late TabController _tabController;

  int _selectedYear = DateTime.now().year;
  List<int> _availableYears = List.generate(10, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    // Inizializza il controller con 2 tab (Gare future e Gare passate)
    _tabController = TabController(length: 2, vsync: this);
    // Carica i dati delle gare all'avvio della schermata
    _racesFuture = _apiService.getRacesByYear(_selectedYear);
  }

  void _onYearChanged(int? year) {
    if (year == null) return;
    setState(() {
      _selectedYear = year;
      _racesFuture = _apiService.getRacesByYear(_selectedYear);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshRaces() async {
    setState(() {
      _racesFuture = _apiService.getRacesByYear(_selectedYear);
    });
    await _racesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con TabBar per navigare tra gare future e passate
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: Row(
          children: [
            const Text('Gare'),
            const Spacer(),
            DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: const SizedBox(),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
              items: _availableYears
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      ))
                  .toList(),
              onChanged: _onYearChanged,
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Prossime'), Tab(text: 'Passate')],
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
                  child: ListView.builder(
                    itemCount: upcomingRaces.length,
                    itemBuilder: (context, index) {
                      final race = upcomingRaces[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                        child: ListTile(
                          leading:
                              race.flagUrl.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      race.flagUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(Icons.flag, size: 40),
                          title: Text(
                            race.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(race.circuit),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        RaceDetailScreen(race: race),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Past Races Tab
                RefreshIndicator(
                  onRefresh: _refreshRaces,
                  child: ListView.builder(
                    itemCount: pastRaces.length,
                    itemBuilder: (context, index) {
                      final race = pastRaces[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                        child: ListTile(
                          leading:
                              race.flagUrl.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      race.flagUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(Icons.flag, size: 40),
                          title: Text(
                            race.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(race.circuit),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        RaceDetailScreen(race: race),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
