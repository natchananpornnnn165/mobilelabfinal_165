import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_list_screen.dart';
import 'statistics_screen.dart';
import 'auth_screen.dart'; // 1. Import หน้า Auth Screen เพื่อใช้ในการ Logout

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        // 2. เพิ่มปุ่ม Logout ที่ AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // สำหรับ Admin ที่ hardcode ไว้ เราแค่ Navigator กลับไปหน้า Login
              // และลบหน้าจอเก่าทั้งหมดทิ้งไป
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ส่วนแสดงข้อมูลแบบ Real-time
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('results').snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return DashboardCard(title: 'Results Submitted', value: count.toString(), icon: Icons.person_pin);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return DashboardCard(title: 'Quizzes', value: count.toString(), icon: Icons.quiz);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // เมนูสำหรับ Admin
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_document, size: 30, color: Colors.blueGrey),
                    title: const Text('Manage Quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Create, edit, delete quizzes'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const QuizListScreen(isAdmin: true)),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.bar_chart, size: 30, color: Colors.green),
                    title: const Text('View Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Scores and performance'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget สำหรับการ์ดแสดงผล (ไม่มีการแก้ไข)
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const DashboardCard({required this.title, required this.value, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}