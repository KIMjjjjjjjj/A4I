import 'package:capstone/alarm_setting.dart';
import 'package:capstone/change_email.dart';
import 'package:capstone/change_password.dart';
import 'package:flutter/material.dart';

import 'delete_account.dart';
import 'main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const SettingacountPage(),
    );
  }
}

class SettingacountPage extends StatelessWidget {
  const SettingacountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '계정 관리',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: ListTile(
              title: const Text('이메일 변경', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeEmailPage()),
                );
              },
            ),
          ),
          SizedBox(height: 5),
          Container(
            color: Colors.white,
            child: ListTile(
              title: const Text('비밀번호 변경', style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          Container(
            color: Colors.white,
            child: ListTile(
              title: const Text('계정 삭제', style: TextStyle(fontSize: 16, color: Colors.red)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
