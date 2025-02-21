import 'surveypage3.dart';
import 'surveypage7.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyApp extends StatelessWidget {
  const SurveyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사전 설문 조사',
      home: const SurveyPage6(),
    );
  }
}

class SurveyPage6 extends StatefulWidget {
  const SurveyPage6({Key? key}) : super(key: key);

  @override
  _SurveyPage6State createState() => _SurveyPage6State();
}

class _SurveyPage6State extends State<SurveyPage6> {
  Set<String> selectedHelps = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddHelpData() async {
    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '받고 싶은 도움': selectedHelps,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage7()),
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
              value: 6 / 7,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '6/7',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '상담 외에 추가로 받고 싶은 도움이 있으신가요?',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                '도움이 될만한 것이 궁금해요!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            CheckboxTile('스트레스 관리 방법'),
            const SizedBox(height: 10),
            CheckboxTile('마음을 다스리는 활동 추천'),
            const SizedBox(height: 10),
            CheckboxTile('명상이나 호흡법 안내'),
            const SizedBox(height: 10),
            CheckboxTile('자기계발 팁 제공'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: AddHelpData,
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

  Widget CheckboxTile(String emotion) {
    return CheckboxListTile(
      title: Text(emotion),
      value: selectedHelps.contains(emotion),
      tileColor:
      selectedHelps.contains(emotion) ? Colors.green[50] : Colors.white,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(
          color: selectedHelps.contains(emotion) ? Colors.green : Colors.grey,
          width: 1.5,
        ),
      ),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedHelps.add(emotion);
          } else {
            selectedHelps.remove(emotion);
          }
        });
      },
      activeColor: Colors.green,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      checkboxShape: const CircleBorder(),
    );
  }
}

