import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'day_report.dart';
import 'report_date_range_selector.dart';
import 'report_service.dart';
import 'report_model.dart';

class weekreport extends StatefulWidget {
  @override
  _weekreport createState() => _weekreport();
}

class _weekreport extends State<weekreport> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> emotions = ["두려움", "슬픔", "놀람", "분노", "기쁨", "기타"];

  String selectedEmotion = "두려움"; // 기본값

  final TextEditingController percentController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  Set<DateTime> availableDates = {};
  bool isLoading = true;

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
      final sevenDaysAgo = latest.subtract(Duration(days: 6));

      final filtered = sorted.where((d) => d.isAfter(sevenDaysAgo.subtract(Duration(days: 1)))).toList();
      setState(() {
        availableDates = dates;
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

  Future<void> loadReports() async {
    if (startDate != null && endDate != null) {
      weeklyReports = await fetchReportsInRange(startDate!, endDate!);
      print("불러온 보고서 개수: ${weeklyReports.length}");
      setState(() {}); // UI 업데이트
    }
  }

  Future<List<Report>> fetchReportsInRange(DateTime start, DateTime end) async {
    final service = ReportService();
    List<Report> reports = [];

    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final currentDate = start.add(Duration(days: i));
      final report = await service.fetchReport(currentDate);
      if (report != null) {
        reports.add(report);
      }
    }

    return reports;
  }

  Widget buildLineChart() {
    List<FlSpot> spots = [];
    Map<int, String> dateLabels = {};
    int currentIndex = 0;

    for (int i = 0; i < weeklyReports.length; i++) {
      final report = weeklyReports[i];
      final date = startDate!.add(Duration(days: i));
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
          frequencyMap[topic] = (frequencyMap[topic] ?? 0) + 1;
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

  // 키워드 빈도수
  List<String> getTopKeywords({int topN = 5}) {
    final Map<String, int> frequencyMap = {};

    for (var report in weeklyReports) {
      if (report.keywords != null) {
        for (var keyword in report.keywords!) {
          frequencyMap[keyword] = (frequencyMap[keyword] ?? 0) + 1;
        }
      }
    }

    final sortedKeywords = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedKeywords.take(topN).map((entry) => entry.key).toList();
  }

  Widget buildKeywordChips() {
    final topKeywords = getTopKeywords();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var text in topKeywords)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
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
                  Text(
                    startDate != null && endDate != null
                        ? "${startDate!.year}년 ${startDate!.month.toString().padLeft(2, '0')}월 ${startDate!.day.toString().padLeft(2, '0')}일부터 "
                        "${endDate!.year}년 ${endDate!.month.toString().padLeft(2, '0')}월 ${endDate!.day.toString().padLeft(2, '0')}일까지"
                        : "로딩 중...",
                    style: TextStyle(fontSize: 14),
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
                            tabs: emotions.map((emotion) {
                              return Tab(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: selectedEmotion == emotion ? Colors.white : Color(0xFFEAEBF0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    emotion,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                  ),
                  SizedBox(height: 30),
                  buildLineChart(),
                  SizedBox(height: 20),
                  Text("대화 주제", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  buildTopicChips(),
                  SizedBox(height: 20),
                  Text("가장 많이 사용한 단어", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  buildKeywordChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}