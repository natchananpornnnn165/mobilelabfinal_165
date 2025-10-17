import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import สำหรับ Logout
import 'add_edit_quiz_screen.dart';
import 'user_quiz_screen.dart';
import 'manage_questions_screen.dart';
import 'auth_screen.dart'; // 2. Import สำหรับกลับไปหน้า Login

class QuizListScreen extends StatelessWidget {
  final bool isAdmin;
  const QuizListScreen({this.isAdmin = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Manage Quizzes' : 'Available Quizzes'),
        backgroundColor: isAdmin ? Colors.blueGrey : Colors.teal,
        // 3. เพิ่มปุ่ม Logout ที่ AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // ถ้าเป็น User ทั่วไป ให้ signOut ออกจาก Firebase
              if (!isAdmin) {
                FirebaseAuth.instance.signOut();
              }
              // ไม่ว่าจะ Admin หรือ User ให้กลับไปหน้า Login และลบหน้าเก่าทิ้ง
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      // ใช้ StreamBuilder เพื่อแสดงข้อมูลแบบ Real-time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No quizzes found.'));
          }

          final quizzes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quizDoc = quizzes[index];
              final quizData = quizDoc.data() as Map<String, dynamic>;
              
              final quizTitle = quizData['title'] ?? 'No Title';
              final quizDesc = quizData['description'] ?? 'No Description';
              final quizId = quizDoc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(quizTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(quizDesc),
                  trailing: isAdmin
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // TODO: Implement edit quiz title/description
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Are you sure?'),
                                    content: Text('Do you want to delete the quiz "$quizTitle"?'),
                                    actions: <Widget>[
                                      TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop()),
                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          FirebaseFirestore.instance.collection('quizzes').doc(quizId).delete();
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (!isAdmin) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserQuizScreen(
                            quizId: quizId,
                            quizTitle: quizTitle,
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ManageQuestionsScreen(
                            quizId: quizId,
                            quizTitle: quizTitle,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddEditQuizScreen()),
                );
              },
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}