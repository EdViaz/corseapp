import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../services/api_service.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<List<Race>> _racesFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _racesFuture = _apiService.getRaces();
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
       title: Image.asset("images/f1logo.png"),
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Races'),
            Tab(text: 'Past Races'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: FutureBuilder<List<Race>>(
        future: _racesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No races available'));
          } else {
            final races = snapshot.data!;
            final upcomingRaces = races.where((race) => !race.isPast).toList();
            final pastRaces = races.where((race) => race.isPast).toList();
            
            return TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Races Tab
                _buildRacesList(upcomingRaces, isUpcoming: true),
                
                // Past Races Tab
                _buildRacesList(pastRaces, isUpcoming: false),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRacesList(List<Race> races, {required bool isUpcoming}) {
    if (races.isEmpty) {
      return Center(
        child: Text(isUpcoming ? 'No upcoming races' : 'No past races'),
      );
    }
    
    return ListView.builder(
      itemCount: races.length,
      itemBuilder: (context, index) {
        final race = races[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: race.flagUrl.isNotEmpty
                ? Image.network(
                    race.flagUrl,
                    width: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.flag, size: 40);
                    },
                  )
                : const Icon(Icons.flag, size: 40),
            title: Text(
              race.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(race.circuit),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${race.date.day}/${race.date.month}/${race.date.year}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.green : Colors.grey,
                  ),
                ),
                Text(race.country),
              ],
            ),
          ),
        );
      },
    );
  }
}