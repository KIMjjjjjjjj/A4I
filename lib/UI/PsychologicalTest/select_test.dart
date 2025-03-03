import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/test_result_page.dart';

import 'explain_test.dart';

class SelectTestPage extends StatefulWidget {
  @override
  _SelectTestPageState createState() => _SelectTestPageState();
}

class _SelectTestPageState extends State<SelectTestPage> {
  User? user = FirebaseAuth.instance.currentUser;
  int solvedCount = 0;
  String SelectTest = "ASI";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      if (user == null) {
        return;
      }
      DocumentSnapshot testDoc = await FirebaseFirestore.instance
          .collection("test")
          .doc(user?.uid)
          .collection(SelectTest)
          .doc("score")
          .get();

      if (testDoc.exists) {
        setState(() {
          solvedCount = testDoc['solvedCount'];
        });
      }
    } catch (e) {
      print("오류");
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "이대로 괜찮을까?\n나를 알아보고 싶다면",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 12),
              Text(
                  "무료 심리테스트를 진행하세요",
                  style: TextStyle(fontSize: 14)
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
                        _buildTestCard("ASI", "불안 민감성 척도", solvedCount, 16, 5),
                        _buildTestCard("BDI", "우울 척도", solvedCount, 10, 5),
                        _buildTestCard("PSS", "스트레스 자각 척도", solvedCount, 21, 5),
                        _buildTestCard("SSI", "자살생각 검사 척도", solvedCount, 19, 5),
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
                        "심리 상담 바로가기",
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

  Widget _buildTestCard(String title, String subtitle, int solvedCount, int totalCount, int minute){
    return Container(
      padding: EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExplainTestPage()),
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
