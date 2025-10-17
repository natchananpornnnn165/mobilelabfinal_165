import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditQuizScreen extends StatefulWidget {
  const AddEditQuizScreen({super.key});

  @override
  State<AddEditQuizScreen> createState() => _AddEditQuizScreenState();
}

class _AddEditQuizScreenState extends State<AddEditQuizScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
      }
      return;
    }
    setState(() { _isLoading = true; });
    try {
      await FirebaseFirestore.instance.collection('quizzes').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': Timestamp.now(),
      });
      if (mounted) { Navigator.of(context).pop(); }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add quiz: $e')));
      }
    }
    if (mounted) { setState(() { _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Quiz'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveQuiz,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Quiz Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description (e.g., 10 questions - 15 min)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Note: Adding questions will be implemented next.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}