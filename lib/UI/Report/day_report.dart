import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:repos/UI/chart/week_report.dart';

import '../diary/calender_page.dart';

class dayreport extends StatefulWidget {
  @override
  _dayreport createState() => _dayreport();
}

class _dayreport extends State<dayreport> {
  String nickname = "";

  @override
  void initState() {
    super.initState();
    loadNickname();
  }

  Future<void> loadNickname() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection("register")
          .doc(userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          nickname = snapshot.data()?["nickname"] ?? "";
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("종합 심리 평가"),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("토리와의 대화를 통해 나의 감정을 객관적으로 확인하고, 그날의 나를 돌아볼 수 있어요!"),
                            Text("일일 보고서는 매일 오전 6시에 갱신돼요."),
                            Text("해당 보고서는 참고용이며, 필요 시 전문가와 상의하세요"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("닫기"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => weekreport()),
            );
          }, child: Text("기간리포트", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))]
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/images/character.png"),
                  ),
                  SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("2025년 01월 28일", style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.event, color: Colors.black),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2025, 1, 1),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                    },
                  ),
                  ],
              ),
                  Text("토리와의 대화에서 마음을 살펴보았어요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEAEBF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("결과", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(maxWidth: 330),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(value: 40, color: Color(0xFF7BD3EA), title: ''),
                                  PieChartSectionData(value: 20, color: Color(0xFFA1EEBD), title: ''),
                                  PieChartSectionData(value: 15, color: Color(0xFFEA7BDF), title: ''),
                                  PieChartSectionData(value: 15, color: Color(0xFFF6F7C4), title: ''),
                                  PieChartSectionData(value: 10, color: Color(0xFFF6D6D6), title: ''),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (var item in [
                                {"color": Color(0xFF7BD3EA), "label": "긍정적"},
                                {"color": Color(0xFFA1EEBD), "label": "낙관적"},
                                {"color": Color(0xFFEA7BDF), "label": "비관적"},
                                {"color": Color(0xFFF6F7C4), "label": "부정적"},
                                {"color": Color(0xFFF6D6D6), "label": "기타"},
                              ])
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: item["color"] as Color,
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      item["label"] as String,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("피드백", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${nickname}님의 오늘의 마음은 긍정적이에요!"),
                          Text("에이브러험 링컨은 이런 말을 했어요."),
                          Text("'내가 걷는 길은 미끄러웠지만, 낭떠러지는 아니야'라고요!"),
                          Text("긍정적인 당신에게 일기를 써보시는건 어떨까요?"),
                          SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CalendarPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("오늘의 일기 쓰러가기", style: TextStyle(color: Colors.white)),
                          ),
                      ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("대화 주제", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${nickname}님은 오늘 '진로'에 대한 고민을 상담했어요!"),
                          Text("두번째로는 '미래의 나'에 대한 고민을 상담했네요!"),
                          Text("다음에는 저랑 더 많은 얘기 나눠요"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("가장 많이 사용한 단어", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${nickname}님이 가장 많이 사용한 긍정적 단어는 '극복하다'에요!"),
                          Text("'낙관적' 단어는 '도전하다'"),
                          Text("'비관적' 단어는 '뒤처지다'"),
                          Text("'부정적' 단어는 '후회하다'에요."),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
