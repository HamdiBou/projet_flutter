import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class RankingService {
  static const String _key = 'quiz_rankings';

  static Future<List<Map<String, dynamic>>> getRankings() async {
    final prefs = await SharedPreferences.getInstance();
    final rankingsJson = prefs.getString(_key);
    if (rankingsJson == null) {
      return [];
    }
    List<dynamic> decodedList = jsonDecode(rankingsJson);
    return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> saveRanking({
    required String category,
    required String difficulty,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingRankings = await getRankings();

    final newRanking = {
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'timestamp': DateTime.now().toIso8601String(),
    };

    existingRankings.add(newRanking);

    // Sort rankings by score (descending) and timestamp (ascending)
    existingRankings.sort((a, b) {
      int scoreComparison = b['score'].compareTo(a['score']);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a['timestamp'].compareTo(b['timestamp']);
    });

    // Keep only the top 10 rankings
    if (existingRankings.length > 10) {
      existingRankings.removeRange(10, existingRankings.length);
    }

    final rankingsJson = jsonEncode(existingRankings);
    await prefs.setString(_key, rankingsJson);
  }

  static Future<void> resetRankings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

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