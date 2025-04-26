import 'package:flutter/material.dart';
import '../services/ranking_service.dart';
import '../services/localization_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> rankings = [];

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    final loadedRankings = await RankingService.getRankings();
    setState(() {
      rankings = loadedRankings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('rankings')),
      ),
      body: rankings.isEmpty
          ? Center(
              child: Text(LocalizationService.of(context)!.translate('no_rankings_available')),
            )
          : ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final ranking = rankings[index];
                return ListTile(
                  title: Text('${ranking['category']} - ${ranking['difficulty']}'),
                  subtitle: Text(
                      'Score: ${ranking['score']}, ${ranking['timestamp']}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await RankingService.resetRankings();
          _loadRankings();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocalizationService.of(context)!.translate('rankings_reset'))),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}