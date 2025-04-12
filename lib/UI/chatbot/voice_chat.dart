import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repos/UI/Chatbot/prompts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'chat_analyzer.dart';
import 'chat_emotion_character.dart';
import 'chat_screen.dart';
import 'sound_wave_painter.dart';
import 'recording_chat_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as convert;

class VoiceChatScreen extends StatefulWidget {
  final List<Map<String, String>> messages;

  // 메시지 목록을 받아오는 생성자 추가
  VoiceChatScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _VoiceChatScreenState createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  String _detectedEmotion = 'neutral';
  double _detectedIntensity = 0.0;
  String _recognizedText = "누르고 말해주세요";
  String _botResponse = "오늘 기분은 어때? 고민이 있으면 편하게 이야기해줘";
  bool _isRecording = false;
  bool _isProcessing = false;
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _animationController;
  // 채팅 메시지 저장할 리스트
  late List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
    initializeTTS();
    _messages = widget.messages; // 전달 받은 메시지 목록 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..addListener(() {
      setState(() {}); // 애니메이션 값이 변할 때마다 UI 업데이트
    });
  }

  void _onStartRecording() {
    setState(() {
      print("isRecording = true");
      _isRecording = true;
      _recognizedText = "말하는 중...";
      _animationController.repeat(reverse: true); // 애니메이션 반복 실행
    });
  }

  void _onStopRecording() {
    setState(() {
      _isRecording = false;
      _animationController.stop(); // 애니메이션 중지

      // 인식된 텍스트가 있고 의미 있는 내용이면 챗봇에 전송
      if (_recognizedText != "누르고 말해주세요" &&
          _recognizedText != "말하는 중..." &&
          _recognizedText != "말을 인식하지 못했어요.") {
        _sendToChatbot(_recognizedText);
      }
    });
  }

  void _onTextRecognized(String text) {
    setState(() {
      _recognizedText = text;
    });
  }

  void _updateEmotionCharacter(String newEmotion, double newIntensity) {
    setState(() {
      _detectedEmotion = newEmotion;
      _detectedIntensity = newIntensity;
    });
  }

  void initializeTTS() async {
    await flutterTts.setLanguage("ko-KR"); // 언어 설정
    await flutterTts.setPitch(1.0); // 음성 높낮이 설정
    await flutterTts.setSpeechRate(0.7); // 음성 속도 설정
  }

  void textToSpeech(String text) {
    flutterTts.speak(text);
  }

  Future<void> _sendToChatbot(String message) async {
    Map<String, String> prompts = await loadPrompts();
    if (message.isEmpty || _isProcessing) return;

    // 사용자 메시지를 먼저 저장
    setState(() {
      _isProcessing = true;
      _messages.add({"sender": "user", "text": message});
      _botResponse = "생각 중...";
    });

    final String _apiKey = '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';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "temperature": 0.85,
          "top_p": 0.9,
          "frequency_penalty": 0.7,
          "presence_penalty": 0.8,
          "messages": [
            { "role": "system",
              "content": prompts["chatPrompt"]
            },
            ..._messages.map((m) => {
              "role": m["sender"] == "user" ? "user" : "assistant",
              "content": m["text"],
            }),
          ]
        }),
      );

      if (response.statusCode == 200) {
        final utfDecoded = convert.utf8.decode(response.bodyBytes);
        final data = jsonDecode(utfDecoded);
        final reply = data['choices'][0]['message']['content'];

        final result = await ChatAnalyzer.analyzeSingleMessage(message);
        final emotion = result["emotion"];
        final intensity = result["emotion_intensity"];

        _updateEmotionCharacter(emotion, intensity);

        setState(() {
          _botResponse = reply.trim();
          // 봇 응답 메시지도 저장
          _messages.add({"sender": "bot", "text": reply.trim()});
          _isProcessing = false;
        });
        Future.microtask(() => textToSpeech(_botResponse));
        ChatAnalyzer.handleCombineMessage(message);
      } else {
        setState(() {
          _botResponse = "죄송해요, 응답을 가져오는 데 문제가 있었어요.";
          _messages.add({"sender": "bot", "text": "죄송해요, 응답을 가져오는 데 문제가 있었어요."});
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _botResponse = "오류가 발생했어요. 다시 시도해주세요.";
        _messages.add({"sender": "bot", "text": "오류가 발생했어요. 다시 시도해주세요."});
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1A099),
        centerTitle: true,
        title: Text("하루의 음성채팅", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Color(0xFFB1A099),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: 10),
                child: Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0,2),
                        )
                      ]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      _botResponse,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16,color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              EmotionCharacter(emotion: _detectedEmotion, intensity: _detectedIntensity, width: 300, height: 300),
              SizedBox(height: 30),

              // 애니메이션 적용
              Container(
                width: screenWidth * 0.6,
                height: 50,
                child: CustomPaint(
                  painter: SoundWavePainter(_isRecording ? _animationController.value : 0.0),
                ),
              ),

              SizedBox(height: 20),
              RecordingChatButton(
                onStart: _onStartRecording,
                onStop: _onStopRecording,
                onTextRecognized: _onTextRecognized,
              ),
              SizedBox(height: 10),
              Text(
                _recognizedText,
                style: TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // 업데이트된 메시지 목록과 함께 ChatScreen으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(initialMessages: _messages),
                  ),
                );
              },
              child: Container(
                width: screenWidth,
                height: 50,
                color: Color(0xFFF8B9B9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("채팅으로 돌아가기", style: TextStyle(fontSize: 16, color: Colors.black)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_upward, color: Colors.black, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}