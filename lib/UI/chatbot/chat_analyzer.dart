import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/Chatbot/prompts.dart';

class ChatAnalyzer {
  static List<String> unsavedMessages = [];
  static DateTime? lastMessageTime;
  static Timer? inactivityTimer;
  static String? lastTopic;

  static Future<void> analyzeAndSaveMessage(String message) async {
    Map<String, String> prompts = await loadPrompts();
    final User? user = FirebaseAuth.instance.currentUser;
    final String _apiKey = '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';

    unsavedMessages.add(message);
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
          {
            "role": "system",
            "content": prompts["analyzerPrompt"]
          },
          {
            "role": "user",
            "content": combinedMessages
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String utfDecoded = utf8.decode(response.bodyBytes);
      Map<String, dynamic> apiResponse = jsonDecode(utfDecoded);

      String responseBody = apiResponse["choices"][0]["message"]["content"];
      Map<String, dynamic> result = jsonDecode(responseBody);

      double emotionIntensity = result["emotion_intensity"] ?? 0.0;
      //List<double> embedding = await getTextEmbedding(message);

      lastMessageTime = DateTime.now();
      inactivityTimer?.cancel();

      // 메시지를 안 보낸지 2분 이상이 되면 저장
      inactivityTimer = Timer(Duration(minutes: 2), () async {
        await createDocument(user!.uid, message, result); //embedding추가
        unsavedMessages.clear();
      });

      // 감정이 강한 경우 저장
      if (emotionIntensity >= 0.8) {
        await createDocument(user!.uid, message, result); //embedding추가
        unsavedMessages.clear();
      }
    }
  }

  static Future<void> createDocument(String userId, String message, Map<String, dynamic> result)async { // List<double> embedding 추가
    List<dynamic> analysis = result["analysis"] ?? [];

    // 주제 전환이 발생한 경우 주제별로 개별 저장
    for (var entry in analysis) {
      await FirebaseFirestore.instance.collection("register").doc(userId).collection("chat").doc().set({
        "timestamp": FieldValue.serverTimestamp(),
        "keywords": List<String>.from(entry["keywords"]),
        "topic": entry["topic"],
        "emotion": entry["emotion"],
        "emotion_intensity": entry["emotion_intensity"],
        "summary": entry["summary"],
        //"embedding": embedding
      });
    }
  }

  /*
  // OpenAI API 키가 해당 Embedding 모델 사용 못함 (Embedding API 별도 권한이 필요)
  static Future<List<double>> getTextEmbedding(String text) async {
    final String _apiKey = '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';
    final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"input": text, "model": "text-embedding-3-small"}) // 모델 변경
    );

    if (response.statusCode == 200) {
      return List<double>.from(jsonDecode(response.body)["data"][0]["embedding"]);
    }
  }
  */
}
