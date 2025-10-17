import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final String quizId;
  final DocumentSnapshot? questionDoc; // รับข้อมูลคำถาม (อาจเป็น null)

  const AddEditQuestionScreen({
    required this.quizId,
    this.questionDoc,
    super.key,
  });

  @override
  _AddEditQuestionScreenState createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  final _questionController = TextEditingController();
  
  String? _correctAnswer;
  bool _isLoading = false;
  bool get _isEditing => widget.questionDoc != null;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นโหมดแก้ไข ให้ดึงข้อมูลเก่ามาใส่ในฟอร์ม
    if (_isEditing) {
      final data = widget.questionDoc!.data() as Map<String, dynamic>;
      _questionController.text = data['questionText'] ?? '';
      final options = List<String>.from(data['options'] ?? []);
      for (int i = 0; i < 4; i++) {
        _optionControllers[i].text = (i < options.length) ? options[i] : '';
      }
      _correctAnswer = data['correctAnswer'];
    }

    for (var controller in _optionControllers) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _correctAnswer == null || _correctAnswer!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields and select the correct answer.')));
      return;
    }
    _formKey.currentState!.save();

    setState(() { _isLoading = true; });

    final questionData = {
      'questionText': _questionController.text.trim(),
      'options': _optionControllers.map((c) => c.text.trim()).toList(),
      'correctAnswer': _correctAnswer,
    };

    try {
      final questionCollection = FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions');

      if (_isEditing) {
        // อัปเดตข้อมูลเดิม
        await questionCollection.doc(widget.questionDoc!.id).update(questionData);
      } else {
        // เพิ่มข้อมูลใหม่
        await questionCollection.add(questionData);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Question' : 'Add Question'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveQuestion,
          ),
        ],
      ),
      // --- นี่คือส่วน Body ที่สมบูรณ์ ---
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(labelText: 'Question Text', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter a question.' : null,
                    ),
                    const SizedBox(height: 16),
                    ..._optionControllers.map((controller) {
                      int index = _optionControllers.indexOf(controller);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Option ${index + 1}', border: const OutlineInputBorder()),
                          validator: (value) => value!.isEmpty ? 'Please enter an option.' : null,
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 20),
                    const Text('Select the Correct Answer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    
                    ..._optionControllers.map((controller) {
                      return RadioListTile<String>(
                        title: Text(controller.text.isNotEmpty ? controller.text : 'Option ${_optionControllers.indexOf(controller) + 1}'),
                        value: controller.text,
                        groupValue: _correctAnswer,
                        onChanged: controller.text.isEmpty ? null : (val) {
                          setState(() {
                            _correctAnswer = val;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}