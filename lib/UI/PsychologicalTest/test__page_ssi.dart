import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/select_test.dart';

class TestPageSsi extends StatefulWidget {
  @override
  _TestPageSsiState createState() => _TestPageSsiState();
}

class _TestPageSsiState extends State<TestPageSsi> {
  User? user = FirebaseAuth.instance.currentUser;
  String testType = 'SSI';
  ScrollController scrollController = ScrollController();
  int index = 0;
  List<int> answers = List.filled(19, -1);

  final List<Map<String, dynamic>> questions = [
    {
      'question': '살고 싶은 소망은?',
      'options': ['보통 혹은 많이 있다.', '약간 있다.', '전혀 없다.']
    },
    {
      'question': '죽고 싶은 소망은?',
      'options': ['전혀 없다.', '약간 있다.', '보통 혹은 많이 있다.']
    },
    // 나머지 17개 질문도 똑같이 이어붙이면 됨
  ];

  @override
  void initState() {
    super.initState();
    loadAnswer();
  }

  int getTotalScore() {
    return answers.where((v) => v != -1).fold(0, (sum, v) => sum + v);
  }

  Future<void> saveAnswer(int questionIndex, int selectedOption) async {
    if (user == null) return;
    final questionRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("questions");

    await questionRef.set({
      "$questionIndex": {"선택 문항": selectedOption}
    }, SetOptions(merge: true));
  }

  Future<void> loadAnswer() async {
    final questionRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("questions");

    final snapshot = await questionRef.get();
    if (snapshot.exists && snapshot.data() != null) {
      final savedAnswers = snapshot.data()!;
      setState(() {
        savedAnswers.forEach((key, value) {
          int questionIndex = int.tryParse(key) ?? -1;
          if (questionIndex >= 0 && questionIndex < answers.length) {
            answers[questionIndex] = value["선택 문항"];
          }
        });
      });
    }
  }

  Future<void> progressTest() async {
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("questions");

    await docRef.set({
      "solvedCount": answers.where((v) => v != -1).length,
    }, SetOptions(merge: true));
  }

  Future<bool> submitTest() async {
    int totalScore = getTotalScore();
    int currentRound = 1;

    int firstUnanswered = answers.indexWhere((v) => v == -1);
    if (firstUnanswered != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("모든 문항을 선택하지 않았어요!")));
      scrollController.animateTo(
        firstUnanswered * 300,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return false;
    }

    final docRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user!.uid)
        .collection(testType)
        .doc("score");

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data.isNotEmpty) {
        List<int> rounds = data.keys
            .where((key) => int.tryParse(key) != null)
            .map((key) => int.parse(key))
            .toList();
        if (rounds.isNotEmpty) {
          currentRound = rounds.reduce((a, b) => a > b ? a : b) + 1;
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ⭐️⭐️⭐️ 핵심
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '자살생각 검사 척도 SSI',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 7),
                const Text(
                  '다음 문항을 읽어보고,\n자신의 상태를 잘 나타내는 곳에 표시하시오',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 7),
                const Text('1/1', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question['question']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          ...List.generate(question['options'].length, (optionIndex) {
                            bool selected = answers[index] == optionIndex;
                            return Container(
                              decoration: BoxDecoration(
                                color: selected ? Color(0xFFCFF7D3) : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: RadioListTile<int>(
                                title: Text(question['options'][optionIndex]),
                                value: optionIndex,
                                groupValue: answers[index],
                                onChanged: (value) {
                                  setState(() {
                                    answers[index] = value!;
                                  });
                                  saveAnswer(index, value!);
                                },
                                activeColor: Colors.green,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          progressTest();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SelectTestPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6BE5A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Text('뒤로가기', style: TextStyle(color: Colors.black, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          bool complete = await submitTest();
                          if (complete) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SelectTestPage()));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6BE5A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Text('제출', style: TextStyle(color: Colors.black, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
