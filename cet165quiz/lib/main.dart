import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import ที่จำเป็นสำหรับ Firebase
import 'firebase_options.dart';                   // 2. Import ไฟล์ตั้งค่าที่ flutterfire สร้างให้

// 3. Import หน้าจอแรกที่จะให้แอปแสดงผล
import 'package:cet165quiz/screens/auth_screen.dart'; 

void main() async { // 4. เปลี่ยน main ให้เป็น async
  // 5. เพิ่ม 2 บรรทัดนี้เพื่อเริ่มต้นการเชื่อมต่อ Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug Banner
      title: 'CET QUIZ',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // กำหนดสีหลักของแอป
        useMaterial3: true,
      ),
      // 6. กำหนดให้หน้า AuthScreen เป็นหน้าแรกของแอป
      home: const AuthScreen(), 
    );
  }
}