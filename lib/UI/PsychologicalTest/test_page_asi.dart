import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/select_test.dart';

class TestPageAsi extends StatefulWidget {
  @override
  _TestPageAsiState createState() => _TestPageAsiState();
}

class _TestPageAsiState extends State<TestPageAsi> {
  User? user = FirebaseAuth.instance.currentUser;
  String testType = 'ASI';
  ScrollController scrollController = ScrollController();
  List<int> answers = List.filled(16, -1);
  List<String> questions = [
    '1. 남들에게 불안하게 보이지 말아야 한다.',
    '2. 집중이 잘 안되면, 이러다가 미치는 것은 아닌가 걱정한다.',
    '3. 몸이 떨리거나 휘청거리면, 겁이 난다.',
    '4. 기절할 것 같으면, 겁이 난다.',
    '5. 감정 조절은 잘 하는 것이 중요하다.',
    '6. 심장이 빨리 뛰면 겁이 난다.',
    '7. 배에서 소리가 나면 깜짝 놀란다.',
    '8. 속이 매스꺼워지면 겁이 난다.',
    '9. 심장이 빨리 뛰는 것이 느껴지면 심장마비가 오지 않을까 걱정된다.',
    '10. 숨이 가빠지면, 겁이 난다.',
    '11. 뱃속이 불편해지면, 심각한 병에 걸린 것은 아닌가 걱정된다.',
    '12. 어떤 일을 할 때 집중이 안되면 겁이 난다.',
    '13. 내가 떨면, 다른 사람들이 알아 챈다.',
    '14. 몸이 평소와 다른 감각이 느껴지면, 겁이 난다.',
    '15. 신경이 예민해지면, 정신적으로 문제가 생긴 것은 아닌가 걱정된다.',
    '16. 신경이 날카로워 지면, 겁이 난다.'
  ];

  @override
  void initState() {
    super.initState();
    loadAnswer();
  }

  // 총점 계산
  int getTotalScore() {
    return answers.where((value) => value != -1).fold(0, (sum, value) => sum + value);
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
  Future<bool> submitTest() async {
    int currentRound = 1;
    int totalScore = getTotalScore();
    int firstUnansweredIndex = answers.indexWhere((answer) => answer == -1);

    if (firstUnansweredIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("모든 문항을 선택하지 않았어요!"))
      );
      scrollController.animateTo(
        firstUnansweredIndex * 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return false;
    }

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

    return true;
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
                '불안 민감성 척도 ASI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                '0: 전혀 그렇지 않다  1: 약간 그런 편이다\n2: 중간이다  3: 꽤 그런 편이다  4: 매우 그렇다',
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
                  controller: scrollController,
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
                      onPressed: () async {
                        bool isComplete = await submitTest();
                        progressTest();
                        if(isComplete){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SelectTestPage()),
                          );
                        }
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
                children: List.generate(5, (index) {
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

