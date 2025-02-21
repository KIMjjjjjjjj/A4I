import 'dart:async';

import 'surveypage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyApp extends StatelessWidget {
  const SurveyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사전 설문 조사',
      home: const SurveyExplainPage(),
    );
  }
}

class SurveyExplainPage extends StatefulWidget {
  const SurveyExplainPage({Key? key}) : super(key: key);

  @override
  _SurveyExplainPageState createState() => _SurveyExplainPageState();
}


class _SurveyExplainPageState extends State<SurveyExplainPage> {

  final TextEditingController currentNicknameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();

    Timer.periodic(Duration(seconds: 1), (timer) async {
      await loadUserData();
    });
  }

  Future<void> loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentNicknameController.text = userDoc['nickname'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('사전 설문 조사'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '반가워요!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${currentNicknameController.text}님에 대해 조금 더 알아가고\n 싶어서 간단한 질문을 준비했어요',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '준비되셨다면 시작해볼까요?',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SurveyPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  '다음',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
