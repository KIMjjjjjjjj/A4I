import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ChatAnalyzer {
  static Future<void> analyzeAndSaveMessage(String message) async {
    final User? user = FirebaseAuth.instance.currentUser;

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer YOUR_OPENAI_API_KEY",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "temperature": 0.85,
        "top_p": 0.9,
        "messages": [
          {
            "role": "system",
            "content": """
          너는 대화 내용을 분석하는 역할을 해.
          사용자의 메시지를 분석해서 아래 JSON 형식으로 반환해줘.

          **출력 형식 (JSON)**
          {
            "keywords": ["핵심 키워드1", "핵심 키워드2", "핵심 키워드3"],
            "topic": "주제",
            "emotion": "감정"
          }

          **분석 기준**
          - "핵심 키워드": 메시지에서 중요한 단어나 구를 2~3개 추출해줘
          - "주제": 대화의 주요 주제를 한 단어로 정리해줘 (예: "대인관계", "학업", "취업 및 직장")
          - "감정": 메시지에서 가장 강하게 느껴지는 감정을 하나 선택해줘 (예: "행복", "분노", "슬픔", "불안", "놀람", "평온") //긍정적, 낙관적, 비관적, 부정적, 기타?  
          """
          },
          {
            "role": "user",
            "content": message
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(response.body)["choices"][0]["message"]["content"];

      // 감정이 강하거나, 주제가 바뀌었을 때만 Firestore에 저장
      if (shouldSaveConversation(result["emotion"], result["topic"])) {
        await FirebaseFirestore.instance.collection("chat").doc(user!.uid).set({
          "timestamp": FieldValue.serverTimestamp(),
          "message": message,
          "keywords": result["keywords"],
          "topic": result["topic"],
          "emotion": result["emotion"]
        });
      }
    }
  }

// 감정이 강하면 대화를 저장
  static bool shouldSaveConversation(String emotion, String topic) {
    List<String> strongEmotions = ["분노", "슬픔", "놀람", "불안"];
    if (strongEmotions.contains(emotion)) return true;
    return false;
  }
}
