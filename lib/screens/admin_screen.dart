import 'dart:convert';

import 'package:corseapp/services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/f1_models.dart';
import '../services/api_service.dart';
import 'constructor_detail_screen.dart';
import 'race_detail_screen.dart';
import 'driver_detail_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final String baseUrl = url; 

  // Token di autorizzazione per le chiamate API admin
  final String authToken =
      'your_auth_token_here'; // In un'app reale, questo dovrebbe essere ottenuto tramite login

  // Futures per caricare i dati
  late Future<List<Driver>> _driversFuture;
  late Future<List<Constructor>> _constructorsFuture;
  late Future<List<News>> _newsFuture;
  late Future<List<Race>> _racesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _driversFuture = _apiService.getDriverStandings();
      _constructorsFuture = _apiService.getConstructorStandings();
      _newsFuture = _apiService.getNews();
      _racesFuture = _apiService.getRaces();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pannello Amministratore'),
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Piloti'),
            Tab(text: 'Team'),
            Tab(text: 'Notizie'),
            Tab(text: 'Gare'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Aggiorna dati',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDriversTab(),
          _buildConstructorsTab(),
          _buildNewsTab(),
          _buildRacesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentTab = _tabController.index;
          if (currentTab == 0) {
            _showDriverForm();
          } else if (currentTab == 1) {
            _showConstructorForm();
          } else if (currentTab == 2) {
            _showNewsForm();
          } else if (currentTab == 3) {
            _showRaceForm();
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Tab Piloti
  Widget _buildDriversTab() {
    return FutureBuilder<List<Driver>>(
      future: _driversFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessun pilota disponibile'));
        } else {
          return FutureBuilder<List<Constructor>>(
            future: _constructorsFuture,
            builder: (context, teamSnapshot) {
              final constructors = teamSnapshot.data ?? [];
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final driver = snapshot.data![index];
                  final team = constructors.firstWhere(
                    (c) => c.id == driver.teamId,
                    orElse: () => Constructor(id: 0, name: '-', points: 0, logoUrl: '', position: 0),
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(driver.imageUrl),
                      ),
                      title: Text('${driver.name} ${driver.surname}'),
                      subtitle: Text('${team.name} - ${driver.points} punti'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriverDetailScreen(driverId: driver.id),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showDriverForm(driver: driver),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => _showDeleteConfirmation(
                                  context,
                                  'pilota',
                                  () async {
                                    // Chiamata API per eliminare il pilota
                                    final response = await http.post(
                                      Uri.parse('$baseUrl/admin_api.php'),
                                      body: jsonEncode({
                                        "entity_type": "drivers",
                                        "action": "delete",
                                        "id": driver.id,
                                      }),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $authToken',
                                      },
                                    );

                                    if (response.statusCode == 200) {
                                      final data = jsonDecode(response.body);
                                      if (data['success']) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Pilota eliminato con successo',
                                            ),
                                          ),
                                        );
                                        _refreshData();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Errore: ${data['error'] ?? "Errore sconosciuto"}',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Errore di connessione al server',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  // Tab Team
  Widget _buildConstructorsTab() {
    return FutureBuilder<List<Constructor>>(
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
                child: ListTile(
                  leading: Image.network(
                    constructor.logoUrl,
                    width: 40,
                    height: 40,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                  title: Text(constructor.name),
                  subtitle: Text('${constructor.points} punti'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConstructorDetailScreen(constructor: constructor),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                            () =>
                                _showConstructorForm(constructor: constructor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed:
                            () => _showDeleteConfirmation(
                              context,
                              'team',
                              () async {
                                // Chiamata API per eliminare il team
                                final response = await http.post(
                                  Uri.parse('$baseUrl/admin_api.php'),
                                  body: jsonEncode({
                                    "entity_type": "constructors",
                                    "action": "delete",
                                    "id": constructor.id,
                                  }),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $authToken',
                                  },
                                );

                                if (response.statusCode == 200) {
                                  final data = jsonDecode(response.body);
                                  if (data['success']) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Team eliminato con successo',
                                        ),
                                      ),
                                    );
                                    _refreshData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Errore: ${data['error'] ?? "Errore sconosciuto"}',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Errore di connessione al server',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // Tab Notizie
  Widget _buildNewsTab() {
    return FutureBuilder<List<News>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessuna notizia disponibile'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final news = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  leading:
                      news.imageUrl.isNotEmpty
                          ? Image.network(
                            news.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                          )
                          : const Icon(Icons.article, size: 40),
                  title: Text(news.title),
                  subtitle: Text(
                    news.content.length > 50
                        ? '${news.content.substring(0, 50)}...'
                        : news.content,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showNewsForm(news: news),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed:
                            () => _showDeleteConfirmation(
                              context,
                              'notizia',
                              () async {
                                // Chiamata API per eliminare la notizia
                                final response = await http.post(
                                  Uri.parse('$baseUrl/admin_api.php'),
                                  body: jsonEncode({
                                    "entity_type": "news",
                                    "action": "delete",
                                    "id": news.id,
                                  }),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $authToken',
                                  },
                                );

                                if (response.statusCode == 200) {
                                  final data = jsonDecode(response.body);
                                  if (data['success']) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Notizia eliminata con successo',
                                        ),
                                      ),
                                    );
                                    _refreshData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Errore: ${data['error'] ?? "Errore sconosciuto"}',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Errore di connessione al server',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // Tab Gare
  Widget _buildRacesTab() {
    return FutureBuilder<List<Race>>(
      future: _racesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nessuna gara disponibile'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final race = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: race.flagUrl.isNotEmpty
                      ? Image.network(
                          race.flagUrl,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag),
                        )
                      : const Icon(Icons.flag),
                  title: Text(race.name),
                  subtitle: Text('${race.circuit} - ${race.date.day}/${race.date.month}/${race.date.year}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RaceDetailScreen(race: race),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showRaceForm(race: race);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Elimina gara'),
                              content: const Text('Sei sicuro di voler eliminare questa gara?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              final response = await http.post(
                                Uri.parse('$baseUrl/admin_api.php'),
                                body: jsonEncode({
                                  "entity_type": "races",
                                  "action": "delete",
                                  "id": race.id,
                                }),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $authToken',
                                },
                              );
                              if (response.statusCode == 200) {
                                final data = jsonDecode(response.body);
                                if (data['success']) {
                                  _refreshData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gara eliminata!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Errore: ${data['error'] ?? "Errore sconosciuto"}')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Errore di connessione al server')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Errore: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // Dialogo di conferma eliminazione
  void _showDeleteConfirmation(
    BuildContext context,
    String itemType,
    Function onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Elimina $itemType'),
            content: Text('Sei sicuro di voler eliminare questo $itemType?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: const Text('Elimina'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  // Form per piloti
  void _showDriverForm({Driver? driver}) {
    final TextEditingController nameController = TextEditingController(
      text: driver?.name ?? '',
    );
    final TextEditingController surnameController = TextEditingController(
      text: driver?.surname ?? '',
    );
    final TextEditingController pointsController = TextEditingController(
      text: driver?.points.toString() ?? '0',
    );
    final TextEditingController imageUrlController = TextEditingController(
      text: driver?.imageUrl ?? '',
    );
    final TextEditingController positionController = TextEditingController(
      text: driver?.position.toString() ?? '0',
    );
    final TextEditingController nationalityController = TextEditingController(text: driver?.nationality ?? '');
    final TextEditingController numberController = TextEditingController(text: driver?.number.toString() ?? '');
    final TextEditingController descriptionController = TextEditingController(text: driver?.description ?? '');
    int? selectedTeamId = driver?.teamId;

    showDialog(
      context: context,
      builder:
          (context) => FutureBuilder<List<Constructor>>(
            future: _constructorsFuture,
            builder: (context, snapshot) {
              final constructors = snapshot.data ?? [];
              return AlertDialog(
                title: Text(driver == null ? 'Aggiungi Pilota' : 'Modifica Pilota'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                      ),
                      TextField(
                        controller: surnameController,
                        decoration: const InputDecoration(labelText: 'Cognome'),
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedTeamId,
                        items: constructors.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        )).toList(),
                        onChanged: (val) {
                          selectedTeamId = val;
                        },
                        decoration: const InputDecoration(labelText: 'Team'),
                      ),
                      TextField(
                        controller: pointsController,
                        decoration: const InputDecoration(labelText: 'Punti'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: positionController,
                        decoration: const InputDecoration(labelText: 'Posizione'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Immagine',
                        ),
                      ),
                      TextField(
                        controller: nationalityController,
                        decoration: const InputDecoration(labelText: 'Nazionalità'),
                      ),
                      TextField(
                        controller: numberController,
                        decoration: const InputDecoration(labelText: 'Numero'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Biografia/Descrizione'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (selectedTeamId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seleziona un team!')),
                        );
                        return;
                      }
                      final body = {
                        "entity_type": "drivers",
                        "action": driver != null ? "update" : "create",
                        if (driver != null) "id": driver.id,
                        "name": nameController.text,
                        "surname": surnameController.text,
                        "team_id": selectedTeamId,
                        "points": int.parse(pointsController.text),
                        "position": int.parse(positionController.text),
                        "image_url": imageUrlController.text,
                        "nationality": nationalityController.text,
                        "number": int.tryParse(numberController.text) ?? 0,
                        "description": descriptionController.text,
                      };
                      final response = await http.post(
                        Uri.parse('$baseUrl/admin_api.php'),
                        body: jsonEncode(body),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $authToken',
                        },
                      );
                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        if (data['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(driver == null
                                  ? 'Pilota aggiunto con successo'
                                  : 'Pilota aggiornato con successo'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Errore: ${data['error'] ?? "Errore sconosciuto"}',
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Errore di connessione al server'),
                          ),
                        );
                      }
                      Navigator.pop(context);
                      _refreshData();
                    },
                    child: const Text('Salva'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Form per team
  void _showConstructorForm({Constructor? constructor}) {
    final TextEditingController nameController = TextEditingController(
      text: constructor?.name ?? '',
    );
    final TextEditingController pointsController = TextEditingController(
      text: constructor?.points.toString() ?? '0',
    );
    final TextEditingController logoUrlController = TextEditingController(
      text: constructor?.logoUrl ?? '',
    );
    final TextEditingController positionController = TextEditingController(
      text: constructor?.position.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              constructor == null ? 'Aggiungi Team' : 'Modifica Team',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(labelText: 'Punti'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Posizione'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: logoUrlController,
                  decoration: const InputDecoration(labelText: 'URL Logo'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () async {
                  // Implementazione chiamata API per salvare il team
                  final action = constructor == null ? "create" : "update";
                  final Map<String, dynamic> requestData = {
                    "entity_type": "constructors",
                    "action": action,
                    "name": nameController.text,
                    "points": int.parse(pointsController.text),
                    "position": int.parse(positionController.text),
                    "logo_url": logoUrlController.text,
                  };

                  // Aggiungi l'ID solo se stiamo aggiornando un team esistente
                  if (constructor != null) {
                    requestData["id"] = constructor.id;
                  }

                  final response = await http.post(
                    Uri.parse('$baseUrl/admin_api.php'),
                    body: jsonEncode(requestData),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $authToken',
                    },
                  );

                  Navigator.pop(context);

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            constructor == null
                                ? 'Team aggiunto con successo'
                                : 'Team aggiornato con successo',
                          ),
                        ),
                      );
                      _refreshData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Errore: ${data['error'] ?? "Errore sconosciuto"}',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Errore di connessione al server'),
                      ),
                    );
                  }
                },
                child: const Text('Salva'),
              ),
            ],
          ),
    );
  }

  // Form per notizie
  void _showNewsForm({News? news}) {
    final TextEditingController titleController = TextEditingController(
      text: news?.title ?? '',
    );
    final TextEditingController contentController = TextEditingController(
      text: news?.content ?? '',
    );
    final TextEditingController imageUrlController = TextEditingController(
      text: news?.imageUrl ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(news == null ? 'Aggiungi Notizia' : 'Modifica Notizia'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titolo'),
                  ),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Contenuto'),
                    maxLines: 5,
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Immagine',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () async {
                  // Implementazione chiamata API per salvare la notizia
                  final action = news == null ? "create" : "update";
                  final Map<String, dynamic> requestData = {
                    "entity_type": "news",
                    "action": action,
                    "title": titleController.text,
                    "content": contentController.text,
                    "image_url": imageUrlController.text,
                    "publish_date": DateTime.now().toIso8601String(),
                  };

                  // Aggiungi l'ID solo se stiamo aggiornando una notizia esistente
                  if (news != null) {
                    requestData["id"] = news.id;
                  }

                  final response = await http.post(
                    Uri.parse('$baseUrl/admin_api.php'),
                    body: jsonEncode(requestData),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $authToken',
                    },
                  );

                  Navigator.pop(context);

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            news == null
                                ? 'Notizia aggiunta con successo'
                                : 'Notizia aggiornata con successo',
                          ),
                        ),
                      );
                      _refreshData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Errore: ${data['error'] ?? "Errore sconosciuto"}',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Errore di connessione al server'),
                      ),
                    );
                  }
                },
                child: const Text('Salva'),
              ),
            ],
          ),
    );
  }

  // Form per gare
  void _showRaceForm({Race? race}) {
    final TextEditingController nameController = TextEditingController(text: race?.name ?? '');
    final TextEditingController circuitController = TextEditingController(text: race?.circuit ?? '');
    final TextEditingController dateController = TextEditingController(text: race != null ? '${race.date.year}-${race.date.month.toString().padLeft(2, '0')}-${race.date.day.toString().padLeft(2, '0')}' : '');
    final TextEditingController flagUrlController = TextEditingController(text: race?.flagUrl ?? '');
    bool isPast = race?.isPast ?? false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Funzione per controllare se la data è futura
            bool isDateFuture() {
              try {
                final date = DateTime.parse(dateController.text);
                final now = DateTime.now();
                return date.isAfter(DateTime(now.year, now.month, now.day));
              } catch (_) {
                return false;
              }
            }
            final bool disableIsPast = isDateFuture();
            return AlertDialog(
              title: Text(race == null ? 'Aggiungi Gara' : 'Modifica Gara'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome gara'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: circuitController,
                      decoration: const InputDecoration(labelText: 'Circuito'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Data (YYYY-MM-DD)'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: flagUrlController,
                      decoration: const InputDecoration(labelText: 'URL bandiera'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: disableIsPast ? false : isPast,
                          onChanged: disableIsPast
                              ? null
                              : (val) {
                                  setState(() {
                                    isPast = val ?? false;
                                  });
                                },
                        ),
                        Text(
                          'Gara passata',
                          style: TextStyle(
                            color: disableIsPast ? Colors.grey : null,
                          ),
                        ),
                        if (disableIsPast)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.info_outline, color: Colors.grey, size: 18),
                          ),
                      ],
                    ),
                    if (disableIsPast)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Il flag "Gara passata" è impostato automaticamente per le date future.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final circuit = circuitController.text.trim();
                    final dateStr = dateController.text.trim();
                    final flagUrl = flagUrlController.text.trim();
                    if (name.isEmpty || circuit.isEmpty || dateStr.isEmpty) return;
                    try {
                      final response = await http.post(
                        Uri.parse('$baseUrl/admin_api.php'),
                        body: jsonEncode({
                          "entity_type": "races",
                          "action": race == null ? "add" : "edit",
                          if (race != null) "id": race.id,
                          "name": name,
                          "circuit": circuit,
                          "date": dateStr,
                          "flagUrl": flagUrl,
                          // Se la data è futura, forziamo isPast a 0
                          "isPast": disableIsPast ? 0 : (isPast ? 1 : 0),
                        }),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $authToken',
                        },
                      );
                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        if (data['success']) {
                          Navigator.pop(context);
                          _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(race == null ? 'Gara aggiunta!' : 'Gara modificata!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Errore: ${data['error'] ?? "Errore sconosciuto"}')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore HTTP ${response.statusCode}: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Errore: $e')),
                      );
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
