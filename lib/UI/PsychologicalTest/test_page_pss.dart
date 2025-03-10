import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/select_test.dart';

class TestPagePss extends StatefulWidget {
  @override
  _TestPagePssState createState() => _TestPagePssState();
}

class _TestPagePssState extends State<TestPagePss> {
  User? user = FirebaseAuth.instance.currentUser;
  String testType = 'PSS';
  List<int> answers = List.filled(10, -1);
  List<String> questions = [
    '1. 예상치 못한 일 때문에 화가 난 적이 있습니까?',
    '2. 생활하면서 중요한 일들을 통제할 수 없다고 느낀 적이 있습니까?',
    '3. 신경이 예민해지고 스트레스를 받은 적이 있습니까?',
    '4. 개인적인 문제들을 다루는 능력에 대해 자신감을 느낀 적이 있습니까?',
    '5. 당신이 원하는 방식으로 일이 진행되고 있다고 느낀 적이 있습니까?',
    '6. 당신이 해야만 하는 모든 일을 감당할 수 없다고 느낀 적이 있습니까?',
    '7. 일상생활에서 겪는 불안감과 초조함을 통제할 수 있었습니까?',
    '8. 일들이 어떻게 돌아가는 지 잘 알고 있다고 느낀 적이 있었습니까?',
    '9. 통제할 수 없는 일 때문에 화가 난 적이 있습니까?',
    '10. 힘든 일이 너무 많이 쌓여도 도저히 감당할 수 없다고 느낀 적이 있습니까?'
  ];

  @override
  void initState() {
    super.initState();
    loadAnswer();
  }

  // 총점 계산
  int getTotalScore() {
    return answers.asMap().entries.fold(0, (sum, entry) {
      int index = entry.key;
      int value = entry.value;

      if (value == -1) return sum;

      if (index >= 3 && index <= 7) {
        int convertedScore;
        switch (value) {
          case 0:
            convertedScore = 3;
            break;
          case 1:
            convertedScore = 2;
            break;
          case 2:
            convertedScore = 1;
            break;
          case 3:
            convertedScore = 0;
            break;
          default:
            convertedScore = value;
        }
        return sum + convertedScore;
      } else {
        return sum + value;
      }
    });
  }

  //답변 저장
  Future<void> saveAnswer(int questionIndex, int selectedOption) async {
    if (user == null) return;

    DocumentReference<Map<String, dynamic>> questionRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("questions");

    await questionRef.set({
      "$questionIndex": {"선택 문항": selectedOption}
    }, SetOptions(merge: true));
  }

  //답변 불러오기
  Future<void> loadAnswer() async {
    DocumentReference<Map<String, dynamic>> questionRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("questions");

    DocumentSnapshot<Map<String, dynamic>> snapshot = await questionRef.get();
    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> savedAnswers = snapshot.data()!;
      setState(() {
        savedAnswers.forEach((key, value) {
          if (key != "solvedCount") {
            int questionIndex = int.tryParse(key) ?? -1;
            if (questionIndex >= 0 && questionIndex < answers.length) {
              answers[questionIndex] = value["선택 문항"];
            }
          }
        });
      });
    }
  }

  // 중간 진행 상황
  Future<void> progressTest() async {
    int solvedCount = answers.where((v) => v != -1).length;

    if (user == null) return;
    DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("score");

    await docRef.set({
      "solvedCount": solvedCount,
    }, SetOptions(merge: true));
  }

  // 최종 제출
  Future<void> submitTest() async {
    int currentRound = 1;
    int totalScore = getTotalScore();

    if (user == null) return;
    DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user?.uid)
        .collection(testType)
        .doc("score");

    DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      if (data != null && data.isNotEmpty) {
        List<int> existingRounds = data.keys
            .where((key) => int.tryParse(key) != null)
            .map((key) => int.parse(key))
            .toList();
        if (existingRounds.isNotEmpty) {
          currentRound = existingRounds.reduce((a, b) => a > b ? a : b);
        }
      }
    }
    await docRef.set({
      "$currentRound": totalScore,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("questions")
        .delete();
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
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                children: [
                  const Text(
                    '스트레스 척도 PSS',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '0: 아니다  1: 가끔 그렇다\n2: 자주그렇다  3: 항상 그렇다',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    '1/1',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          children: List.generate(questions.length, (index) {
                            return QuestionSlider(
                              question: questions[index],
                              value: answers[index],
                              onChanged: (value) {
                                setState(() => answers[index] = value);
                                saveAnswer(index, value);
                              },
                            );
                          })
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            progressTest();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SelectTestPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6BE5A0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17.0),
                            ),
                            padding: const EdgeInsets.all(12.0),
                          ),
                          child: const Text(
                            '뒤로가기',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            submitTest();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SelectTestPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6BE5A0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17.0),
                            ),
                            padding: const EdgeInsets.all(12.0),
                          ),
                          child: const Text(
                            '제출',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                ]
            ),
          ),
        )
    );
  }
}

class QuestionSlider extends StatelessWidget {
  final String question;
  final int value;
  final ValueChanged<int> onChanged;

  const QuestionSlider({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 16)),
        Stack(
          children: [
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFF7D3),
                  borderRadius: BorderRadius.circular(17.0),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Column(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: value,
                        onChanged: (value) => onChanged(value!),
                        activeColor: Color(0xFF6BE5A0),
                        fillColor: MaterialStateColor.resolveWith((states) =>
                        value == index ? Color(0xFF6BE5A0) : Colors.grey),
                      ),
                      Text(index.toString()),
                    ],
                  );
                }),
              ),
            )
          ],
        ),
        SizedBox(height: 10)
      ],
    );
  }
}

