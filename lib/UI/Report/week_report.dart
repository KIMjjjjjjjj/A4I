import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:repos/UI/Report/report_date_range_selector.dart';
import 'day_report.dart';

class weekreport extends StatefulWidget {
  @override
  _weekreport createState() => _weekreport();
}

class _weekreport extends State<weekreport> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<String> topTopics = [];
  List<String> topKeywords = [];
  List<FlSpot> emotionSpots = [];
  DateTime? _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime? _endDate = DateTime.now();
  String selectedEmotion = "두려움";
  final List<String> emotions = ["두려움", "슬픔", "놀람", "분노", "기쁨", "기타"];
  final TextEditingController percentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAnalysisData();
  }

  Future<void> selectEmotionData(String emotion) async {
    List<Map<String, dynamic>> data = await loadAnalysisData(_startDate!, _endDate!);
    setState(() {
      selectedEmotion = emotion;
      emotionSpots = getEmotions(data, emotion);
    });
  }

  Future<void> fetchAnalysisData() async {
    List<Map<String, dynamic>> data = await loadAnalysisData(_startDate!, _endDate!);
    setState(() {
      topTopics = getTopTopics(data, 3);
      topKeywords = getTopKeywords(data, 5);
      emotionSpots = getEmotions(data, selectedEmotion);
    });
  }

  // 기간별 분석 데이터 조회
  Future<List<Map<String, dynamic>>> loadAnalysisData(DateTime startDate, DateTime endDate) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("register")
        .doc(user?.uid)
        .collection("chat")
        .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where("timestamp", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy("timestamp")
        .get();

    final List<Map<String, dynamic>> analysisData = querySnapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    return analysisData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.event, color: Colors.black),
          onPressed: () async {
            final pickedRange = await DateRangePicker.selectDateRange(context);
            if (pickedRange != null) {
              setState(() {
                _startDate = pickedRange.start;
                _endDate = pickedRange.end;
              });
            }
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
                  Text('${DateFormat('yyyy.MM.dd').format(_startDate!)} ~ ${DateFormat('yyyy.MM.dd').format(_endDate!)}', style: TextStyle(fontSize: 16)),
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
                      children: emotions.map((test) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedEmotion = test;
                                selectEmotionData(test);
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
                            spots: emotionSpots,
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
                      for (int i = 0; i < topTopics.length; i++)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('${i + 1}. ${topTopics[i]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                      for (int i = 0; i < topKeywords.length; i++)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('${i + 1}. ${topKeywords[i]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  // 감정 강도 추이 변화
  List<FlSpot> getEmotions(List<Map<String, dynamic>> data, String emotion) {
    final filtered = data
        .where((doc) => doc['emotion'] == emotion)
        .toList();

    filtered.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
    List<FlSpot> spots = [];

    for (int i = 0; i < filtered.length; i++) {
      final intensity = filtered[i]['emotion_intensity'] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), intensity.toDouble()));
    }
    return spots;
  }

  // 토픽 빈도 Top3
  List<String> getTopTopics(List<Map<String, dynamic>> data, int n) {
    final Map<String, int> topicCounts = {};
    for (var doc in data) {
      if (doc['topic'] != null) {
        final topics = doc['topic'].split(',').map((t) => t.trim());
        for (var topic in topics) {
          topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
        }
      }
    }
    final sorted = topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).map((e) => e.key).toList();
  }

  // 키워드 Top5
  List<String> getTopKeywords(List<Map<String, dynamic>> data, int n) {
    final Map<String, int> keywordCounts = {};
    for (var doc in data) {
      if (doc['keywords'] != null) {
        for (String keword in List<String>.from(doc['keywords'])) {
          keywordCounts[keword] = (keywordCounts[keword] ?? 0) + 1;
        }
      }
    }
    final sorted = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).map((e) => e.key).toList();
  }
}
