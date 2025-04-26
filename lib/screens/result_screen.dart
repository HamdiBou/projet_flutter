import 'package:flutter/material.dart';
import '../services/ranking_service.dart';
import '../services/localization_service.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String category;
  final String categoryName;
  final String difficulty;
  final VoidCallback onRetry;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.categoryName,
    required this.difficulty,
    required this.onRetry,
  });

  // Constructor overload for backward compatibility
  factory ResultScreen.withCategoryId({
    Key? key,
    required int score,
    required int totalQuestions,
    required String category,
    required String difficulty,
    required VoidCallback onRetry,
  }) {
    return ResultScreen(
      key: key,
      score: score,
      totalQuestions: totalQuestions,
      category: category,
      categoryName: category, // This will be translated by RankingService
      difficulty: difficulty,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage for visual feedback
    final percentage = (score / totalQuestions) * 100;
    final String resultMessage = _getResultMessage(percentage, context);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('results')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              resultMessage,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _getColorForPercentage(percentage),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $score / $totalQuestions',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              '${LocalizationService.of(context)!.translate('category')}: $categoryName',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${LocalizationService.of(context)!.translate('difficulty')}: ${_getDifficultyName(difficulty, context)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(LocalizationService.of(context)!.translate('retry_quiz')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await RankingService.saveRanking(
                  category: category,
                  categoryName: categoryName,
                  difficulty: difficulty,
                  score: score,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocalizationService.of(context)!.translate('ranking_saved'))),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: Text(LocalizationService.of(context)!.translate('save_ranking')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed("/home");
              },
              icon: const Icon(Icons.home),
              label: Text(LocalizationService.of(context)!.translate('back_to_home')),
            ),
          ],
        ),
      ),
    );
  }

  String _getResultMessage(double percentage, BuildContext context) {
    if (percentage >= 80) {
      return LocalizationService.of(context)!.translate('excellent_result');
    } else if (percentage >= 60) {
      return LocalizationService.of(context)!.translate('good_result');
    } else if (percentage >= 40) {
      return LocalizationService.of(context)!.translate('fair_result');
    } else {
      return LocalizationService.of(context)!.translate('keep_practicing');
    }
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.blue;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getDifficultyName(String difficulty, BuildContext context) {
    return LocalizationService.of(context)!.translate('difficulty_$difficulty') ?? difficulty;
  }
}