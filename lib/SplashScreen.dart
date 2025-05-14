import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'UI/chatbot/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 로딩 시간 시뮬레이션 (로고 보여주는 시간)
    await Future.delayed(Duration(seconds: 2));

    // 메시지 미리 불러오고 static 변수에 저장
    List<Map<String, String>> messages = await _loadMessages();
    ChatScreen.cachedInitialMessages = messages;

    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<List<Map<String, String>>> _loadMessages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_history.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List decoded = jsonDecode(contents);
        return decoded.map((e) => Map<String, String>.from(e)).toList();
      }
    } catch (e) {
      print('스플래쉬에서 메시지 로딩 실패: $e');
    }

    // 기본 초기 메시지
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(flex: 2), // 위 여백
          Center(
            child: Image.asset(
              'assets/images/splash_icon.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
