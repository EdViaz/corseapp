import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../models/user_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import './auth_screen.dart';
import './driver_detail_screen.dart';
import './news_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final PreferencesService _preferencesService = PreferencesService();
  
  User? _currentUser;
  bool _isLoading = true;
  List<Driver> _favoriteDrivers = [];
  List<Driver> _allDrivers = [];
  List<Comment> _userComments = [];
  List<News> _allNews = []; // Aggiunto per tenere traccia di tutte le news
  List<Constructor> _constructors = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final user = await _authService.getCurrentUser();
      final drivers = await _apiService.getDriverStandings();
      final constructors = await _apiService.getConstructorStandings();
      final favoriteIds = await _preferencesService.getFavoriteDrivers();
      final favorites = drivers.where((driver) => favoriteIds.contains(driver.id)).toList();
      List<Comment> comments = [];
      if (user != null) {
        try {
          comments = await _apiService.getUserComments(user.id);
        } catch (e) {}
      }
      List<News> news = [];
      try {
        news = await _apiService.getNews();
      } catch (e) {}
      if (mounted) {
        setState(() {
          _currentUser = user;
          _allDrivers = drivers;
          _favoriteDrivers = favorites;
          _userComments = comments;
          _allNews = news;
          _constructors = constructors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento dei dati: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleFavorite(Driver driver) async {
    final isFavorite = _favoriteDrivers.any((d) => d.id == driver.id);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (isFavorite) {
        // Rimuovi dai preferiti
        await _preferencesService.removeFavoriteDriver(driver.id);
        setState(() {
          _favoriteDrivers.removeWhere((d) => d.id == driver.id);
        });
      } else {
        // Aggiungi ai preferiti
        await _preferencesService.addFavoriteDriver(driver.id);
        setState(() {
          _favoriteDrivers.add(driver);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'aggiornamento dei preferiti: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo Utente'),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.red,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProfileContent(),
            _buildLoadingIndicator(), // Indicatore di caricamento sovrapposto
          ],
        ),
      ),
    );
  }
  
  // Mostra un indicatore di caricamento sovrapposto
  Widget _buildLoadingIndicator() {
    return _isLoading
        ? Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
  
  Widget _buildProfileContent() {
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Registrati/accedi per gestire il tuo profilo',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                ).then((_) {
                  if (mounted) {
                    _loadUserData();
                  }
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Registrati/accedi'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informazioni utente
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser!.username,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Appassionato di Formula 1'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _authService.logout();
                        if (mounted) {
                          setState(() {
                            _currentUser = null;
                            _favoriteDrivers = [];
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logout effettuato con successo')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
            


            
            const SizedBox(height: 24),
            
            // Piloti preferiti
            const Text(
              'I tuoi piloti preferiti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _favoriteDrivers.isEmpty
                ? const Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Non hai ancora aggiunto piloti ai preferiti. Aggiungi i tuoi piloti preferiti dalla sezione "Tutti i piloti".',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _favoriteDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = _favoriteDrivers[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(driver.imageUrl),
                            onBackgroundImageError: (_, __) => const Icon(Icons.error),
                          ),
                          title: Text('${driver.name} ${driver.surname}'),
                          subtitle: Text(_constructors.firstWhere(
                            (c) => c.id == driver.teamId,
                            orElse: () => Constructor(id: 0, name: '-', points: 0, logoUrl: '', position: 0),
                          ).name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () => _toggleFavorite(driver),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverDetailScreen(driverId: driver.id),
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    _loadUserData();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            
            const SizedBox(height: 24),
            
            // I tuoi commenti
            const Text(
              'I tuoi commenti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _userComments.isEmpty
                ? const Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Non hai ancora scritto commenti. Visita la sezione notizie per commentare.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userComments.length,
                    itemBuilder: (context, index) {
                      final comment = _userComments[index];
                      return InkWell(
                        onTap: () async {
                          // Cerca la news già caricata
                          final news = _allNews.firstWhere(
                            (n) => n.id == comment.newsId,
                            orElse: () => News(
                              id: 0,
                              title: 'Notizia non trovata',
                              content: '',
                              imageUrl: '',
                              publishDate: DateTime.now(),
                              additionalImages: [],
                            ),
                          );
                          if (news.id != 0) {
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailScreen(news: news),
                              ),
                            );
                          } else {
                            // Se non trovata, prova a caricarla da API
                            try {
                              final fetchedNews = await _apiService.getNewsById(comment.newsId);
                              if (!mounted) return;
                              if (fetchedNews != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailScreen(news: fetchedNews),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notizia non trovata'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Errore nel caricamento della notizia: $e'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade800,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#${comment.newsId}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Commento', 
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${comment.date.day}/${comment.date.month}/${comment.date.year}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(comment.content),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            
            const SizedBox(height: 24),
            
            // Tutti i piloti
            const Text(
              'Tutti i piloti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allDrivers.length,
              itemBuilder: (context, index) {
                final driver = _allDrivers[index];
                final isFavorite = _favoriteDrivers.any((d) => d.id == driver.id);
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(driver.imageUrl),
                      onBackgroundImageError: (_, __) => const Icon(Icons.error),
                    ),
                    title: Text('${driver.name} ${driver.surname}'),
                    subtitle: Text(_constructors.firstWhere(
                      (c) => c.id == driver.teamId,
                      orElse: () => Constructor(id: 0, name: '-', points: 0, logoUrl: '', position: 0),
                    ).name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () => _toggleFavorite(driver),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverDetailScreen(driverId: driver.id),
                              ),
                            );
                            if (result == true && mounted) {
                              _loadUserData();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}