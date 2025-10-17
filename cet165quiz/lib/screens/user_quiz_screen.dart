// lib/screens/user_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cet165quiz/screens/result_screen.dart';

class UserQuizScreen extends StatefulWidget {
  final String quizId; // 1. รับ quizId
  final String quizTitle; // 2. รับ quizTitle

  const UserQuizScreen({required this.quizId, required this.quizTitle, super.key});

  @override
  State<UserQuizScreen> createState() => _UserQuizScreenState();
}

class _UserQuizScreenState extends State<UserQuizScreen> {
  List<QueryDocumentSnapshot> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // 3. ฟังก์ชันดึงคำถามจาก Firestore
  Future<void> _fetchQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions')
        .get();
    
    setState(() {
      _questions = snapshot.docs;
      _isLoading = false;
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    final correctAns = _questions[_currentQuestionIndex].data() as Map<String, dynamic>;
    if (_selectedAnswer == correctAns['correctAnswer']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: _score, totalQuestions: _questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text('No questions found for this quiz!')),
      );
    }

    final currentQuestionData = _questions[_currentQuestionIndex].data() as Map<String, dynamic>;
    final questionText = currentQuestionData['questionText'] ?? 'No Question Text';
    final options = List<String>.from(currentQuestionData['options'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quizTitle} • ${_currentQuestionIndex + 1}/${_questions.length}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              questionText,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ...options.map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RadioListTile<String>(
                  title: Text(option, style: const TextStyle(fontSize: 18)),
                  value: option,
                  groupValue: _selectedAnswer,
                  onChanged: (value) => _selectAnswer(value!),
                  activeColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: _selectedAnswer == option ? Colors.teal : Colors.grey,
                      width: _selectedAnswer == option ? 2 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _currentQuestionIndex == _questions.length - 1 ? 'Submit' : 'Next Question',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}