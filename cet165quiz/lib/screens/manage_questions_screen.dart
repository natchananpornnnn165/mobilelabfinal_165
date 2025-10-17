import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_question_screen.dart'; // Import หน้าสำหรับเพิ่ม/แก้ไขคำถาม

class ManageQuestionsScreen extends StatelessWidget {
  final String quizId;
  final String quizTitle;

  const ManageQuestionsScreen({required this.quizId, required this.quizTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions for "$quizTitle"'),
        backgroundColor: Colors.indigo,
      ),
      // ใช้ StreamBuilder เพื่อแสดงรายการคำถามแบบ Real-time
      body: StreamBuilder<QuerySnapshot>(
        // ดึงข้อมูลจาก subcollection 'questions' ของ quiz ปัจจุบัน
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No questions found. Add one!'));
          }

          final questions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final questionDoc = questions[index];
              final questionData = questionDoc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(questionData['questionText'] ?? 'No question text'),
                  subtitle: Text('Correct Answer: ${questionData['correctAnswer']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- ปุ่มแก้ไข ---
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {
                          // 1. เมื่อกดปุ่มแก้ไข ให้ไปหน้า AddEditQuestionScreen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddEditQuestionScreen(
                                quizId: quizId,
                                questionDoc: questionDoc, // 2. ส่งข้อมูลคำถาม (document) ทั้งหมดไปด้วย
                              ),
                            ),
  
                          );
                        },
                      ),
                      // --- ปุ่มลบ ---
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          // แสดง Dialog ยืนยันก่อนลบคำถาม
                           showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Are you sure?'),
                              content: const Text('Do you want to delete this question?'),
                              actions: <Widget>[
                                TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop()),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    questionDoc.reference.delete();
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ปุ่มสำหรับพาไปยังหน้า Add Question
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 3. เมื่อกดปุ่ม + ให้ไปหน้า AddEditQuestionScreen แบบไม่ส่งข้อมูล (เป็นการสร้างใหม่)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditQuestionScreen(quizId: quizId),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}