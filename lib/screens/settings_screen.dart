import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, this.onThemeChanged}) : super(key: key);
  final void Function(bool)? onThemeChanged;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Amministrazione'),
          _buildAdminButton(),
          const SizedBox(height: 32),
          _buildSectionTitle('Info app'),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAdminButton() {
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings),
        title: const Text('Accesso Amministratore'),
        subtitle: const Text('Gestisci piloti, team e notizie'),
        onTap: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Login Amministratore'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
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
                        final username = _usernameController.text.trim();
                        final password = _passwordController.text.trim();

                        // Effettua la richiesta al backend
                        final response = await http.post(
                          Uri.parse('http://localhost:80/api/admin_login.php'),
                          body: jsonEncode({
                            'username': username,
                            'password': password,
                          }),
                          headers: {'Content-Type': 'application/json'},
                        );

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          if (data['success']) {
                            Navigator.pop(context); // Chiudi il dialogo PRIMA
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminScreen(),
                              ),
                            );
                            return;
                          }
                        }

                        // Autenticazione fallita, mostra un messaggio di errore
                        Navigator.pop(context); // Chiudi il dialogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Autenticazione fallita. Controlla le credenziali.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Accedi'),
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CorseApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Versione: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Autore: Edoardo Viale'),
            const SizedBox(height: 8),
            const Text('Email: edoardo.viale@itiszuccante.edu.it'),
          ],
        ),
      ),
    );
  }
}
