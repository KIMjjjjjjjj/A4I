import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'week_report.dart';
import 'report_service.dart';
import 'dart:math';
import '../DayLine/day_line_UI.dart';
import '../Community/community_ui.dart';
import '../diary/calender_page.dart';
import 'report_date_selector.dart';
import 'report_date_service.dart';

class dayreport extends StatefulWidget {
  @override
  _dayreport createState() => _dayreport();
}

class _dayreport extends State<dayreport> {
  String nickname = "";
  DateTime selectedDate = DateTime.now();
  final reportService = ReportService();
  final dateService = ReportDateService();
  Set<DateTime> availableReportDates = {};

  final List<Color> fixedColors = [
    Color(0xFF7BD3EA), // 1위 감정
    Color(0xFFA1EEBD), // 2위 감정
    Color(0xFFEA7BDF), // 3위 감정
    Color(0xFFF6F7C4), // 4위 감정
    Color(0xFFF6D6D6), // 5위 감정
  ];

  final random = Random();
  final options = [
    {
      "label": "오늘의 일기 쓰러가기",
      "text": "오늘 감정을 기록해보는 건 어떨까요?",
      "route": CalendarPage(),
    },
    {
      "label": "오늘 한줄 쓰러가기",
      "text": "오늘의 나에게 짧게 한 줄 남겨보는 건 어떨까요?",
      "route": DayLineScreen(),
    },
    {
      "label": "커뮤니티로 이동하기",
      "text": "다른 사람들과 이야기를 나눠보는 건 어떨까요?",
      "route": CommunityScreen(),
    },
  ];


  Map<String, double>? emotionData; // key : 일반화된 감정 value : 카테고리 비율
  String? feedback;                 // GPT 요약 피드백
  List<String>? topics;             // 상위 3개의 키워드
  List<String>? words;              // 상위 3개의 토픽

  @override
  void initState() {
    super.initState();
    loadNickname(); // 유저 닉네임 조회
    loadReport(selectedDate); // 초기에는 오늘 날짜로 데이터 불러오기
    loadAvailableDates(); // 선택 가능한 날짜 조회
  }

  // 파이어베이스에서 리포트 불러오기
  void loadReport(DateTime date) async {
    final report = await reportService.fetchReport(date);
    if (report != null) {
      setState(() {
        emotionData = report.emotionData;
        feedback = report.feedback;
        topics = report.topics;
        words = report.keywords;
      });
    } else {
      setState(() {
        emotionData = {};
        feedback = null;
        topics = null;
        words = null;
      });
    }
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

  Future<void> loadAvailableDates() async {
    final service = ReportDateService();
    final dates = await service.fetchAvailableReportDates();
    setState(() {
      availableReportDates = dates;
    });
  }

  // 차트 메서드
  Widget buildPieChart() {
    if (emotionData == null || emotionData!.isEmpty) {
      return Text("데이터가 없습니다");
    }

    // 감정 비율 높은 순으로 정렬
    final entries = emotionData!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEmotion = entries.first.key;
    final topPercentage = (entries.first.value * 100).round();

    return Column(
      children: [
        // ✅ Stack으로 차트와 중앙 텍스트를 겹쳐서 표시
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: PieChart(
                PieChartData(
                  sections: List.generate(entries.length, (index) {
                    final entry = entries[index];
                    return PieChartSectionData(
                      value: entry.value,
                      color: fixedColors[index],
                      title: '',
                    );
                  }),
                  centerSpaceRadius: 60,
                  sectionsSpace: 0,
                  centerSpaceColor: Colors.white,
                ),
              ),
            ),
            // ✅ 차트 중앙 텍스트
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${topPercentage}%",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  topEmotion,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA5A5A5), // 연한 회색
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 20),

        // ✅ 감정 라벨과 색상 표시
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: fixedColors[index],
                    shape: BoxShape.rectangle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // GPT 피드백 텍스트 UI
  Widget buildFeedback() {
    if (feedback == null || emotionData == null || emotionData!.isEmpty) {
      return const SizedBox.shrink();
    }

    final randomOption = options[random.nextInt(options.length)];
    final sortedEmotions = emotionData!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotion = sortedEmotions.first.key;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                Text("${nickname}님의 오늘의 마음은 ${topEmotion}이에요!"),
                Text(feedback!, style: const TextStyle(fontSize: 14),),
                Text(randomOption["text"] as String),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  randomOption["route"] as Widget),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      randomOption["label"] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 토픽 UI
  Widget buildTopics() {
    if (topics == null || topics!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                Text("${nickname}님은 오늘 ${topics![0]}에 대한 고민을 상담했어요!"),
                Text("또 ${topics![1]}와 ${topics![2]} 대한 고민을 상담했네요!"),
                Text("다음에는 저랑 더 많은 얘기 나눠요"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 키워드 UI
  Widget buildKeywords() {
    if (words == null || words!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                Text(
                  "${nickname}님이 최근 자주 사용한 단어는 "
                      "'${words![0]}', '${words![1]}', '${words![2]}'이에요.",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                            Text("하루와의 대화를 통해 나의 감정을 객관적으로 확인하고, 그날의 나를 돌아볼 수 있어요!"),
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
                      ReportDateSelector(
                        selectedDate: selectedDate,
                        availableReportDates: availableReportDates,
                        onDateSelected: (pickedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                          loadReport(pickedDate);
                        },
                      ),
                    ],
                  ),
                  Text("하루와의 대화에서 마음을 살펴보았어요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Text("감정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: BoxConstraints(maxWidth: 330),
                      child: buildPieChart(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("피드백", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildFeedback(),
                  SizedBox(height: 20),
                  Text("토픽", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildTopics(),
                  SizedBox(height: 20),
                  Text("키워드", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildKeywords(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
