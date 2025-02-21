import 'surveypage4.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyApp extends StatelessWidget {
  const SurveyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사전 설문 조사',
      home: const SurveyPage3(),
    );
  }
}

class SurveyPage3 extends StatefulWidget {
  const SurveyPage3({Key? key}) : super(key: key);

  @override
  _SurveyPageState3 createState() => _SurveyPageState3();
}

class _SurveyPageState3 extends State<SurveyPage3> {
  String? selectedAnswer = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddAnswerData() async {
    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '상담 경험이 있는가?': selectedAnswer,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage4()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류')),
      );
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
            LinearProgressIndicator(
              value: 3 / 7,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '3/7',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '심리 상담을 받아본 경험이 있으신가요?',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                '솔직하게 답해주세요!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            RadioListTile<String>(
              title: const Text('네'),
              value: '네',
              tileColor: selectedAnswer == '네' ? Colors.green[50] : Colors.white,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: selectedAnswer == '네' ? Colors.green : Colors.grey,
                  width: 1.5,
                ),
              ),
              groupValue: selectedAnswer,
              onChanged: (value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
              activeColor: Colors.green,
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text('아니오'),
              value: '아니오',
              tileColor: selectedAnswer == '아니오' ? Colors.green[50] : Colors.white,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: selectedAnswer == '아니오' ? Colors.green : Colors.grey,
                  width: 1.0,
                ),
              ),
              groupValue: selectedAnswer,
              onChanged: (value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
              activeColor: Colors.green,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: AddAnswerData,
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
