import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question_model.dart';
import 'result_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html_unescape/html_unescape.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String category;
  final String difficulty;
  const QuizScreen({super.key, required this.questions, required this.category, required this.difficulty});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool answerWasSelected = false;
  String? selectedAnswer;
  final player = AudioPlayer();
  bool _soundEnabled = true;
  final unescape = HtmlUnescape();
  
  // Timer variables
  int _timeLeft = 30; // Time in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startTimer();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound') ?? true;
    });
  }

  void _startTimer() {
    _timeLeft = 30; // Reset timer to 30 seconds
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          // Time's up, handle as incorrect answer
          if (!answerWasSelected) {
            answerWasSelected = true;
            playSound('sounds/incorrect.mp3');
            vibrate();
            // Auto proceed to next question after delay
            Future.delayed(const Duration(seconds: 2), () {
              _nextQuestion();
            });
          }
        }
      });
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        answerWasSelected = false;
        selectedAnswer = null;
        currentQuestionIndex++;
        _startTimer(); // Reset timer for new question
      });
    } else {
      // End of quiz
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: correctAnswers,
            totalQuestions: widget.questions.length,
            category: widget.category,
            difficulty: widget.difficulty,
            onRetry: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> playSound(String soundPath) async {
    if (_soundEnabled) {
      await player.play(AssetSource(soundPath));
    }
  }

  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer display
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _timeLeft <= 5 ? Colors.red : Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Time left: $_timeLeft',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 5 ? Colors.red : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Question display
              Text(
                unescape.convert(widget.questions[currentQuestionIndex].question),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Options
              ...(widget.questions[currentQuestionIndex].options).map((option) {
                final String unescapedOption = unescape.convert(option);
                final bool isCorrect = option == widget.questions[currentQuestionIndex].correctAnswer;
                final bool isSelected = option == selectedAnswer;
                
                // Icon for feedback
                Widget getAnswerStatusIcon() {
                  if (!answerWasSelected) return const SizedBox.shrink();
                  
                  if (isCorrect) {
                    return const Icon(Icons.check_circle, color: Colors.green);
                  } else if (isSelected) {
                    return const Icon(Icons.cancel, color: Colors.red);
                  }
                  
                  return const SizedBox.shrink();
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: answerWasSelected ? Border.all(
                        color: isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey),
                        width: 2.0,
                      ) : null,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: answerWasSelected
                          ? null
                          : () async {
                              setState(() {
                                answerWasSelected = true;
                                selectedAnswer = option;
                                
                                if (isCorrect) {
                                  correctAnswers++;
                                  playSound('sounds/correct.mp3');
                                } else {
                                  playSound('sounds/incorrect.mp3');
                                  vibrate();
                                }
                              });
                              
                              // Auto proceed to next question after delay
                              Future.delayed(const Duration(milliseconds: 2000), () {
                                _nextQuestion();
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Stack(
                        children: [
                          // Center the text
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                unescapedOption,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Position the icon on the right
                          if (answerWasSelected)
                            Positioned(
                              right: 12.0,
                              top: 0,
                              bottom: 0,
                              child: Center(child: getAnswerStatusIcon()),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 20),
              
              // Progress indicator
              Text(
                'Question ${currentQuestionIndex + 1} / ${widget.questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}