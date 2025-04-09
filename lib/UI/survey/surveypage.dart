import 'surveypage2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({Key? key}) : super(key: key);

  @override
  _SurveyPageState createState() => _SurveyPageState();
}


class _SurveyPageState extends State<SurveyPage> {
  String? selectedGender = '';
  bool _showError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddGenderData() async {
    if (selectedGender == null || selectedGender!.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '성별': selectedGender,
      });
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage2()),
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
                value: 1 / 7,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '1/7',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  '성별을 선택해주세요!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              RadioListTile<String>(
                title: const Text('남성'),
                value: '남성',
                tileColor: selectedGender == '남성' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedGender == '남성' ? Colors.green : Colors.grey,
                    width: 1.5,
                  ),
                ),
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('여성'),
                value: '여성',
                tileColor: selectedGender == '여성' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedGender == '여성' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('선택안함'),
                value: '선택안함',
                tileColor: selectedGender == '선택안함' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedGender == '선택안함' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              // 에러 메시지 표시 부분
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: AddGenderData,
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
