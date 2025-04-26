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
  String difficulty = 'easy';
  int numberOfQuestions = 5;
  List<dynamic> categories = [];
  Map<String, dynamic>? categoriesData;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    categoriesData = await ApiService.fetchCategories();
    setState(() {
      categories = categoriesData!['trivia_categories'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.of(context)!.translate('quiz_setup')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: LocalizationService.of(context)!.translate('category')),
              value: category,
              items: categories.map((categoryItem) {
                return DropdownMenuItem<String>(
                  value: categoryItem['id'].toString(),
                  child: Text(categoryItem['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: LocalizationService.of(context)!.translate('difficulty')),
              value: difficulty,
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
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: LocalizationService.of(context)!.translate('number_of_questions')),
              value: numberOfQuestions,
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
            ElevatedButton(
              onPressed: () async {
                if (category != null) {
                  List<Question> questions = await ApiService.fetchQuestions(
                      category!, difficulty, numberOfQuestions);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        questions: questions,
                        category: category!,
                        difficulty: difficulty,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                }
              },
              child: Text(LocalizationService.of(context)!.translate('start')),
            ),
          ],
        ),
      ),
    );
  }
}