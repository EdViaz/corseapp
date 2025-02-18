import 'package:flutter/material.dart';
import 'classifica_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 Stats App'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuButton(
              context,
              title: "Classifica Piloti",
              icon: Icons.emoji_events,
              screen: ClassificaScreen(),
            ),
            _buildMenuButton(
              context,
              title: "Calendario Gare",
              icon: Icons.calendar_today,
              screen: PlaceholderScreen(title: "Calendario Gare"),
            ),
            _buildMenuButton(
              context,
              title: "Confronta Piloti",
              icon: Icons.compare_arrows,
              screen: PlaceholderScreen(title: "Confronta Piloti"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String title, required IconData icon, required Widget screen}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// Placeholder per schermate ancora da sviluppare
class PlaceholderScreen extends StatelessWidget {
  final String title;
  PlaceholderScreen({required this.title});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("sigma", style: TextStyle(fontSize: 18))),
    );
  }
}
