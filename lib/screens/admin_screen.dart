import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/f1_models.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final String baseUrl = 'http://localhost/backend/api';

  // Token di autorizzazione per le chiamate API admin
  final String authToken =
      'your_auth_token_here'; // In un'app reale, questo dovrebbe essere ottenuto tramite login

  // Futures per caricare i dati
  late Future<List<Driver>> _driversFuture;
  late Future<List<Constructor>> _constructorsFuture;
  late Future<List<News>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _driversFuture = _apiService.getDriverStandings();
      _constructorsFuture = _apiService.getConstructorStandings();
      _newsFuture = _apiService.getNews();
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostra dialogo per aggiungere un nuovo elemento in base alla tab corrente
          final currentTab = _tabController.index;
          if (currentTab == 0) {
            _showDriverForm();
          } else if (currentTab == 1) {
            _showConstructorForm();
          } else {
            _showNewsForm();
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final driver = snapshot.data![index];
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
                  subtitle: Text('${driver.team} - ${driver.points} punti'),
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
    final TextEditingController teamController = TextEditingController(
      text: driver?.team ?? '',
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

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  TextField(
                    controller: teamController,
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
                  if (driver != null) {
                    final response = await http.post(
                      Uri.parse('$baseUrl/admin_api.php'),
                      body: jsonEncode({
                        "entity_type": "drivers",
                        "action": "update",
                        "id": driver.id,
                        "name": nameController.text,
                        "surname": surnameController.text,
                        "team": teamController.text,
                        "points": int.parse(pointsController.text),
                        "position": int.parse(positionController.text),
                        "image_url": imageUrlController.text,
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
                            content: Text('Pilota aggiornato con successo'),
                          ),
                        );
                      }
                    }
                  } else {
                    // Aggiungi pilota
                    final response = await http.post(
                      Uri.parse('$baseUrl/admin_api.php'),
                      body: jsonEncode({
                        "entity_type": "drivers",
                        "action": "create",
                        "name": nameController.text,
                        "surname": surnameController.text,
                        "team": teamController.text,
                        "points": int.parse(pointsController.text),
                        "position": int.parse(positionController.text),
                        "image_url": imageUrlController.text,
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
                            content: Text('Pilota aggiunto con successo'),
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
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        driver == null
                            ? 'Pilota aggiunto con successo'
                            : 'Pilota aggiornato con successo',
                      ),
                    ),
                  );
                  _refreshData();
                },
                child: const Text('Salva'),
              ),
            ],
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
}
