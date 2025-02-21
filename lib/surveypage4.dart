import 'surveypage5.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyApp extends StatelessWidget {
  const SurveyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사전 설문 조사',
      home: const SurveyPage4(),
    );
  }
}

class SurveyPage4 extends StatefulWidget {
  const SurveyPage4({Key? key}) : super(key: key);

  @override
  _SurveyPage4State createState() => _SurveyPage4State();
}

class _SurveyPage4State extends State<SurveyPage4> {
  Set<String> selectedWorrys = {};
  TextEditingController TextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddWorryData() async {
    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      if (selectedWorrys.contains('기타(직접 입력)')) {
        String etcInput = TextController.text.trim();
        if (etcInput.isNotEmpty) {
          selectedWorrys.remove('기타(직접 입력)');
          selectedWorrys.add(etcInput);
        }
      }

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '현재 고민': selectedWorrys,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage5()),
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
              value: 4 / 7,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '4/7',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '현재 고민이 있으신가요?',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                '사소한 고민도 괜찮아요!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            CheckboxTile('대인 관계'),
            const SizedBox(height: 10),
            CheckboxTile('학업'),
            const SizedBox(height: 10),
            CheckboxTile('취업 및 직장생활'),
            const SizedBox(height: 10),
            CheckboxTile('건강(신체적/정신적)'),
            const SizedBox(height: 10),
            CheckboxTile('경제적 어려움'),
            const SizedBox(height: 10),
            CheckboxTile('기타(직접 입력)'),
            Visibility(
              visible: selectedWorrys.contains('기타(직접 입력)'),
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
                onPressed: AddWorryData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(18.0),
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
    value: selectedWorrys.contains(emotion),
    tileColor:
    selectedWorrys.contains(emotion) ? Colors.green[50] : Colors.white,
    shape: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: selectedWorrys.contains(emotion) ? Colors.green : Colors.grey,
        width: 1.5,
      ),
    ),
    onChanged: (bool? value) {
      setState(() {
        if (value == true) {
          selectedWorrys.add(emotion);
        } else {
          selectedWorrys.remove(emotion);
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
