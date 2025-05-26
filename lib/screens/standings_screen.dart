import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';
import 'driver_detail_screen.dart';
import 'constructor_detail_screen.dart';

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
    await Future.wait([_driversFuture, _constructorsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con titolo e TabBar per navigare tra le classifiche
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Piloti'), Tab(text: 'Team')],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      // Corpo della schermata con due tab per piloti e costruttori
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Piloti
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
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }
                // Gestisce il caso in cui non ci siano dati disponibili
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessun pilota disponibile'));
                }
                // Costruisce la lista dei piloti quando i dati sono disponibili
                else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final driver = snapshot.data![index];
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
                          leading: Hero(
                            tag: 'driver-image-${driver.id}',
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(driver.imageUrl),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${driver.name} ${driver.surname}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Punti: ${driver.points}'),
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
                                        DriverDetailScreen(driverId: driver.id),
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
                  );
                }
              },
            ),
          ),
          // Tab Team
          RefreshIndicator(
            onRefresh: _refreshStandings,
            child: FutureBuilder<List<Constructor>>(
              future: _constructorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessun team disponibile'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final constructor = snapshot.data![index];
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
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(constructor.logoUrl),
                            backgroundColor: Colors.white,
                          ),
                          title: Text(
                            constructor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Punti: ${constructor.points}'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    ConstructorDetailScreen(constructor: constructor),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
