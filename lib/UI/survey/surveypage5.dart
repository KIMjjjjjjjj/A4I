import 'surveypage6.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyPage5 extends StatefulWidget {
  const SurveyPage5({Key? key}) : super(key: key);

  @override
  _SurveyPage5State createState() => _SurveyPage5State();
}

class _SurveyPage5State extends State<SurveyPage5> {
  String? selectedWant = '';
  bool _showError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddWantData() async {
    if (selectedWant == null || selectedWant!.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '상담을 통해 얻고 싶은 것': selectedWant,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage6()),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: 5 / 7,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '5/7',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  '상담을 통해 얻고싶은 것이 무엇인가요?',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),

              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  '부담없이 말씀해주세요!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              RadioListTile<String>(
                title: const Text('문제 해결을 위한 실질적인 조언'),
                value: '문제 해결을 위한 실질적인 조언',
                tileColor: selectedWant == '문제 해결을 위한 실질적인 조언' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedWant == '문제 해결을 위한 실질적인 조언' ? Colors.green : Colors.grey,
                    width: 1.5,
                  ),
                ),
                groupValue: selectedWant,
                onChanged: (value) {
                  setState(() {
                    selectedWant = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('감정적인 공감과 위로'),
                value: '감정적인 공감과 위로',
                tileColor: selectedWant == '감정적인 공감과 위로' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedWant == '감정적인 공감과 위로' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedWant,
                onChanged: (value) {
                  setState(() {
                    selectedWant = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('새로운 시각과 아이디어'),
                value: '새로운 시각과 아이디어',
                tileColor: selectedWant == '새로운 시각과 아이디어' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedWant == '새로운 시각과 아이디어' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedWant,
                onChanged: (value) {
                  setState(() {
                    selectedWant = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('스트레스 해소 및 심리적 안정'),
                value: '스트레스 해소 및 심리적 안정',
                tileColor: selectedWant == '스트레스 해소 및 심리적 안정' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedWant == '스트레스 해소 및 심리적 안정' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedWant,
                onChanged: (value) {
                  setState(() {
                    selectedWant = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              if (_showError)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      '선택해주세요',
                      style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: AddWantData,
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
      ),
    );
  }
}
