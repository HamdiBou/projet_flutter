import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String category;
  final String difficulty;
  final VoidCallback onRetry;

  const ResultScreen({super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: $score / $totalQuestions',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry Quiz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await RankingService.saveRanking(
                  category: category,
                  difficulty: difficulty,
                  score: score,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ranking saved!')),
                );
              },
              child: const Text('Save Ranking'),
            ),
          ],
        ),
      ),
    );
  }
}