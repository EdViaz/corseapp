import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';
import 'driver_detail_screen.dart';

// Schermata che mostra le classifiche di Formula 1
// Contiene due tab: una per i piloti e una per i costruttori
// Permette di visualizzare le classifiche aggiornate e navigare ai dettagli dei piloti

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen>
    with SingleTickerProviderStateMixin {
  // Servizio per le chiamate API
  final ApiService _apiService = ApiService();
  // Controller per gestire le tab Piloti e Costruttori
  late TabController _tabController;
  // Future per i dati dei piloti e costruttori
  late Future<List<Driver>> _driversFuture;
  late Future<List<Constructor>> _constructorsFuture;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller con 2 tab (Piloti e Costruttori)
    _tabController = TabController(length: 2, vsync: this);
    // Carica i dati delle classifiche all'avvio della schermata
    _driversFuture = _apiService.getDriverStandings();
    _constructorsFuture = _apiService.getConstructorStandings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshStandings() async {
    setState(() {
      _driversFuture = _apiService.getDriverStandings();
      _constructorsFuture = _apiService.getConstructorStandings();
    });
    await Future.wait([
      _driversFuture,
      _constructorsFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con titolo e TabBar per navigare tra le classifiche
      appBar: AppBar(
        title: const Text('F1 Standings'),
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Drivers'), Tab(text: 'Constructors')],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      // Corpo della schermata con due tab per piloti e costruttori
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Piloti - Mostra la classifica piloti
          // FutureBuilder gestisce lo stato di caricamento dei dati dei piloti
          RefreshIndicator(
            onRefresh: _refreshStandings,
            child: FutureBuilder<List<Driver>>(
              future: _driversFuture,
              builder: (context, snapshot) {
                // Mostra indicatore di caricamento mentre i dati vengono recuperati
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Gestisce eventuali errori durante il recupero dei dati
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Gestisce il caso in cui non ci siano dati disponibili
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No driver standings available'),
                  );
                }
                // Costruisce la lista dei piloti quando i dati sono disponibili
                else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final driver = snapshot.data![index];
                      // Card per ogni pilota nella classifica
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        // InkWell per rendere l'intera card cliccabile
                        child: InkWell(
                          // Naviga alla schermata di dettaglio quando si tocca un pilota
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                      DriverDetailScreen(driverId: driver.id),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${driver.position}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(driver.imageUrl),
                                ),
                              ],
                            ),
                            title: Text(driver.name + " " + driver.surname),
                            subtitle: Text(driver.team),
                            trailing: Text(
                              '${driver.points} pts',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

          // Constructors Tab
          RefreshIndicator(
            onRefresh: _refreshStandings,
            child: FutureBuilder<List<Constructor>>(
              future: _constructorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No constructor standings available'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final constructor = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            // Qui si potrebbe aggiungere una schermata di dettaglio del team in futuro
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Team: ${constructor.name}'),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${constructor.position}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    constructor.logoUrl,
                                  ),
                                ),
                              ],
                            ),
                            title: Text(constructor.name),
                            trailing: Text(
                              '${constructor.points} pts',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
