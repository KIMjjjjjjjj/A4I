import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/select_test.dart';
import 'package:repos/main.dart';
import '../../bottom_navigation_bar.dart';

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
      'options': [
        '보통 혹은 많이 있다.',
        '약간 있다.',
        '전혀 없다.'
      ]
    },

    {
      'question': '죽고 싶은 소망은?',
      'options': [
        '전혀 없다.',
        '약간 있다.',
        '보통 혹은 많이 있다.'
      ]
    },

    {
      'question': '살고 싶은 이유 / 죽고 싶은 이유는?',
      'options': [
        '사는 것이 죽는 것보다 낫기 때문이다.',
        '사는 것이나 죽는 것이나 마찬가지다.',
        '죽는 것이 사는 것보다 낫기 때문이다.'
      ]
    },

    {
      'question': '실제로 자살 시도를 하려는 욕구가 있는가?',
      'options': [
        '전혀 없다.',
        '약간 있다.',
        '보통 혹은 많이 있다.'
      ]
    },

    {
      'question': '별로 적극적이지는 않고 수동적인 자살 욕구가 생길 때는?',
      'options': [
        '생명을 건지기 위해 필요한 조치를 미리 할 것이다.',
        '삶과 죽음을 운명에 맡기겠다.',
        '살기 위한 노력을 하지 않겠다.'
      ]
    },

    {
      'question': '자살하고 싶은 생각이나 소망이 얼마나 오랫동안 지속되는가?',
      'options': [
        '잠깐 그런 생각이 들다가 곧 사라진다.',
        '한 동안 그런 생각이 계속 된다.',
        '계속, 거의 항상 그런 생각이 지속된다.'
      ]
    },

    {
      'question': '얼마나 자주 자살하고 싶은 생각이 드는가?',
      'options': [
        '거의 그런 생각이 들지 않는다.',
        '가끔 그런 생각이 든다.',
        '그런 생각이 계속 지속된다.'
      ]
    },

    {
      'question': '자살 생각이나 소망에 대한 당신의 태도는?',
      'options': [
        '절대로 받아 들이지 않겠다.',
        '양가적이나 크게 개의치 않는다.',
        '그런 생각을 받아 들인다.'
      ]
    },

    {
      'question': '자살하고 싶은 충동을 통제할 수 있는가?',
      'options': [
        '충분히 통제할 수 있다.',
        '통제할 수 있을지 확신할 수 없다.',
        '전혀 통제할 수 없을 것 같다.'
      ]
    },

    {
      'question': '실제로 자살 시도하는 것에 대한 장애물이 있다면? (예시: 가족, 종교 등)',
      'options': [
        '장애물 때문에 자살 시도를 하지 않을 것이다.',
        '장애물 때문에 조금은 마음이 쓰인다.',
        '장애물에 개의치 않는다.'
      ]
    },

    {
      'question': '자살에 대해 깊게 생각해 본 이유는?',
      'options': [
        '생각해 본 적이 없다.',
        '사람들의 관심을 끌고 보복하기 위해.',
        '현실 도피적인 문제 해결 방법으로.'
      ]
    },

    {
      'question': '자살에 대해 깊게 생각했을 때 구체적인 방법까지 계획했는가?',
      'options': [
        '자살에 대해 생각해 본 적이 없다.',
        '자살을 생각했으나 구체적인 방법까지는 생각하지 않았다.',
        '구체적인 방법을 제시하고 치밀하게 생각해 놓았다.'
      ]
    },

    {
      'question': '자살 방법을 깊게 생각했다면 그것이 얼마나 현실적으로 실현 가능하며, 또한 시도할 기회가 있다고 생각하는가?',
      'options': [
        '방법도 현실적으로 실현 불가능하고 기회도 없을 것이다.',
        '방법이 시간과 노력이 필요하고 기회가 쉽게 오지 않을 것이다.',
        '생각한 방법이 현실적으로 실현 가능하며 기회도 있을 것이다.'
      ]
    },

    {
      'question': '실제로 자살을 할 수 있는 능력이 있다고 생각하는가?',
      'options': [
        '용기가 없고 너무 약하며 두렵고 능력이 없어서 자살할 수 없다.',
        '자살할 용기와 능력이 있는지 확신할 수 없다.',
        '자살할 용기와 자신이 있다.'
      ]
    },

    {
      'question': '정말로 자살 시도를 할 것이라고 확신하는가?',
      'options': [
        '없다.',
        '잘 모르겠다.',
        '그렇다.'
      ]
    },

    {
      'question': '자살에 대한 생각을 실행하기 위해 실제로 준비한 것이 있는가?',
      'options': [
        '없다.',
        '부분적으로 했다.',
        '완전하게 준비했다.'
      ]
    },

    {
      'question': '자살하려는 글(유서)를 쓴 적이 있는가?',
      'options': [
        '없다.',
        '쓰기 시작했으나 다 쓰지 못했다.',
        '다 써 놓았다.'
      ]
    },

    {
      'question': '죽음을 예상하고 마지막으로 한 일은 (보험, 유언)?',
      'options': [
        '없다.',
        '생각만 해 보았거나 약간의 정리를 했다.',
        '확실한 계획을 세웠거나 다 정리를 해 놓았다.'
      ]
    },

    {
      'question': '자살에 대한 생각을 다른 사람들에게 이야기한 적이 있습니까?',
      'options': [
        '자살에 대해 생각해 본 적이 없거나 다른 사람에게 터놓고 이야기 하였다.',
        '드러내는 것을 주저하다가 숨겼다.',
        '그런 생각을 속이고, 숨겼다.'
      ]
    },
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) =>  CustomNavigationBar()),
                (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
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
    );
  }
}
