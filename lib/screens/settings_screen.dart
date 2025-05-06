import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  bool _isDarkMode = false;
  double _fontSize = 1.0;
  int _primaryColor = 0xFFE10600; // Rosso F1 predefinito

  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Rosso F1', 'value': 0xFFE10600},
    {'name': 'Blu', 'value': 0xFF0000FF},
    {'name': 'Verde', 'value': 0xFF00C853},
    {'name': 'Arancione', 'value': 0xFFFF9800},
    {'name': 'Viola', 'value': 0xFF6200EA},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final isDarkMode = await _preferencesService.isDarkMode();
    final fontSize = await _preferencesService.getFontSize();
    final primaryColor = await _preferencesService.getPrimaryColor();

    setState(() {
      _isDarkMode = isDarkMode;
      _fontSize = fontSize;
      _primaryColor = primaryColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: Color(_primaryColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Tema'),
          _buildThemeSelector(),
          const Divider(),

          _buildSectionTitle('Colore Principale'),
          _buildColorSelector(),
          const Divider(),

          _buildSectionTitle('Dimensione Testo'),
          _buildFontSizeSelector(),
          const Divider(),

          _buildSectionTitle('Gestione Dati'),
          _buildResetButton(),
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

  Widget _buildThemeSelector() {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: const Text('Tema Scuro'),
        subtitle: const Text('Attiva il tema scuro per l\'app'),
        value: _isDarkMode,
        activeColor: Color(_primaryColor),
        onChanged: (value) async {
          await _preferencesService.setDarkMode(value);
          setState(() {
            _isDarkMode = value;
          });
          // Qui si potrebbe implementare un sistema per aggiornare il tema in tutta l'app
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleziona il colore principale dell\'app'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  _availableColors.map((colorData) {
                    return InkWell(
                      onTap: () async {
                        await _preferencesService.setPrimaryColor(
                          colorData['value'],
                        );
                        setState(() {
                          _primaryColor = colorData['value'];
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(colorData['value']),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                _primaryColor == colorData['value']
                                    ? Colors.white
                                    : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child:
                            _primaryColor == colorData['value']
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dimensione del testo'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    activeColor: Color(_primaryColor),
                    onChanged: (value) async {
                      await _preferencesService.setFontSize(value);
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 24)),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Testo di esempio',
                  style: TextStyle(fontSize: 16 * _fontSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.restore),
        title: const Text('Ripristina impostazioni predefinite'),
        onTap: () async {
          // Mostra dialogo di conferma
          final confirm = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Ripristina impostazioni'),
                  content: const Text(
                    'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Ripristina'),
                    ),
                  ],
                ),
          );

          if (confirm == true) {
            await _preferencesService.resetAllPreferences();
            await _loadPreferences(); // Ricarica le preferenze predefinite
          }
        },
      ),
    );
  }
}
