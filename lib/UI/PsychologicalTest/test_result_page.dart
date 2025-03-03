import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TestResultPage extends StatefulWidget {
  @override
  _TestResultPageState createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  User? user = FirebaseAuth.instance.currentUser;
  List<double> points = [];
  List<String> labels = [];
  String SelectTest = "ASI";
  String TestDescription = "ASI";
  String nickname = "";

  @override
  void initState() {
    super.initState();
    loadNickname();
    loadData();
  }

  Future<void> loadNickname() async {
    try {
      if (user == null) return;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection("register")
          .doc(user?.uid)
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

  Future<void> loadData() async {
    try {
      if (user == null) return;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection("test")
          .doc(user?.uid)
          .collection(SelectTest)
          .doc("score")
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        if (data != null) {
          List<int> key = data.keys.map((key) => int.parse(key)).toList();
          List<double> newPoints = key.map((key) => (data[key.toString()] as num).toDouble()).toList();
          List<String> newLabels = key.map((key) => "$key회차").toList();

          setState(() {
            points = newPoints;
            labels = newLabels;
            TestDescription = TestResult(SelectTest);
          });
        }
      }
    } catch (e) {
      print("오류");
    }
  }

  String TestResult(String test) {
    switch (test) {
      case "ASI":
        return
          "16-20점: 불안 자극에 약간 민감하게 반응\n"
              "21-24점: 불안 자극에 상당히 민감하게 반응\n"
              "25점 이상: 불안 자극에 매우 민감하게 반응\n";

      case "BDI":
        return
          "17점 이하: 정상\n"
              "18-25점: 경도의 스트레스\n"
              "26점 이상: 고도의 스트레스\n";

      case "PSS":
        return
          "0-10점: 정상\n"
              "11-16점: 가벼운 기분 장애\n"
              "17-20점: 임상적 경계성 우울\n"
              "21-30점: 중증 정도의 우울증\n"
              "31-40점: 심한 우울증\n"
              "41점 이상: 극도의 우울증\n";

      case "SSI":
        return
          "*성인 기준\n"
              "9-11점: 연령 집단에 비해 자살 생각을 많이 함\n"
              "12-14점: 연령 집단에 비해 자살 생각을 상당히 많이 함\n"
              "15점 이상: 연령 집단에 비해 자살 생각을 매우 많이 함\n";
      default:
        return "";
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
          "심리 테스트 결과",
          style: TextStyle(fontSize: 20)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "각 결과를 종합적으로 확인할 수 있어요",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
              ),
              Text(
                "본 결과지는 참고용이며, 필요시 전문가와 상담하세요\n",
                style: TextStyle(fontSize: 14)
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFEAEBF0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ["ASI", "BDI", "PSS", "SSI"].map((test) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              SelectTest = test;
                            });
                            loadData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SelectTest == test ? Colors.white : Color(0xFFEAEBF0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            test,
                            style: TextStyle(
                                fontSize: 15,
                                color: SelectTest == test ? Colors.black : Color(0xFFAAA4A5)
                            )
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "얼마나 많은 변화가 있었을까요?",
                                style: TextStyle(fontSize: 17, color: Color(0xFF535353), fontWeight: FontWeight.bold)
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: List.generate(
                                  points.length,
                                      (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: points[index],
                                        color: index == points.length - 1
                                            ? Color(0xFF36C574)
                                            : Color(0xFF6BE5A0),
                                        width: 50,
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ],
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        int index = value.toInt();
                                        return Text(labels[index], style: TextStyle(color: Color(0xFF5A5A5A)));
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        return Text("${value.toInt()}", style: TextStyle(fontSize: 15, color: Color(0xFF5A5A5A)));
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                ),
                                extraLinesData: ExtraLinesData(
                                  horizontalLines: [
                                    HorizontalLine(
                                      y: 0,
                                      color: Color(0xFF5A5A5A),
                                      strokeWidth: 0.5,
                                    ),
                                  ],
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              TestDescription,
                              style: TextStyle(fontSize: 14, color: Color(0xFF686767)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            "해설",
                            style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.help_outline, color: Colors.black),
                            iconSize: 17,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    title: Text("${SelectTest}"),
                                    content: Text(TestDescription),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            spreadRadius: 0,
                            blurRadius: 5.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                              "${nickname}님의 ${labels.last} ${SelectTest} 점수는 ${points.last.toInt()}점으로 ".replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
                              style: TextStyle(fontSize: 15)
                          ),
                          Text(
                              "심리 상담을 통해 ‘나’에 대해 자세히 알아보시는 건 어떨까요?".replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
                              style: TextStyle(fontSize: 15)
                          ),
                          SizedBox(height: 15),
                          Center(
                              child: ElevatedButton(
                                onPressed:(){},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6BE5A0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                                  padding: const EdgeInsets.symmetric(horizontal: 70),
                                ),
                                child: Text("심리 상담 바로가기", style: TextStyle(fontSize: 15, color: Colors.black)),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
