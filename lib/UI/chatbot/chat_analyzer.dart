import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/Chatbot/OpenAPI/prompts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'OpenAPI/call_api.dart';

class ChatAnalyzer {
  static List<String> unsavedMessages = [];
  static DateTime? lastMessageTime;
  static Timer? inactivityTimer;

  static Future<void> handleCombineMessage(String message) async {
    unsavedMessages.add(message);

    lastMessageTime = DateTime.now();
    inactivityTimer?.cancel();
    // 메시지를 안 보낸지 2분 이상이 되면 저장
    inactivityTimer = Timer(Duration(minutes: 2), () async {
      await analyzeCombinedMessages();
      unsavedMessages.clear();
    });
  }

  // 그동안 저장되지 않은 메시지들 합쳐서 분석
  static Future<void> analyzeCombinedMessages() async {
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
        await createDocument(user!.uid, result);
      } catch (e) {
        print("에러");
      }
    } else {
      print("에러");
    }
  }

  // 단일 메시지에서 강한 감정이 발생하는 경우 저장
  static Future<Map<String, dynamic>> analyzeSingleMessage(String message) async {
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, String> prompts = await loadPrompts();

    final response = await callOpenAIChat(
      prompt: prompts["analyzerPrompt"] ?? "",
      messages: [
        {"sender": "user", "text": message}
      ],
    );

    if (response != null) {

      try {
        final Map<String, dynamic> outer = jsonDecode(response);
        final List<dynamic> analysis = outer["analysis"] ?? [];

        final result = analysis[0] as Map<String, dynamic>;

        final emotion = result["emotion"] ?? "neutral";
        final emotionIntensity = result["emotion_intensity"] is String
            ? double.tryParse(result["emotion_intensity"]) ?? 0.0
            : result["emotion_intensity"] ?? 0.0;

        if (emotionIntensity >= 0.7 && user != null) {
          Future.microtask(() async {
            await createEmotionDocument(user.uid, result);
          });
        }

        return {
          "emotion": emotion,
          "emotion_intensity": emotionIntensity
        };
      } catch (e) {
        print("에러");
      }
    } else {
      print("에러");
    }

    return {
      "emotion": "neutral",
      "emotion_intensity": 0.0
    };
  }

  static Future<void> analyzeVisibleMessages(List<Map<String, String>> messages, String uid) async {
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, String> prompts = await loadPrompts();

    String combinedMessages = messages
        .where((msg) => msg["sender"] == "user")
        .map((msg) => msg["text"])
        .join(" ");

    if (combinedMessages.trim().isEmpty) return;

    final response = await callOpenAIChat(
      prompt: prompts["analyzerPrompt"] ?? "",
      messages: [
        {"sender": "user", "text": combinedMessages}
      ],
    );

    if (response != null && response.trim().isNotEmpty) {
      try {
        final Map<String, dynamic> result = jsonDecode(response);
        if (user != null) {
          await createDocument(user.uid, result);
        }
      } catch (e) {
        print("에러");
      }
    } else {
      print("에러");
    }
  }

  // 전체 대화 분석 저장하는 함수
  static Future<void> createDocument(String userId, Map<String, dynamic> result)async { // List<double> embedding 추가
    List<dynamic> analysis = result["analysis"] ?? [];

    // 주제 전환이 발생한 경우 주제별로 개별 저장
    for (var entry in analysis) {
      try {
        await FirebaseFirestore.instance.collection("register").doc(userId).collection("chat").doc().set({
          "timestamp": FieldValue.serverTimestamp(),
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

  // 분석 내용 중 감정만 저장하는 함수
  static Future<void> createEmotionDocument(String userId, Map<String, dynamic> result) async {
    // 강한 감정이 발생한 경우 감정만 저장
    try {
      await FirebaseFirestore.instance.collection("register").doc(userId).collection("chatEmotion").doc().set({
        "timestamp": FieldValue.serverTimestamp(),
        "emotion": result["emotion"] ?? "",
        "emotion_intensity": result["emotion_intensity"] ?? 0.0,
      });
    } catch (e) {
      print("문서 저장 실패: $e");
    }
  }

  static Future<bool> timecheck(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("register")
          .doc(userId)
          .collection("chat")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final latest = snapshot.docs.first.data();
      final Timestamp? timestamp = latest["timestamp"];
      if (timestamp == null) return false;

      final now = DateTime.now();
      final savedTime = timestamp.toDate();
      final difference = now.difference(savedTime).inSeconds;

      return difference <= 60;
    } catch (e) {
      return false;
    }
  }
}

