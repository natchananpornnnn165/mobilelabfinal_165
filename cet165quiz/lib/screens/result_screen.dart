// lib/screens/result_screen.dart
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({required this.score, required this.totalQuestions, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Result'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // ไม่ให้กด Back
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              const Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score:',
                style: TextStyle(fontSize: 22, color: Colors.grey[700]),
              ),
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // กลับไปยังหน้า Quiz List หรือ Home Screen
                    Navigator.of(context).popUntil((route) => route.isFirst); // กลับไปหน้าแรกสุด
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}