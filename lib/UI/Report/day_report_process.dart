import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/Report/report_model.dart';
import 'package:repos/UI/Report/report_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Chatbot/prompts.dart';

class DayReportProcess {
  // 마지막 채팅 가져오기
  static Future<Map<String, dynamic>?> getLastChat(String uid) async {
    final query = await FirebaseFirestore.instance
        .collection("register")
        .doc(uid)
        .collection("chat")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }

  // 해당 날짜의 chat 데이터 불러오기
  static Future<List<Map<String, dynamic>>> getChatsByDate(String uid, DateTime startDate) async {
    final endDate = startDate.add(Duration(days: 1));
    final querySnapshot = await FirebaseFirestore.instance
        .collection("register")
        .doc(user?.uid)
        .collection("chat")
        .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where("timestamp", isLessThan: Timestamp.fromDate(endDate))
        .orderBy("timestamp")
        .get();

    // keywords, topic, summary가 있는 데이터만 추출(감정만 있는 데이터는 가져오지 않음)
    return querySnapshot.docs
        .map((doc) => doc.data())
        .where((entry) => entry.containsKey("keywords") && entry.containsKey("topic") && entry.containsKey("summary"))
        .toList();
  }

  // chat 컬렉션에서 가장 최근 데이터의 기준으로 리포트 생성
  static Future<void> generateReportFromLastChat() async {
    final user = FirebaseAuth.instance.currentUser;

    final lastChat = await getLastChat(user!.uid);

    if (lastChat != null) {
      final timestamp = lastChat['timestamp'];
      final local = timestamp.toDate().toLocal();
      final reportDate = DateTime(local.year, local.month, local.day);
      processDailyReport(reportDate);
    }
  }

  // 일일리포트 생성 및 병합
  static Future<void> processDailyReport(DateTime date) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final reportService = ReportService();

    final chatData = await getChatsByDate(user!.uid, date);

    // 데이터 가공
    final emotions  = getEmotions(chatData);
    final feedback  = generateFeedback(chatData);
    final topics  = getTopTopics(chatData, 3);
    final keywords  = getTopKeywords(chatData, 5);
    final intensity = getEmotionIntensitys(chatData);

    // 기존 리포트 확인
    final existingReport = await reportService.fetchReport(date);

    // 리포터가 존재하면 기존 데이터와 병합, 존재하지 않으면 새로 생성
    final updatedReport = Report(
      emotionData: existingReport != null ? mergeEmotions(existingReport.emotionData, emotions) : emotions,
      feedback: await feedback,
      topics: existingReport != null ? mergeList(existingReport.topics ?? [], topics, max: 3) : topics,
      keywords: existingReport != null ? mergeList(existingReport.keywords ?? [], keywords, max: 5) : keywords,
      emotionIntensityData: intensity,
    );
    await reportService.saveReport(date, updatedReport);
  }

  //// 기존 리포트 존재할때
  // 1. 기존 감정 데이터와 새로운 감정 데이터를 평균낸 후 전체 비율이 1이 되도록 정규화
  // (최근 데이터에 더 많은 가중치를 둠)
  static Map<String, double> mergeEmotions(Map<String, double> old, Map<String, double> fresh) {
    final result = <String, double>{};
    final allKeys = {...old.keys, ...fresh.keys};
    for (final key in allKeys) {
      result[key] = ((old[key] ?? 0) + (fresh[key] ?? 0)) / 2;
    }
    final total = result.values.fold(0.0, (a, b) => a + b);
    if (total > 0) {
      for (final key in result.keys) {
        result[key] = result[key]! / total;
      }
    }
    return result;
  }

  // 2. 리스트 병합 후 가장 많이 등장한 항목을 기준으로 상위 N개를 추림
  // (키워드/토픽 에서 사용)
  static List<String> mergeList(List<String> old, List<String> fresh, {int max = 5}) {
    final all = [...old, ...fresh];
    final freq = <String, int>{};
    for (final item in all) {
      freq[item] = (freq[item] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final result = sorted.take(max).map((e) => e.key).toList();

    while (result.length < max) {
      result.add("");
    }
    return result;
  }

  //// 두 경우 동일
  // 3. 전체 감정 강도 수집해서 감정별로 강도 값 리스트 생성
  static Map<String, List<double>> getEmotionIntensitys(List<Map<String, dynamic>> chats) {
    final result  = <String, List<double>>{};

    for (final chat in chats) {
      final emotion = chat['emotion'] as String?;
      final intensity = (chat['emotion_intensity'] as num?)?.toDouble() ?? 0.0;

      if (emotion != null && emotion.isNotEmpty) {
        result.putIfAbsent(emotion, () => []).add(intensity);
      }
    }
    return result;
  }

  //// 새로 만들때
  // 4. 감정별 등장 횟수를 센 후 전체 감정 수로 나눠 비율 계산
  static Map<String, double> getEmotions(List<Map<String, dynamic>> chats) {
    const emotions = ["두려움", "슬픔", "놀람", "분노", "기쁨", "기타"];
    final count = {for (var e in emotions) e: 0};
    int total = 0;

    for (final doc in chats) {
      final emotion = doc['emotion'] as String?;
      if (emotion != null && emotions.contains(emotion)) {
        count[emotion] = count[emotion]! + 1;
        total++;
      }
    }
    return {
      for (final emotion in emotions)
        emotion: total > 0 ? count[emotion]! / total : 0.0
    };
  }

  // 5. 토픽 빈도 Top3
  static List<String> getTopTopics(List<Map<String, dynamic>> chats, int n) {
    final Map<String, int> topicCounts = {};
    for (var doc in chats) {
      if (doc['topic'] != null) {
        final topics = doc['topic'].split(',').map((t) => t.trim());
        for (var topic in topics) {
          topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
        }
      }
    }
    final sorted = topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final result =  sorted.take(n).map((e) => e.key).toList();

    while (result.length < n) {
      result.add("");
    }
    return result;
  }

  // 6. 키워드 빈도 Top5
  static List<String> getTopKeywords(List<Map<String, dynamic>> chats, int n) {
    final Map<String, int> keywordCounts = {};
    for (final chat in chats) {
      final keywords = chat['keywords'];
      if (keywords is List) {
        for (final keyword in keywords) {
          if (keyword is String) {
            keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
          }
        }
      }
    }
    final sorted = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final result = sorted.take(n).map((e) => e.key).toList();

    while (result.length < n) {
      result.add("");
    }
    return result;
  }

  //// summary로 피드백 생성
  static Future<String> generateFeedback(List<Map<String, dynamic>> chats) async {
    Map<String, String> prompts = await loadPrompts();
    final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    final summaries = chats.map((chat) => chat['summary'] as String).toList();
    final userContent = summaries.join('\n');

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "temperature": 0.85,
        "top_p": 0.9,
        "messages": [
          {
            "role": "system",
            "content": prompts["feedbackPrompt"]
          },
          {
            "role": "user",
            "content": userContent
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final feedback = data['choices'][0]['message']['content'];
      return feedback;
    } else {
      print('❌ Error: ${response.statusCode}');
      return "error";
    }
  }
}