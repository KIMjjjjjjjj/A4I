import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/test_result_page.dart';

import 'explain_test.dart';

class SelectTestPage extends StatefulWidget {
  @override
  _SelectTestPageState createState() => _SelectTestPageState();
}

class _SelectTestPageState extends State<SelectTestPage> {
  User? user = FirebaseAuth.instance.currentUser;
  int solvedCount1 = 0;
  int solvedCount2 = 0;
  int solvedCount3 = 0;
  int solvedCount4 = 0;

  @override
  void initState() {
    super.initState();
    loadTestData();
  }

  // 현재 테스트 진행 상황 불러오기
  Future<void> loadTestData() async {
    List<String> testTypes = ["ASI", "BDI", "PSS", "SSI"];
    Map<String, int> solvedCounts = {"ASI": 0, "BDI": 0, "PSS": 0, "SSI": 0};

    for (String testType in testTypes) {
      DocumentSnapshot<Map<String, dynamic>> testDoc = await FirebaseFirestore.instance
          .collection("test")
          .doc(user!.uid)
          .collection(testType)
          .doc("questions")
          .get();

      if (testDoc.exists && testDoc.data()!.containsKey("solvedCount")) {
        solvedCounts[testType] = testDoc["solvedCount"];
      }
    }

    setState(() {
      solvedCount1 = solvedCounts["ASI"]!;
      solvedCount2 = solvedCounts["BDI"]!;
      solvedCount3 = solvedCounts["PSS"]!;
      solvedCount4 = solvedCounts["SSI"]!;
    });
  }

  // 새로운 테스트 회차 생성
  Future<void> startNewTest(String selectTest) async {
    int currentRound = 1;

    DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
        .collection("test")
        .doc(user?.uid)
        .collection(selectTest)
        .doc("score");

    DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    if(snapshot.exists){
      Map<String, dynamic>? data = snapshot.data();
      if (data != null && data.isNotEmpty) {
        List<int> existingRounds = data.keys
            .where((key) => int.tryParse(key) != null)
            .map((key) => int.parse(key))
            .toList();
        if (existingRounds.isNotEmpty) {
          currentRound = existingRounds.reduce((a, b) => a > b ? a : b);

          int currentScore = data.containsKey("$currentRound") ? data["$currentRound"] : 0;

          if(currentScore > 0) {
            currentRound += 1;
          }
        }
      }
    }
    await docRef.set({
      "$currentRound": 0,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            "심리 테스트",
            style: TextStyle(fontSize: 20)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "이대로 괜찮을까?\n나를 알아보고 싶다면",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 12),
              Text(
                  "무료 심리테스트를 진행하세요",
                  style: TextStyle(fontSize: 15)
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFEAEBF0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: [
                        _buildTestCard("ASI", "불안 민감성 척도", solvedCount1, 16, 10,
                            "이 척도는 불안과 관련된 증상을 경험할 때 그 증상으로 인해 얼마나 두렵고 염려되는가를 평가하는 검사로서 불안 증상에 대해 개인이 가지고 있는 두려움을 반영한다."),
                        _buildTestCard("BDI", "우울 척도", solvedCount2, 21, 10,
                            "이 척도는 우울 증상의 정도를 측정하는 도구로서 현재 임상에서도 우울증 환자에서 사용되고 있는 척도이다. 1961년 Beck이 임상적인 우울 증상을 토대로 우울증의 유형과 정도를 측정하기 위해 개발한 것으로 전 세계적으로 널리 사용되고 있다. BDI는 우울증의 인지적, 정서적, 동기적, 신체적 증상 영역을 포함하는 21개의 문항으로 구성되어 있다."),
                        _buildTestCard("PSS", "스트레스 자각 척도", solvedCount3, 10, 10,
                            "이 척도는 지난 1개월 동안 피험자가 지각한 스트레스 경험에 대해 5점 likert척도로 평가하는 14문항 설문지로 1983년 Cohen 등에 의해 개발되어 신뢰도와 타당도가 입증되었다. "),
                        _buildTestCard("SSI", "자살생각 검사 척도", solvedCount4, 19, 10,
                            "이 척도는 개인이 경험하는 자살 사고의 정도를 측정하는 도구로서 임상 및 연구 환경에서 자살 위험을 평가하고 치료 방향을 설정하는 데 도움을 주고 있다."),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:(){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TestResultPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6BE5A0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                    ),
                    child: Text(
                        "결과 보러가기",
                        style: TextStyle(fontSize: 18, color: Colors.black)
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(String title, String subtitle, int solvedCount, int totalCount, int minute, String description){
    return Container(
      padding: EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton(
          onPressed: () {
            startNewTest(title);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExplainTestPage(
                title: title,
                subtitle: subtitle,
                totalCount: totalCount,
                description: description,
              )),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),
            ),
            padding: const EdgeInsets.all(14),
            minimumSize: Size(150, 50),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)
              ),
              Text(
                  subtitle,
                  style: TextStyle(fontSize: 15, color: Colors.black)
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value: solvedCount/totalCount,
                          backgroundColor: Color(0xFFD9D9D9),
                          color: Color(0xFF6BE5A0),
                          borderRadius: BorderRadius.circular(20),
                          minHeight: 20,
                        ),
                      ),
                    ),
                    Center(
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.edit, color: Colors.black),
                            Text(
                              "심리검사",
                              style: TextStyle(fontSize: 14, color: Color(0xFF374957)),
                            ),
                            SizedBox(width: 20),
                            Text(
                              "$totalCount문항 $minute분",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}