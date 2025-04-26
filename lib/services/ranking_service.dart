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
    required String categoryName,
    required String difficulty,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingRankings = await getRankings();

    final newRanking = {
      'category': category,
      'categoryName': categoryName,
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

  // Helper method to get category name from category ID
  static String getCategoryName(String categoryId, BuildContext context) {
    // If the ranking already has a categoryName field, use that
    if (categoryId.contains('_name_')) {
      return categoryId.split('_name_')[1];
    }

    // Otherwise translate the category ID using LocalizationService
    return LocalizationService.of(context)!.translate('category_$categoryId') ?? categoryId;
  }
}

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> rankings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() {
      isLoading = true;
    });

    final loadedRankings = await RankingService.getRankings();

    setState(() {
      rankings = loadedRankings;
      isLoading = false;
    });
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('rankings')),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rankings.isEmpty
          ? Center(
        child: Text(LocalizationService.of(context)!.translate('no_rankings_available')),
      )
          : ListView.builder(
        itemCount: rankings.length,
        itemBuilder: (context, index) {
          final ranking = rankings[index];

          // Get the category name
          String categoryName = ranking['categoryName'] ??
              RankingService.getCategoryName(ranking['category'], context);

          String difficulty = ranking['difficulty'];
          String difficultyName = LocalizationService.of(context)!.translate('difficulty_$difficulty') ?? difficulty;

          // Format timestamp to be more readable
          String formattedTime = _formatTimestamp(ranking['timestamp']);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text('$categoryName - $difficultyName'),
              subtitle: Text(
                '${LocalizationService.of(context)!.translate('score')}: ${ranking['score']}',
              ),
              trailing: Text(formattedTime, style: const TextStyle(fontSize: 12)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show confirmation dialog
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(LocalizationService.of(context)!.translate('confirm_reset')),
              content: Text(LocalizationService.of(context)!.translate('reset_rankings_warning')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(LocalizationService.of(context)!.translate('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(LocalizationService.of(context)!.translate('reset')),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await RankingService.resetRankings();
            _loadRankings();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocalizationService.of(context)!.translate('rankings_reset'))),
            );
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}