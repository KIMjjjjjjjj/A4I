import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bottom_navigation_bar.dart';
import '../HelpCenter/help_center_ui.dart';
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
  DateTime? selectedDate;
  Set<DateTime> availableReportDates = {};
  final reportService = ReportService();
  final dateService = ReportDateService();


  final List<Color> fixedColors = [
    Color(0xFF7BD3EA), // 1위 감정
    Color(0xFFA1EEBD), // 2위 감정
    Color(0xFFEA7BDF), // 3위 감정
    Color(0xFFF6F7C4), // 4위 감정
    Color(0xFFF6D6D6), // 5위 감정
    Color(0xFFFF8A00), // 6위 감정
  ];

  final random = Random();
  final options = {
    "기쁨":[
      {
      "label": "오늘의 일기 쓰러가기",
      "text": "오늘의 좋은 감정을 일기에 기록해보는 건 어때요?",
      "route": CalendarPage(),
      },
      {
      "label": "오늘 한줄 쓰러가기",
      "text": "오늘의 좋은 기분을 더 오래 간직하고 싶지 않나요? 오늘의 한 줄을 작성해보세요.",
      "route": DayLineScreen(),
      },
      {
      "label": "커뮤니티로 이동하기",
      "text": "행복은 나눌수록 커져요. 다른 사람들과 기쁨을 나눠보는 건 어떤가요?",
      "route": CommunityScreen(),
      }
    ],
    "슬픔": [
      {
      "label": "오늘 한줄 쓰러가기",
      "text": "마음이 무거운 날엔 짧은 글 한 줄이 위로가 되어줄 수 있어요. 오늘의 나에게 짧게 한 줄 남겨보는 건 어때요?",
      "route": DayLineScreen(),
      },
      {
      "label": "커뮤니티로 이동하기",
      "text": "슬픔은 나눌수록 가벼워져요. 다른 사람들과 마음을 나누어보세요.",
      "route": CommunityScreen(),
      },
      {
      "label": "근처 도움센터 찾아보기",
      "text": "도움이 필요하다면 근처 도움센터를 안내해드릴게요. 전문가에게 도움을 받아보는 건 어떨까요?",
      "route": HelpCenterPage(),
      },
    ],
    "분노": [
      {
      "label": "오늘 한줄 쓰러가기",
      "text": "분노는 자연스러운 감정이에요. 짧은 문장이 마음을 정리하는 데 도움이 될 수 있어요.",
      "route": DayLineScreen(),
      },
      {
      "label": "근처 도움센터로 찾아보기",
      "text": "도저히 감당하기 힘든 마음이라면 근처 도움센터를 안내해드릴요. 전문가에게 도움을 받아보는 건 어떨까요?",
      "route": HelpCenterPage(),
      },
    ],
    "두려움": [
      {
      "label": "커뮤니티로 이동하기",
      "text": "오늘 느낀 감정에 대해 다른 사람들과 이야기를 나눠보는 건 어떨까요?",
      "route": CommunityScreen(),
      },
      {
      "label": "근처 도움센터로 찾아보기",
      "text": "두려운 마음이 크다면, 전문가에게 도움을 받아보는 건 어떨까요? 근처 도움센터를 안내해드릴요.",
      "route": HelpCenterPage(),
      },
    ],
    "놀람": [
      {
        "label": "오늘의 일기 쓰러가기",
        "text": "오늘의 놀란 마음을 차분하게 일기로 써보세요. 감정을 정리하는 데 도움이 될 거예요.",
        "route": CalendarPage(),
      },
      {
        "label": "커뮤니티로 이동하기",
        "text": "비슷한 경험을 나눈 사람들의 이야기를 들어보는 것도 도움이 될 거예요. 다른 사람들과 이야기를 나눠보세요.",
        "route": CommunityScreen(),
      },
    ],
    "default": [
      { "label": "오늘의 일기 쓰러가기", "text": "오늘도 수고했어요. 감정을 정리해볼까요?", "route": CalendarPage() },
    ]
  };


  Map<String, double>? emotionData; // key : 일반화된 감정 value : 카테고리 비율
  String? feedback;                 // GPT 요약 피드백
  List<String>? topics;             // 상위 3개의 키워드
  List<String>? words;              // 상위 3개의 토픽
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeReportDates();
    loadNickname(); // 유저 닉네임 조회
  }
  Future<void> initializeReportDates() async {
    final dates = await reportService.getAvailableReportDates(); // Firestore에서 날짜 가져오는 함수
    if (dates.isNotEmpty) {
      final normalizedToday = DateTime.now();
      final normalizedDates = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

      // 오늘 날짜가 포함되어 있으면 선택, 아니면 가장 최근 날짜
      final initial = normalizedDates.contains(normalizedToday)
          ? normalizedToday
          : normalizedDates.reduce((a, b) => a.isAfter(b) ? a : b);

      setState(() {
        availableReportDates = normalizedDates;
        selectedDate = initial;
        isLoading = false;
      });

      loadReport(initial);
    } else {
      // 리포트가 하나도 없는 경우
      setState(() {
        isLoading = false;
      });
    }
  }
  // 파이어베이스에서 리포트 불러오기
  void loadReport(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final report = await reportService.fetchReport(normalizedDate);
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
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

  // 차트 메서드
  Widget buildPieChart() {
    if (emotionData == null || emotionData!.isEmpty) {
      return Text("데이터가 없습니다");
    }

// 감정 비율 높은 순으로 정렬
    final entries = emotionData!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

// 최대 6개의 감정까지만 표시 (fixedColors에 맞춰)
    final displayEntries = entries.take(6).toList();

/*    final topEmotion = entries.first.key;
    final topPercentage = (entries.first.value * 100).round();*/

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: List.generate(displayEntries.length, (index) {
                    final entry = displayEntries[index];
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(displayEntries.first.value * 100).round()}%",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  displayEntries.first.key,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA5A5A5),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(displayEntries.length, (index) {
            final entry = displayEntries[index];
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${nickname}님의 오늘의 마음은 ${topEmotion}이에요!"),
                Text(feedback!, style: const TextStyle(fontSize: 14),),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 추천활동 UI
  Widget buildRecommendation() {
    if (feedback == null || emotionData == null || emotionData!.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEmotions = emotionData!.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotion = sortedEmotions.first.key;

    final emotionBasedOptions = options[topEmotion] ?? options["default"]!;
    final randomOption = emotionBasedOptions.isNotEmpty
        ? emotionBasedOptions[random.nextInt(emotionBasedOptions.length)]
        : null;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(randomOption?["text"] as String),
                SizedBox(height: 5),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  randomOption?["route"] as Widget),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      randomOption?["label"] as String,
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
  Widget buildTopicChips() {
    if (topics == null || topics!.isEmpty) return const SizedBox.shrink();
    final topTopics = topics!.where((text) => text.trim().isNotEmpty).take(3).toList();

    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: [
        for (var text in topTopics)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${nickname}님은 오늘 ${topics![0]}에 대한 고민을 상담했어요! "
                    "이외에도 ${topics![1]}와 ${topics![2]} 대해 이야기했네요! "
                    "다음에는 저랑 더 많은 얘기 나눠요😊"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 키워드 UI
  Widget buildKeywordChips() {
    if (words == null || words!.isEmpty) return const SizedBox.shrink();
    final topKeywords = words!.take(3).toList();

    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: [
        for (var text in topKeywords)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

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
    if (selectedDate == null || isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("종합 심리 평가")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustomNavigationBar()),
              );
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("감정 리포트"),
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

                        selectedDate: normalizeDate(selectedDate!),

                        availableReportDates: availableReportDates,
                        onDateSelected: (pickedDate) {
                          final normalized = normalizeDate(pickedDate);
                          setState(() {
                            selectedDate = normalized;
                          });
                          loadReport(normalized);
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
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Color(0xFFEAEBF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("감정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: buildPieChart(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("피드백", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildFeedback(),
                  SizedBox(height: 20),
                  Text("추천활동", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildRecommendation(),
                  SizedBox(height: 20),
                  Text("오늘의 토픽", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildTopicChips(),
                  SizedBox(height: 5),
                  buildTopics(),
                  SizedBox(height: 20),
                  Text("자주 사용한 단어", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildKeywordChips(),
                  SizedBox(height: 5),
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
