import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/question_model.dart';
import 'quiz_screen.dart';
import '../services/localization_service.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  QuizSetupScreenState createState() => QuizSetupScreenState();
}

class QuizSetupScreenState extends State<QuizSetupScreen> {
  String? category;
  String? categoryName;
  String difficulty = 'easy';
  int numberOfQuestions = 5;
  List<dynamic> categories = [];
  Map<String, dynamic>? categoriesData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      categoriesData = await ApiService.fetchCategories();
      setState(() {
        categories = categoriesData!['trivia_categories'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Show error message if categories can't be loaded
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationService.of(context)!.translate('error_loading_categories'))),
        );
      }
    }
  }

  // Function to get category name from selected category ID
  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
          (cat) => cat['id'].toString() == categoryId,
      orElse: () => {'name': categoryId},
    );
    return category['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('quiz_setup')),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.of(context)!.translate('quiz_options'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: LocalizationService.of(context)!.translate('category'),
                        border: const OutlineInputBorder(),
                      ),
                      value: category,
                      isExpanded: true,
                      items: categories.map((categoryItem) {
                        return DropdownMenuItem<String>(
                          value: categoryItem['id'].toString(),
                          child: Text(categoryItem['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          category = value;
                          categoryName = getCategoryName(value!);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: LocalizationService.of(context)!.translate('difficulty'),
                        border: const OutlineInputBorder(),
                      ),
                      value: difficulty,
                      isExpanded: true,
                      items: ['easy', 'medium', 'hard'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(LocalizationService.of(context)!.translate(value)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          difficulty = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: LocalizationService.of(context)!.translate('number_of_questions'),
                        border: const OutlineInputBorder(),
                      ),
                      value: numberOfQuestions,
                      isExpanded: true,
                      items: [5, 10, 15, 20].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          numberOfQuestions = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                if (category != null) {
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    List<Question> questions = await ApiService.fetchQuestions(
                        category!,
                        difficulty,
                        numberOfQuestions
                    );

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            questions: questions,
                            category: category!,
                            categoryName: categoryName!, // Pass the human-readable category name
                            difficulty: difficulty,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(LocalizationService.of(context)!.translate('error_loading_questions'))),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocalizationService.of(context)!.translate('please_select_category'))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text(
                LocalizationService.of(context)!.translate('start_quiz'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            if (category != null)
              Text(
                '${LocalizationService.of(context)!.translate('selected_category')}: $categoryName',
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}