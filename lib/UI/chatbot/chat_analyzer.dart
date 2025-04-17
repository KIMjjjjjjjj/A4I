import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/Chatbot/prompts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, String> prompts = await loadPrompts();

    String combinedMessages = unsavedMessages.join(" ");

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
          {"role": "system", "content": prompts["analyzerPrompt"]},
          {"role": "user", "content": combinedMessages}
        ]
      }),
    );

    if (response.statusCode == 200) {
      String utfDecoded = utf8.decode(response.bodyBytes);
      Map<String, dynamic> apiResponse = jsonDecode(utfDecoded);

      String responseBody = apiResponse["choices"][0]["message"]["content"];
      Map<String, dynamic> result = jsonDecode(responseBody);

      await createDocument(user!.uid, result);
    }
  }

  // 단일 메시지에서 강한 감정이 발생하는 경우 저장
  static Future<Map<String, dynamic>> analyzeSingleMessage(String message) async {
    final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, String> prompts = await loadPrompts();

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
          {"role": "system", "content": prompts["emotionAnalyzerPrompt"]},
          {"role": "user", "content": message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      String utfDecoded = utf8.decode(response.bodyBytes);
      Map<String, dynamic> apiResponse = jsonDecode(utfDecoded);

      String responseBody = apiResponse["choices"][0]["message"]["content"];
      print("🧠 GPT 응답: $responseBody");
      Map<String, dynamic> result = jsonDecode(responseBody);

      final emotion = result["emotion"] ?? "neutral";
      final emotionIntensity = result["emotion_intensity"] is String
          ? double.tryParse(result["emotion_intensity"]) ?? 0.0
          : result["emotion_intensity"] ?? 0.0;

      if (emotionIntensity >= 0.7) {
        Future.microtask(() async {
          await createEmotionDocument(user!.uid, result);
        });
      }
      return {
        "emotion": emotion,
        "emotion_intensity": emotionIntensity
      };
    } else {
      return {
        "emotion": "neutral",
        "emotion_intensity": 0.0
      };
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
}




