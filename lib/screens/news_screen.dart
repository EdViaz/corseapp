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

  // Modalità di visualizzazione: 0 = lista, 1 = griglia 2 colonne
  int _viewMode = 0;

  @override
  void initState() {
    super.initState();
    // Carica le notizie all'avvio della schermata
    _newsFuture = _apiService.getNews();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = (_viewMode + 1) % 2;
    });
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
      appBar: AppBar(
        title: const Text('Notizie'),
        backgroundColor: Colors.red.shade700,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == 0 ? Icons.view_list : Icons.grid_view,
            ),
            tooltip: 'Cambia vista',
            onPressed: _toggleViewMode,
          ),
        ],
      ),
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
            final newsList = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshNews,
              child: _viewMode == 0
                  ? ListView.builder(
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return _buildNewsCard(context, news, isGrid: false);
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return _buildNewsCard(context, news, isGrid: true);
                      },
                    ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, News news, {bool isGrid = false}) {
    return GestureDetector(
      // Naviga alla schermata di dettaglio quando si tocca una notizia
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
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
        margin: EdgeInsets.all(isGrid ? 4.0 : 12.0),
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
                    height: isGrid ? 120 : 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: isGrid ? 120 : 200,
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
              padding: EdgeInsets.all(isGrid ? 8.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: isGrid ? 15 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: isGrid ? 2 : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.content,
                    maxLines: isGrid ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isGrid ? 13 : 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pubblicato il ${news.publishDate.day}/${news.publishDate.month}/${news.publishDate.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: isGrid ? 11 : 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
