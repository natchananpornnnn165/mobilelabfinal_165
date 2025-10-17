import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // 1. Import package สำหรับจัดรูปแบบวันที่

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Scores & Statistics'),
        backgroundColor: Colors.green,
      ),
      // ใช้ StreamBuilder เพื่อแสดงข้อมูลผลลัพธ์แบบ Real-time
      body: StreamBuilder<QuerySnapshot>(
        // ดึงข้อมูลจาก collection 'results' และเรียงตามเวลาล่าสุด
        stream: FirebaseFirestore.instance
            .collection('results')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ขณะกำลังโหลดข้อมูล
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // ถ้ามี Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // ถ้าไม่มีข้อมูล
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No results found yet.'));
          }

          // เมื่อมีข้อมูลแล้ว
          final results = snapshot.data!.docs;

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final resultData = results[index].data() as Map<String, dynamic>;
              
              // 2. ดึงข้อมูล Timestamp และป้องกัน Error ถ้าเป็น null
              final timestamp = resultData['timestamp'] as Timestamp?;
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.shade100,
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          '${resultData['score']}/${resultData['totalQuestions']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    resultData['quizTitle'] ?? 'Unknown Quiz',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('User: ${resultData['userEmail'] ?? 'Unknown User'}'),
                      const SizedBox(height: 2),
                      // 3. แสดงวันที่และเวลาที่จัดรูปแบบแล้ว
                      if (timestamp != null)
                        Text(
                          DateFormat.yMd().add_jms().format(timestamp.toDate()),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        )
                      else
                        const Text('No date available', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}