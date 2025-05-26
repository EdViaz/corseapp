import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';
import './news_detail_screen.dart'; // Importa la nuova schermata

// Schermata che mostra le ultime notizie di Formula 1
// Visualizza un elenco di notizie con titolo e immagine
// Permette di accedere ai dettagli completi di ogni notizia

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // Servizio per le chiamate API
  final ApiService _apiService = ApiService();
  // Future per i dati delle notizie
  late Future<List<News>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Carica le notizie all'avvio della schermata
    _newsFuture = _apiService.getNews();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = _apiService.getNews();
    });
    await _newsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<News>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // Mostra indicatore di caricamento mentre i dati vengono recuperati
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Gestisce eventuali errori durante il recupero dei dati
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Gestisce il caso in cui non ci siano notizie disponibili
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available'));
          }
          // Costruisce la lista delle notizie quando i dati sono disponibili
          else {
            return RefreshIndicator(
              onRefresh: _refreshNews,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final news = snapshot.data![index];
                  // Card cliccabile per ogni notizia
                  return GestureDetector(
                    // Naviga alla schermata di dettaglio quando si tocca una notizia
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  NewsDetailScreen(news: news),
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
                    child: Card(
                      margin: const EdgeInsets.all(12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (news.imageUrl.isNotEmpty)
                            Hero(
                              tag: 'news-image-${news.id}',
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: Image.network(
                                  news.imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.error),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  news.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  news.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pubblicato il ${news.publishDate.day}/${news.publishDate.month}/${news.publishDate.year}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
