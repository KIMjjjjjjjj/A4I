import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'day_report.dart';

class weekreport extends StatefulWidget {
  @override
  _weekreport createState() => _weekreport();
}

class _weekreport extends State<weekreport> {
  String selectedEmotion = "긍정적";
  final List<String> emotions = ["긍정적", "낙관적", "부정적", "비관적", "기타"];

  final TextEditingController percentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.event, color: Colors.black),
          onPressed: () async {
            final selectedDate  = await showDatePicker(
              context: context,
              initialDate: DateTime(2025, 1, 1),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
          },
        ),
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
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => dayreport()),
              );
            },
            child: Text("일일리포트", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
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
                  Text("2025년 01월 22일부터 2025년 01월 29일까지", style: TextStyle(fontSize: 14)),
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
                  Text("얼마나 많은 변화가 있었을까요?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: ["긍정적", "낙관적", "부정적", "비관적", "기타"].map((test) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedEmotion = test;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedEmotion == test ? Colors.white : Color(0xFFEAEBF0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              fixedSize: Size(90, 40),
                            ),
                            child: Text(
                              test,
                              style: TextStyle(fontSize: 12, color: Color(0xFFAAA4A5), fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        backgroundColor: Color(0xFFEAEBF0),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 20),
                              FlSpot(1, 25),
                              FlSpot(2, 30),
                              FlSpot(3, 35),
                              FlSpot(4, 50),
                            ],
                            isCurved: true,
                            color: Color(0xFF8979FF),
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8979FF),
                                  Color(0xFFEAEBF0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("대화 주제", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var text in ["1. 대인 관계 문제", "2. 진로 고민", "3. 스케줄 관리"])
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("가장 많이 사용한 단어", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var text in ["1. 긍정적", "2. 낙관적", "3. 부정적", "4. 비관적", "5. 기타"])
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                    ],
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
