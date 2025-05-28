
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:repos/UI/Chatbot/OpenAPI/prompts.dart';
import '../chatbot/OpenAPI/call_api.dart';
import 'diary_report.dart';
import 'report_date_range_selector.dart';
import 'report_service.dart';
import 'report_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class weekreport extends StatefulWidget {
  @override
  _weekreport createState() => _weekreport();
}

class _weekreport extends State<weekreport> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> emotions = ["두려움", "슬픔", "놀람", "분노", "기쁨", "기타"];
  String selectedEmotion = "두려움";
  final TextEditingController percentController = TextEditingController();
  Set<String> usedEmotionsSet = {};

  DateTime? startDate;
  DateTime? endDate;
  Set<DateTime> availableDates = {};
  bool isLoading = true;

  Color getEmotionColor(String emotion) {
    switch (emotion) {
      case '기쁨':
        return Color(0xFFFF8A00);
      case '두려움':
        return Color(0xFFA1EEBD);
      case '슬픔':
        return Color(0xFF7BD3EA);
      case '분노':
        return Color(0xFFEA7BDF);
      case '놀람':
        return Color(0xFFF6D6D6);
      default:
        return Color(0xFFF6F7C4);
    }
  }

  String getEmotionEmoji(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '😊';
      case '두려움':
        return '😰';
      case '슬픔':
        return '😢';
      case '분노':
        return '😡';
      case '놀람':
        return '😲';
      default:
        return '😐';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: emotions.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedEmotion = emotions[_tabController.index];
      });
    });
    _initializeReportRange();
  }

  Future<void> _initializeReportRange() async {
    final service = ReportService();
    final dates = await service.getAvailableReportDates();

    if (dates.isNotEmpty) {
      final sorted = dates.toList()..sort();
      final latest = sorted.last;
      final rangeStart  = latest.subtract(Duration(days: 6));

      final filtered = sorted.where((date) =>
      !date.isBefore(rangeStart) && !date.isAfter(latest)
      ).toList();

      setState(() {
        availableDates = filtered.toSet();
        startDate = filtered.first;
        endDate = filtered.last;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    await loadReports();
  }

  late List<Report> weeklyReports = [];

  Future<List<Report>> loadReportsFromCache(DateTime startDate, DateTime endDate) async {
    final cacheFile = await _getCacheFile(startDate, endDate);
    if (await cacheFile.exists()) {
      final cacheData = await cacheFile.readAsString();
      final List<dynamic> jsonData = jsonDecode(cacheData);
      return jsonData.map((e) => Report.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<File> _getCacheFile(DateTime startDate, DateTime endDate) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "diary_${startDate.toIso8601String().substring(0, 10)}_${endDate.toIso8601String().substring(0, 10)}.json";
    return File('${directory.path}/$fileName');
  }

  // 날짜 범위에 있는 리포트 불러와 리스트에 저장
  Future<void> loadReports() async {
    if (startDate != null && endDate != null) {
      // 캐시된 데이터를 먼저 시도
      final cachedReports = await loadReportsFromCache(startDate!, endDate!);
      if (cachedReports.isNotEmpty) {
        setState(() {
          weeklyReports = cachedReports;
        });
      } else {
        // 캐시가 없으면 최신 데이터 불러오기
        final reports = await fetchReportsInRange(startDate!, endDate!);
        await _cacheReports(reports); // 최신 데이터 캐시 저장
        setState(() {
          weeklyReports = reports;
        });
      }

      // 사용된 감정 수집
      final usedEmotions = <String>{};
      for (final report in weeklyReports) {
        for (final emotion in emotions) {
          if (report.emotionIntensityData?[emotion] != null) {
            usedEmotions.add(emotion);
          }
        }
      }

      setState(() {
        usedEmotionsSet = usedEmotions;
        selectedEmotion = usedEmotions.contains(selectedEmotion)
            ? selectedEmotion
            : emotions.firstWhere((e) => usedEmotions.contains(e), orElse: () => "기타");
      });
    }
  }

// 최신 데이터를 캐시하는 함수
  Future<void> _cacheReports(List<Report> reports) async {
    final cacheFile = await _getCacheFile(startDate!, endDate!);
    final jsonData = jsonEncode(reports.map((e) => e.toJson()).toList());
    await cacheFile.writeAsString(jsonData);
  }


  // 날짜마다 리포트 불러오는 함수
  Future<List<Report>> fetchReportsInRange(DateTime start, DateTime end) async {
    final service = ReportService();
    List<Report> reports = [];

    for (DateTime date = start; !date.isAfter(end); date = date.add(Duration(days: 1))) {
      final report = await service.fetchReport(date);
      if (report != null) {
        reports.add(report);
      }
    }
    return reports;
  }

  // 라인차트
  Widget buildLineChart() {
    List<FlSpot> spots = [];
    Map<int, String> dateLabels = {};
    int currentIndex = 0;

    if (weeklyReports.isEmpty) {
      // 만약 데이터가 비어있으면 최신 리포트를 로드
      loadReports(); // 데이터를 비동기적으로 로드합니다.
    }

    for (int i = 0; i < weeklyReports.length; i++) {
      final report = weeklyReports[i];
      final date = report.date;
      final dateLabel = "${date.month}/${date.day}";

      final emotionList = report.emotionIntensityData?[selectedEmotion];
      if (emotionList != null) {
        for (int j = 0; j < emotionList.length; j++) {
          spots.add(FlSpot(currentIndex.toDouble(), emotionList[j]));
          if (j == 0) {
            dateLabels[currentIndex] = dateLabel;
          }
          currentIndex++;
        }
      }
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (dateLabels.containsKey(index)) {
                    return Text(dateLabels[index]!,
                        style: TextStyle(fontSize: 10));
                  } else {
                    return SizedBox.shrink();
                  }
                },
                interval: 1,
                reservedSize: 30,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          backgroundColor: Color(0xFFEAEBF0),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 토픽 빈도 계산 함수
  List<String> getTopTopics({int topN = 3}) {
    final Map<String, int> frequencyMap = {};

    for (var report in weeklyReports) {
      if (report.topics != null) {
        for (var topic in report.topics!) {
          if (topic.trim().isNotEmpty) {
            frequencyMap[topic] = (frequencyMap[topic] ?? 0) + 1;
          }
        }
      }
    }
    final sortedTopics = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedTopics.take(topN).map((entry) => entry.key).toList();
  }

  Widget buildTopicChips() {
    final topTopics = getTopTopics(); // weeklyReports 내부에서 꺼내기

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var text in topTopics)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

  // 감정별 상위 키워드 맵
  Map<String, List<String>> getTopKeywordsByEmotion({int topNEmotion = 3, int topNKeyword = 3}) {
    final Map<String, int> emotionFrequencyMap = {};
    final Map<String, Map<String, int>> emotionKeywordMap = {};

    for (var report in weeklyReports) {
      final emotions = report.emotionData;
      final keywords = report.keywords;

      if (emotions != null && keywords != null) {
        // 가장 높은 점수의 감정 선택
        final topEmotion = emotions.entries.reduce((a, b) => a.value > b.value ? a : b,).key;
        // 감정 빈도 증가
        emotionFrequencyMap[topEmotion] = (emotionFrequencyMap[topEmotion] ?? 0) + 1;
        // 감정별 키워드 누적
        emotionKeywordMap.putIfAbsent(topEmotion, () => {});
        for (var keyword in keywords) {
          if (keyword != null && keyword.trim().isNotEmpty) {
            emotionKeywordMap[topEmotion]![keyword] = (emotionKeywordMap[topEmotion]?[keyword] ?? 0) + 1;
          }
        }
      }
    }
    // 상위 감정 추출
    final topEmotions = emotionFrequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotionKeys = topEmotions.take(topNEmotion).map((entry) => entry.key).toList();
    // 감정별 상위 키워드 추출
    final Map<String, List<String>> result = {};

    for (var emotion in topEmotionKeys) {
      final keywordMap = emotionKeywordMap[emotion]!;
      final sortedKeywords = keywordMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      result[emotion] = sortedKeywords.take(topNKeyword).map((entry) => entry.key).toList();
    }

    return result;
  }

  Widget buildEmotionKeywordMap() {
    final emotionKeywordMap = getTopKeywordsByEmotion();

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: emotionKeywordMap.length,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          final entry = emotionKeywordMap.entries.elementAt(index);
          final emotion = entry.key;
          final keywords = entry.value;
          final color = getEmotionColor(emotion);

          return Container(
            width: 250,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color.withOpacity(0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    children: [
                      Text(
                        getEmotionEmoji(emotion),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 5),
                      Text(
                        emotion,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    ]
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: keywords.map((k) {
                    return Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        k,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // 감정 타임라인
  List<Map<String, dynamic>> getEmotionTimeline() {
    final List<Map<String, dynamic>> timeline = [];

    for (int i = 0; i < weeklyReports.length; i++) {
      final report = weeklyReports[i];
      final date = report.date;
      final dateLabel = "${date!.month.toString().padLeft(2, '0')}/${date!.day.toString().padLeft(2, '0')}";

      if (report.emotionData != null) {
        final topEmotion = report.emotionData.entries
            .reduce((a, b) => a.value > b.value ? a : b);

        timeline.add({
          "date": dateLabel,
          "emotion": topEmotion.key,
          "value": topEmotion.value,
        });
      }
    }
    return timeline.reversed.toList();
  }

  Widget buildTimelineChart(){
    final List<Map<String, dynamic>> timeline = getEmotionTimeline();

    return Column(
      children: timeline.map((item) {
        final day = item["date"] as String;
        final emotion = item["emotion"] as String;
        final emoji = getEmotionEmoji(emotion);

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color:  Colors.white,
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Text(emoji, style: TextStyle(fontSize: 25)),
            title: Text(
              "$day - $emotion",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<File> _getFeedbackCacheFile(DateTime startDate, DateTime endDate) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "diary_${startDate.toIso8601String().substring(0, 10)}_${endDate.toIso8601String().substring(0, 10)}_feedback.txt";
    return File('${directory.path}/$fileName');
  }
  Future<String?> _loadFeedbackFromCache(DateTime startDate, DateTime endDate) async {
    final file = await _getFeedbackCacheFile(startDate, endDate);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
  Future<void> _cacheFeedback(String feedback, DateTime startDate, DateTime endDate) async {
    final file = await _getFeedbackCacheFile(startDate, endDate);
    await file.writeAsString(feedback);
  }

  Future<String> generatePeriodFeedback(List<Report> reports, DateTime startDate, DateTime endDate) async {
    // 1. 캐시 확인
    final cached = await _loadFeedbackFromCache(startDate, endDate);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 2. 없으면 생성
    Map<String, String> prompts = await loadPrompts();

    final userContent = reports
        .where((report) => report.feedback != null && report.feedback!.isNotEmpty)
        .map((report) => "- ${report.feedback}")
        .join("\n");

    final response = await callOpenAIChat(
      prompt: prompts["periodFeedbackPrompt"] ?? "",
      messages: [
        { "sender": "user", "text": userContent }
      ],
    );

    if (response != null) {
      await _cacheFeedback(response, startDate, endDate);
      return response;
    } else {
      return "error";
    }
  }

  Widget buildPeriodFeedback() {
    if (startDate == null || endDate == null) {
      return const Center(
        child: Text("데이터를 불러오는 중입니다...", style: TextStyle(fontSize: 14)),
      );
    }

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
            child: FutureBuilder<String>(
              future: generatePeriodFeedback(weeklyReports, startDate!, endDate!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("요약 생성 중...", style: TextStyle(fontSize: 14));
                } else {
                  return Text(snapshot.data ?? '', style: const TextStyle(fontSize: 14));
                }
              },
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => diaryreport()),
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
                MaterialPageRoute(builder: (context) => diaryreport()),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        startDate != null && endDate != null
                            ? "${startDate!.year}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.day.toString().padLeft(2, '0')} - "
                            "${endDate!.year}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.day.toString().padLeft(2, '0')}"
                            : "로딩 중...",
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: Icon(Icons.event, color: Colors.black),
                        onPressed: () async {
                          final range = await DateRangePicker.showValidDateRangePicker(context);
                          if (range != null) {
                            setState(() {
                              startDate = range.start;
                              endDate = range.end;
                            });
                            print("선택된 범위: ${range.start} ~ ${range.end}");
                            await loadReports();
                          }
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFEAEBF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text("얼마나 많은 변화가 있었을까요?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Color(0xFFAAA4A5),
                        indicatorColor: Colors.transparent,
                        onTap: (index) {
                          final emotion = emotions[index];
                          if (usedEmotionsSet.contains(emotion)) {
                            setState(() {
                              selectedEmotion = emotion;
                            });
                          } else {
                            // 선택을 막음 (탭 변경 무효화)
                            _tabController.animateTo(_tabController.previousIndex);
                          }
                        },
                        tabs: emotions.map((emotion) {
                          final isEnabled = usedEmotionsSet.contains(emotion);
                          final isSelected = selectedEmotion == emotion;

                          return Tab(
                            child: Opacity(
                              opacity: isEnabled ? 1.0 : 0.3, // 흐리게
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : isEnabled
                                      ? Color(0xFFEAEBF0)
                                      : Color(0xFFE0E0E0), // 비활성화된 배경색
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  emotion,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isEnabled ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                  ),
                  SizedBox(height: 30),
                  buildLineChart(),
                  SizedBox(height: 25),
                  Text("대화 주제", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  buildTopicChips(),
                  SizedBox(height: 25),
                  Text("감정별 상위 키워드 맵", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  buildEmotionKeywordMap(),
                  SizedBox(height: 25),
                  Text("기간 피드백", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  buildPeriodFeedback(),
                  SizedBox(height: 25),
                  Text("감정 타임라인", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  buildTimelineChart(),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
