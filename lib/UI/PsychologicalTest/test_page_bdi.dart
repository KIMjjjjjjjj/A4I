import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/select_test.dart';

class TestPageBdi extends StatefulWidget {
  @override
  _TestPageBdiState createState() => _TestPageBdiState();
}

class _TestPageBdiState extends State<TestPageBdi> {
  User? user = FirebaseAuth.instance.currentUser;
  String testType = 'BDI';
  int index = 0;
  List<int> answers = List.filled(21, -1);
  final List<Map<String, dynamic>> questions = [
    {
      'options': [
        '나는 슬프지 않다.',
        '나는 슬프다.',
        '나는 항상 슬퍼서 기운을 낼 수 없다.',
        '나는 너무나 슬프고 불행해서 도저히 견딜 수가 없다.'
      ]
    },
    {
      'options': [
        '나는 앞날에 대해서 별로 낙담하지 않는다.',
        '나는 앞날에 대해서 비관적인 느낌이 든다.',
        '나는 앞날에 대해 기대할 것이 아무것도 없다고 느낀다.',
        '나의 앞날은 아주 절망적이고 나아질 가망이 없다고 느낀다.'
      ]
    },
    {
      'options': [
        '나는 실패자라고 느끼지 않는다.',
        '나는 보통 사람들보다 더 많이 실패한 것 같다.',
        '내가 살아온 과거를 뒤돌아 보면 실패투성이인 것 같다.',
        '나는 인간으로서 완전한 실패자라고 느낀다.'
      ]
    },
    {
      'options': [
        '나는 전과 같은 일상생활에 만족하고 있다.',
        '나의 일상생활은 예전처럼 즐겁지 않다.',
        '나는 어떠한 것에서도 만족을 느끼지 못한다.',
        '나는 모든 것이 싫고 불만스럽다.'
      ]
    }
  ];


  @override
  void initState() {
    super.initState();
    // 제출하지 않고 페이지를 벗어났을 때 이전에 선택했던 답을 저장하고 있어야 함
  }

  // 총점 계산
  int getTotalScore() {
    return answers.where((value) => value != -1).fold(0, (sum, value) => sum + value);
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
      "solvedCount": 0
    }, SetOptions(merge: true));
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
                    '우울 척도 BDI',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '다음 문항을 읽어보고, 자신의 상태를\n잘 나타내는 곳에 표시를 하시오',
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
                    child: ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, questionIndex){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: List.generate(questions[index]['options'].length, (index) {
                                return RadioListTile<int>(
                                  title: Text(questions[index]['options'][index]),
                                  value: index,
                                  groupValue: answers[index],
                                  onChanged: (int? value) {
                                    setState(() => answers[index] = value!);
                                  },
                                );
                              }),
                            ),
                          ],
                        );
                      }
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

