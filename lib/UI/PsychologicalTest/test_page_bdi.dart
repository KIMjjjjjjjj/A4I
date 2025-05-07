import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/select_test.dart';
import '../../bottom_navigation_bar.dart';

class TestPageBdi extends StatefulWidget {
  @override
  _TestPageBdiState createState() => _TestPageBdiState();
}

class _TestPageBdiState extends State<TestPageBdi> {
  User? user = FirebaseAuth.instance.currentUser;
  String testType = 'BDI';
  ScrollController scrollController = ScrollController();
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
        '나는 요즘에는 어떤 것에도 별로 만족을 얻지 못한다.',
        '나는 모든 것이 다 불만스럽고 지겹다.'
      ]
    },
    {
      'options': [
        '나는 특별히 죄책감을 느끼지 않는다.',
        '나는 죄책감을 느낄 때가 많다.',
        '나는 죄책감을 느낄 때가 아주 많다',
        '나는 항상 죄책감에 시달리고 있다.'
      ]
    },
    {
      'options': [
        '나는 벌을 받고 있다고 느끼지 않는다.',
        '나는 어쩌면 벌을 받을 지도 모른다는 느낌이 든다.',
        '나는 벌을 받아야 한다고 느낀다.',
        '나는 지금 벌을 받고 있다고 느낀다.'
      ]
    },
    {
      'options': [
        '나는 나 자신에게 실망하지 않는다.',
        '나는 나 자신에게 실망하고 있다.',
        '나는 나 자신에게 화가 난다.',
        '나는 나 자신을 증오한다.'
      ]
    },    {
      'options': [
        '내가 다른 사람보다 못한 것 같지는 않다.',
        '나는 나의 약점이나 실수에 대해서 나 자신을 탓하는 편이다.',
        '내가 한 일이 잘못 되었을 때는 언제나 나를 탓한다.',
        '일어나는 모든 나쁜 일들은 모두 내 탓이다.'
      ]
    },    {
      'options': [
        '나는 자살 같은 것은 생각하지 않는다.',
        '나는 자살할 생각을 가끔 하지만 실제로 하지는 않을 것이다.',
        '자살하고 싶은 생각이 자주 든다.',
        '나는 기회가 있으면 자살하겠다.'
      ]
    },    {
      'options': [
        '나는 평소보다 더 울지는 않는다.',
        '나는 전보다 더 많이 운다.',
        '나는 요즘 항상 운다.',
        '나는 전에는 울고 싶을 때 울 수 있었지만 요즘에는 울래야 울 기력조차 없다.'
      ]
    },    {
      'options': [
        '나는 요즘 평소보다 더 짜증을 내는 편은 아니다.',
        '나는 전보다 더 쉽게 짜증이 나고 귀찮아진다.',
        '나는 요즘 항상 짜증스럽다.',
        '전에는 짜증스럽던 일에 요즘은 너무 지쳐서 짜증조차 나지 않는다.'
      ]
    },

    {
      'options': [
        '나는 다른 사람들에 대한 관심을 잃지 않고 있다.',
        '나는 전보다 사람들에 대한 관심이 줄었다.',
        '나는 사람들에 대한 관심이 거의 없어졌다.',
        '나는 사람들에 대한 관심이 완전히 없어졌다.'
      ]
    },

    {
      'options': [
        '나는 평소처럼 결정을 잘 내린다.',
        '나는 결정을 미루는 때가 전보다 많다.',
        '나는 전에 비해 결정을 내리는 데 큰 어려움을 느낀다.',
        '나는 더 이상 아무 결정도 내릴 수 없다.'
      ]
    },

    {
      'options': [
        '나는 전보다 내 모습이 나빠졌다고 생각지 않는다.',
        '나는 매력 없어 보일까봐 걱정한다.',
        '나는 내 모습이 매력 없게 변해버린 것 같은 느낌이 든다.',
        '나는 내가 추하게 보인다고 믿는다.'
      ]
    },

    {
      'options': [
        '나는 전처럼 일을 할 수 있다.',
        '어떤 일을 시작하는 데는 전보다 많은 노력이 든다.',
        '무슨 일이든 하려면 나 자신을 매우 심하게 채찍질해야만 한다.',
        '나는 전혀 아무 일도 할 수가 없다.'
      ]
    },

    {
      'options': [
        '나는 평소처럼 잠을 잘 수 있다.',
        '나는 전에 만큼 잠을 자지는 못한다.',
        '나는 전보다 일찍 깨고 다시 잠들지 못한다.',
        '나는 평소보다 몇 시간이나 일찍 깨고 한번 깨면 다시 잠들 수 없다.'
      ]
    },

    {
      'options': [
        '나는 평소보다 더 피곤하지는 않다.',
        '나는 전보다 더 쉽게 피곤해진다.',
        '나는 무엇을 해도 피곤해진다.',
        '나는 너무나 피곤해서 아무 일도 할 수 없다.'
      ]
    },

    {
      'options': [
        '내 식욕은 평소와 다름 없다.',
        '나는 요즘 전보다 식욕이 좋지 않다.',
        '나는 요즘 식욕이 많이 떨어졌다.',
        '요즘에는 전혀 식욕이 없다.'
      ]
    },

    {
      'options': [
        '요즘 체중이 별로 줄지 않았다.',
        '전보다 몸무게가 2kg 가량 줄었다.',
        '전보다 몸무게가 5kg 가량 줄었다.',
        '전보다 몸무게가 7kg 가량 줄었다.'
      ]
    },
    {
      'options': [
        '나는 건강에 대해 전보다 더 염려하고 있지는 않다.',
        '나는 여러가지 통증, 소화 불량, 변비 등과 같은 신체적 문제로 걱정하고 있다.',
        '나는 건강이 너무 염려되어 다른 일은 생각하기 힘들다.',
        '나는 건강이 너무 염려되어 다른 일은 아무 것도 생각할 수가 없다.'
      ]
    },
    {
      'options': [
        '나는 요즘 성(sex)에 대한 관심에 별다른 변화가 없다.',
        '나는 전보다 성(sex)에 대한 관심이 줄었다.',
        '나는 전보다 성(sex)에 대한 관심이 상당히 줄었다.',
        '나는 성(sex)에 대한 관심을 완전히 잃었다.'
      ]
    },

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
        .doc("questions");

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
        firstUnansweredIndex * 300,
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) =>  CustomNavigationBar()),
                      (route) => false,
                );
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
                      controller: scrollController,
                      itemBuilder: (context, questionIndex) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${questionIndex + 1}.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: List.generate(questions[questionIndex]['options'].length, (optionIndex) {
                                bool isSelected = answers[questionIndex] == optionIndex;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0.1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFFCFF7D3) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: RadioListTile<int>(
                                      title: Text(
                                        questions[questionIndex]['options'][optionIndex],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      value: optionIndex,
                                      groupValue: answers[questionIndex],
                                      onChanged: (int? value) {
                                        setState(() {
                                          answers[questionIndex] = value!;
                                        });
                                        saveAnswer(questionIndex, value!);
                                      },
                                      activeColor: Colors.green,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        );
                      },
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
