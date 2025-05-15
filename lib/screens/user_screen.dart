import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../models/user_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import './auth_screen.dart';
import './news_detail_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with SingleTickerProviderStateMixin {
  // Servizi
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final PreferencesService _preferencesService = PreferencesService();
  
  // Controller per le tab
  late TabController _tabController;
  
  // Stato utente
  User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Dati utente
  List<Driver> _favoriteDrivers = [];
  List<Comment> _userComments = [];
  List<Driver> _allDrivers = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkCurrentUser();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Verifica se l'utente è loggato
  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final user = await _authService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        
        if (user != null) {
          _loadUserData();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante il caricamento dei dati: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  // Carica i dati dell'utente (piloti preferiti e commenti)
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Carica tutti i piloti
      final drivers = await _apiService.getDriverStandings();
      
      // Ottieni gli ID dei piloti preferiti
      final favoriteIds = await _preferencesService.getFavoriteDrivers();
      
      // Filtra i piloti preferiti
      final favorites = drivers.where((driver) => favoriteIds.contains(driver.id)).toList();
      
      // Carica i commenti dell'utente
      List<Comment> comments = [];
      if (_currentUser != null) {
        try {
          comments = await _apiService.getUserComments(_currentUser!.id);
        } catch (e) {
          print('Errore nel caricamento dei commenti: ${e.toString()}');
          // Non blocchiamo il caricamento degli altri dati se i commenti falliscono
        }
      }
      
      if (mounted) {
        setState(() {
          _allDrivers = drivers;
          _favoriteDrivers = favorites;
          _userComments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante il caricamento dei dati: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  // Logout
  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        setState(() {
          _currentUser = null;
          _favoriteDrivers = [];
          _userComments = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il logout: ${e.toString()}'))
        );
      }
    }
  }
  
  // Naviga alla schermata di autenticazione
  void _navigateToAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    ).then((_) {
      // Quando torniamo dalla schermata di autenticazione, verifichiamo se l'utente è loggato
      _checkCurrentUser();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo Utente'),
        actions: [
          // Mostra il pulsante di logout solo se l'utente è loggato
          if (_currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _currentUser == null
                  ? _buildLoginPrompt()
                  : _buildUserContent(),
    );
  }
  
  // Widget per il prompt di login
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Accedi o registrati per visualizzare il tuo profilo',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToAuth,
            child: const Text('Accedi / Registrati'),
          ),
        ],
      ),
    );
  }
  
  // Widget per il contenuto dell'utente loggato
  Widget _buildUserContent() {
    return Column(
      children: [
        // Informazioni utente
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser!.username,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID: ${_currentUser!.id}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Tab bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Piloti Preferiti'),
            Tab(icon: Icon(Icons.comment), text: 'I Miei Commenti'),
          ],
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFavoriteDriversTab(),
              _buildUserCommentsTab(),
            ],
          ),
        ),
      ],
    );
  }
  
  // Tab per i piloti preferiti
  Widget _buildFavoriteDriversTab() {
    if (_favoriteDrivers.isEmpty) {
      return const Center(
        child: Text(
          'Non hai ancora aggiunto piloti ai preferiti.\nVisita la classifica piloti e aggiungi i tuoi preferiti!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _favoriteDrivers.length,
      itemBuilder: (context, index) {
        final driver = _favoriteDrivers[index];
        return ListTile(
          leading: driver.imageUrl != null && driver.imageUrl!.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(driver.imageUrl!),
                )
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text('${driver.name} ${driver.surname}'),
          subtitle: Text(driver.team),
          trailing: Text(
            '${driver.points} pts',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
  
  // Tab per i commenti dell'utente
  Widget _buildUserCommentsTab() {
    if (_userComments.isEmpty) {
      return const Center(
        child: Text(
          'Non hai ancora commentato nessuna notizia.\nVisita la sezione notizie e lascia i tuoi commenti!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _userComments.length,
      itemBuilder: (context, index) {
        final comment = _userComments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pubblicato il ${comment.date.day}/${comment.date.month}/${comment.date.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}