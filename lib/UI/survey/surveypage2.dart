import 'surveypage3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SurveyPage2 extends StatefulWidget {
  const SurveyPage2({Key? key}) : super(key: key);

  @override
  _SurveyPage2State createState() => _SurveyPage2State();
}

class _SurveyPage2State extends State<SurveyPage2> {
  String? selectedAge = '';
  bool _showError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddAgeData() async {
    if (selectedAge == null || selectedAge!.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      await _firestore.collection('test').doc(uid).collection('firsttest').doc(uid).set({
        '나이대': selectedAge,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage3()),
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
                value: 2 / 7,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '2/7',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  '연령대를 선택해주세요!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              RadioListTile<String>(
                title: const Text('10대'),
                value: '10대',
                tileColor: selectedAge == '10대' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedAge == '10대' ? Colors.green : Colors.grey,
                    width: 1.5,
                  ),
                ),
                groupValue: selectedAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('20대'),
                value: '20대',
                tileColor: selectedAge == '20대' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedAge == '20대' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
                    _showError = false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('30대'),
                value: '30대',
                tileColor: selectedAge == '30대' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedAge == '30대' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('40대'),
                value: '40대',
                tileColor: selectedAge == '40대' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedAge == '40대' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('50대 이상'),
                value: '50대 이상',
                tileColor: selectedAge == '50대 이상' ? Colors.green[50] : Colors.white,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: selectedAge == '50대 이상' ? Colors.green : Colors.grey,
                    width: 1.0,
                  ),
                ),
                groupValue: selectedAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = value;
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
                  onPressed: AddAgeData,
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
