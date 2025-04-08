import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repos/UI/Report/report_model.dart';
import 'package:repos/UI/Report/report_service.dart';

class DayReportProcess {

  // chat 컬렉션에서 가장 최근 데이터의 기준으로 리포트 생성
  static Future<void> generateReportFromLastChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection("register")
        .doc(user.uid)
        .collection("chat")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final timestamp = query.docs.first['timestamp'] as Timestamp;
      final local = timestamp.toDate().toLocal();
      final reportDate = DateTime(local.year, local.month, local.day);

      processDailyReport(reportDate);
    }
  }

  // 일일보고서 생성
  static Future<void> processDailyReport(DateTime date) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final reportService = ReportService();
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(Duration(days: 1));

    // chat 데이터 불러오기
    final querySnapshot = await FirebaseFirestore.instance
        .collection("register")
        .doc(user?.uid)
        .collection("chat")
        .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where("timestamp", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy("timestamp")
        .get();

    final chatData = querySnapshot.docs.map((doc) => doc.data()).toList();

    // 데이터 가공
    final newEmotionData = getEmotions(chatData);
    final newFeedback = '피드백';
    final newTopics = getTopTopics(chatData, 3);
    final newKeywords = getTopKeywords(chatData, 5);
    final newEmotionIntensitys = getEmotionIntensitys(chatData);

    // 기존 리포트 확인
    final existingReport = await reportService.fetchReport(date);

    if (existingReport != null) {
      // 기존 데이터와 병합
      final mergedEmotionData = mergeEmotions(
          existingReport.emotionData, newEmotionData);
      final mergedKeywords = mergeList(
          existingReport.keywords, newKeywords, max: 5);
      final mergedTopics = mergeList(existingReport.topics, newTopics, max: 3);

      final updatedReport = Report(
        emotionData: mergedEmotionData,
        feedback: newFeedback,
        keywords: mergedKeywords,
        topics: mergedTopics,
        emotionIntensitys: newEmotionIntensitys,
      );
      await reportService.saveReport(date, updatedReport);
    } else {
      // 리포트 존재하지 않으면 새로 생성
      final newReport = Report(
        emotionData: newEmotionData,
        feedback: newFeedback,
        keywords: newKeywords,
        topics: newTopics,
        emotionIntensitys: newEmotionIntensitys,
      );
      await reportService.saveReport(date, newReport);
    }
  }

  // 감정 업데이트 함수
  static Map<String, double> mergeEmotions(Map<String, double> old, Map<String, double> fresh) {
    final result = <String, double>{};
    final allKeys = {...old.keys, ...fresh.keys};
    for (final key in allKeys) {
      result[key] = ((old[key] ?? 0) + (fresh[key] ?? 0)) / 2;
    }

    // 정규화
    final total = result.values.fold(0.0, (a, b) => a + b);
    if (total > 0) {
      result.updateAll((key, value) => value / total);
    }

    return result;
  }

  // 리스트 업데이트 함수
  static List<String> mergeList(List<String> old, List<String> fresh, {int max = 5}) {
    final all = [...old, ...fresh];
    final freq = <String, int>{};
    for (final item in all) {
      freq[item] = (freq[item] ?? 0) + 1;
    }

    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(max).map((e) => e.key).toList();
  }

  // 감정 정규화 (각 감정의 평균을 구한 후 평균들의 합이 1이 되도록 정규화)
  static Map<String, double> getEmotions(List<Map<String, dynamic>> chatDocs) {
    const emotionCategories = ["두려움", "슬픔", "놀람", "분노", "기쁨", "기타"];
    final Map<String, int> emotionCounts = {
      for (final emotion in emotionCategories) emotion: 0
    };
    int totalCount = 0;
    // 각 감정 수 합산
    for (final doc in chatDocs) {
      final emotion = doc['emotion'] as String?;
      if (emotion != null && emotionCategories.contains(emotion)) {
        emotionCounts[emotion] = emotionCounts[emotion]! + 1;
        totalCount++;
      }
    }
    // 총합 1이 되도록 정규화
    return {
      for (final emotion in emotionCategories)
        emotion: totalCount > 0
            ? emotionCounts[emotion]! / totalCount
            : 0.0
    };
  }

  // 감정 강도 업데이트 함수
  static Map<String, List<double>> getEmotionIntensitys(List<Map<String, dynamic>> chatDocs) {
    final emotionMap = <String, List<double>>{};

    for (final chat in chatDocs) {
      final emotion = chat['emotion'] as String?;
      final intensity = (chat['emotion_intensity'] as num?)?.toDouble() ?? 0.0;

      if (emotion == null || emotion.isEmpty) continue;

      if (!emotionMap.containsKey(emotion)) {
        emotionMap[emotion] = [];
      }
      emotionMap[emotion]!.add(intensity);
    }
    return emotionMap;
  }

  // 토픽 빈도 Top3
  static List<String> getTopTopics(List<Map<String, dynamic>> data, int n) {
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

  // 키워드 빈도 Top5
  static List<String> getTopKeywords(List<Map<String, dynamic>> data, int n) {
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