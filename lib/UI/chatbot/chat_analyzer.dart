import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ChatAnalyzer {
  static List<String> unsavedMessages = [];
  static DateTime? lastMessageTime;
  static Timer? inactivityTimer;
  static String? lastTopic;

  static Future<void> analyzeAndSaveMessage(String message) async {
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
            "content": """
          사용자의 메시지를 분석하여 사건을 중심으로 정리하는 역할을 수행해줘.
          주어진 텍스트를 기반으로 사용자의 메시지를 분석해서 핵심 정보를 추출한 후 아래 JSON 형식으로 반환해줘.

          **출력 형식 (JSON)**
          {
            "analysis": [
              {
                "topic": "주제1",
                "keywords": ["핵심 키워드1", "핵심 키워드2", "핵심 키워드3"],
                "emotion": "주제1에 대한 감정",
                "emotion_intensity": 0.0,
                "summary": "주제1에 대한 요약"
              },
              {
                "topic": "주제2",
                "keywords": ["핵심 키워드1", "핵심 키워드2", "핵심 키워드3"],
                "emotion": "주제2에 대한 감정",
                "emotion_intensity": 0.0,
                "summary": "주제2에 대한 요약"
              }
            ],
          }

          **분석 기준**
          - "topic": 대화의 핵심 주제 **하나만** 반환해줘
                   - 반드시 한 단어로 표현해줘 (예: "대인관계", "학업", "취업", "직장")
                   예시:
                    - 입력: "회사에서 상사랑 의견이 안 맞아서 너무 스트레스 받아."  
                      출력: "직장"  
                    - "학업 및 대인관계" (금지)  
                    - "취업/직장" (슬래시 사용 금지)
          - "keywords": 메시지에서 중요한 단어를 2~3개 추출해줘
                    - **명사(NNG, NNP)만 사용하며**, 동사, 형용사 등은 제외해줘  
                    - **조사(은, 는, 이, 가, 을, 를 등)는 포함하지 말고**, 단어 원형만 추출해줘  
                    - **동일한 개념의 단어는 중복되지 않도록** 가장 대표적인 하나만 선택해줘  
                    예시:
                      - 입력: "요즘 기말고사 준비 때문에 시간이 너무 부족해"  
                        출력: ["기말고사", "시간 부족"]
          - "emotion": 메시지에서 가장 강하게 느껴지는 감정을 하나 선택해줘 (예: "행복", "분노", "슬픔", "불안", "놀람", "평온") //긍정적, 낙관적, 비관적, 부정적, 기타  
          - "emotion_intensity": 감정 강도를 0~1 사이 값으로 반환해줘
                    - 감정 강도가 높을수록 해당 감정이 강렬함을 의미해
          - "summary": 메시지를 요약하여 1~2문장으로 정리해줘
                    - 핵심 내용만 포함하고 불필요한 정보는 제외
                    - 감정 상태와 주요 사건을 함께 포함
          
          **예제 입력 및 출력**
            사용자 입력: "최근에 면접을 봤는데 너무 긴장해서 실수했어. 취업이 걱정돼"
            예상 출력:
            {
              "keywords": ["면접", "긴장", "취업"],
              "topic": "취업",
              "emotion": "불안",
              "emotion_intensity": 0.4,
              "summary": "사용자는 면접에서 긴장해 실수했고, 취업에 대한 걱정이 크다"
            }
          """
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
