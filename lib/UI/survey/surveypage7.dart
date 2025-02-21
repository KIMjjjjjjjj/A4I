import '../Login/Login_UI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyApp extends StatelessWidget {
  const SurveyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사전 설문 조사',
      home: const SurveyPage7(),
    );
  }
}

class SurveyPage7 extends StatefulWidget {
  const SurveyPage7({Key? key}) : super(key: key);

  @override
  _SurveyPage7State createState() => _SurveyPage7State();
}

class _SurveyPage7State extends State<SurveyPage7> {
  Set<String> selectedEmotions = {};
  TextEditingController TextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddEmotionData() async {
    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      if (selectedEmotions.contains('기타(직접 입력)')) {
        String etcInput = TextController.text.trim();
        if (etcInput.isNotEmpty) {
          selectedEmotions.remove('기타(직접 입력)');
          selectedEmotions.add(etcInput);
        }
      }

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '현재 감정': selectedEmotions,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
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
              value: 7 / 7,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '7/7',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '요즘 당신의 감정을 한 단어로 표현한다면?',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                '편하게 선택해주세요!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            CheckboxTile('행복'),
            const SizedBox(height: 10),
            CheckboxTile('불안'),
            const SizedBox(height: 10),
            CheckboxTile('슬픔'),
            const SizedBox(height: 10),
            CheckboxTile('지침'),
            const SizedBox(height: 10),
            CheckboxTile('외로움'),
            const SizedBox(height: 10),
            CheckboxTile('기타(직접 입력)'),
            Visibility(
              visible: selectedEmotions.contains('기타(직접 입력)'),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextField(
                  controller: TextController,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    filled: true,
                    fillColor: Colors.green[50],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: AddEmotionData,
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
      value: selectedEmotions.contains(emotion),
      tileColor:
      selectedEmotions.contains(emotion) ? Colors.green[50] : Colors.white,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: BorderSide(
          color: selectedEmotions.contains(emotion) ? Colors.green : Colors.grey,
          width: 1.5,
        ),
      ),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedEmotions.add(emotion);
          } else {
            selectedEmotions.remove(emotion);
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
