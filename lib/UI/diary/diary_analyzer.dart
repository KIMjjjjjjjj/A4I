import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/Chatbot/OpenAPI/prompts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../chatbot/OpenAPI/call_api.dart';

class DiaryAnalyzer {
  static List<String> unsavedMessages = [];
  static DateTime? lastMessageTime;
  static Timer? inactivityTimer;

  static Future<void> handleCombineMessage(String message) async {
    unsavedMessages.add(message);
  }

  // 그동안 저장되지 않은 메시지들 합쳐서 분석
  static Future<void> analyzeCombinedMessages({required DateTime diaryDate}) async {
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, String> prompts = await loadPrompts();

    String combinedMessages = unsavedMessages.join(" ");

    final response = await callOpenAIChat(
      prompt: prompts["analyzerPrompt"] ?? "",
      messages: [
        {"sender": "user", "text": combinedMessages}
      ],
    );

    if (response != null) {
      try {
        Map<String, dynamic> result = jsonDecode(response);
        await createDocument(user!.uid, result, diaryDate);
      } catch (e) {
        print("에러");
      }
    } else {
      print("에러");
    }
  }

  // 전체 대화 분석 저장하는 함수
  static Future<void> createDocument(String userId, Map<String, dynamic> result, DateTime diaryDate)async { // List<double> embedding 추가
    List<dynamic> analysis = result["analysis"] ?? [];

    // 주제 전환이 발생한 경우 주제별로 개별 저장
    for (var entry in analysis) {
      try {
        await FirebaseFirestore.instance.collection("diary").doc(userId).collection("diary_analyzer").doc().set({
          "timestamp": Timestamp.fromDate(diaryDate),
          "keywords": List<String>.from(entry["keywords"]),
          "topic": entry["topic"] ?? "",
          "emotion": entry["emotion"] ?? "",
          "emotion_intensity": entry["emotion_intensity"] ?? 0.0,
          "summary": entry["summary"] ?? "",
        });
      } catch (e) {
        print("문서 저장 실패: $e");
      }
    }
  }
}

