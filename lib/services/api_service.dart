import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions(String category, String difficulty, int amount) async {
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=multiple');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Question> questions = (data['results'] as List).map((question) {
        List<String> options = List<String>.from(question['incorrect_answers'])..add(question['correct_answer']);
        options.shuffle();
        return Question(
          question: question['question'],
          options: options,
          correctAnswer: question['correct_answer'],
        );
      }).toList();
      return questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }

  static Future<Map<String, dynamic>> fetchCategories() async {
    final url = Uri.parse('https://opentdb.com/api_category.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load categories');
    }
  }
}