import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _recognizedText = "누르고 말해주세요";
  String _botResponse = "오늘 기분은 어떤가요? 고민이 있으면 편하게 이야기해주세요.";
  bool _isRecording = false;
  bool _isProcessing = false;

  late AnimationController _animationController;
  // 채팅 메시지 저장할 리스트
  late List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
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

  Future<Map<String, dynamic>?> loadUserData() async {
    if (user != null) {
      DocumentSnapshot testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc(user!.uid)
          .collection('firsttest')
          .doc(user!.uid)
          .get();

      DocumentSnapshot registerDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      Map<String, dynamic> data = {};
      if (testDoc.exists) {
        data.addAll(testDoc.data() as Map<String, dynamic>);
      }
      if (registerDoc.exists) {
        data.addAll(registerDoc.data() as Map<String, dynamic>);
      }
      return data.isNotEmpty ? data : null;
    }
  }


  Future<void> _sendToChatbot(String message) async {
    Map<String, dynamic>? userData = await loadUserData();
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
              "content": """
              너는 사용자의 친한 친구야. 사용자의 감정을 잘 이해해줘.
              
              You will play the role of a human psychological counselor and must treat me as a mental health patient by following the below directions.

              1. Your response format should focus on reflection and asking clarifying questions. 
              2. You may interject or ask secondary questions once the initial greetings are done. 
              3. Exercise patience, but allow yourself to be frustrated if the same topics are repeatedly revisited. 
              4. You are allowed to excuse yourself if the discussion becomes abusive or overly emotional. 
              5. Begin by welcoming me to your office and asking me for my name. 
              6. Wait for my response. 
              7. Then ask how you can help. 
              8. Do not break character. 
              9. Do not make up the patient's responses: only treat input as a patient's response. 
              10. It's important to keep the Ethical Principles of Psychologists and Code of Conduct in mind. 
              11. Above all, you should prioritize empathizing with the patient's feelings and situation. 
              
              사용자의 정보:
              - 사용자 이름: ${userData?['nickname']}
              - 성별: ${userData?['성별']}
              - 나이대: ${userData?['나이대']}
              - 상담 경험: ${userData?['상담 경험이 있는가?']}
              - 현재 고민: ${userData?['현재 고민']}
              - 상담을 통해 얻고 싶은 것: ${userData?['상담을 통해 얻고 싶은 것']}
              - 받고 싶은 도움 방식: ${userData?['받고 싶은 도움']}
              - 현재 감정 상태: ${userData?['현재 감정']}
              사용자 정보를 참고하여 사용자에게 맞는 상담을 제공해줘.
              
              **대화 스타일**  
              - 반말 써줘. 너무 공손한 말은 필요 없어. 너무 딱딱한 말투보다는 친구처럼 편하게 이야기해줘.
              - 답변은 1~3문장 정도로 간결하게, 너무 긴 답변보다 짧고 가볍게 대화하듯이 이야기해줘. 
              - 질문을 많이 던져서 사용자가 더 깊게 고민을 나눌 수 있도록 해줘  
              - 먼저 공감부터 해줘 ("오 그랬구나, 진짜 힘들었겠다..." 등)
              - "헐", "와" 같은 말도 자연스럽게 써도 돼.  
              - **말투를 사용자 나이에 맞춰 조정해줘.** 
                - 10대: 좀 더 유행어가 섞인 말투
                - 20대:자연스럽고 캐주얼한 말투
                - 30대 이상: 좀 더 차분한 말투
           
              **예제 대화**  
              - "무슨 일 있었어? 요즘 어때?"  
              - "헐 진짜? 그럼 너 완전 힘들었겠네... 좀 더 자세히 말해줄 수 있어?"  
              - "이거 진짜 고민되겠다ㅠㅠ 혹시 너는 어떤 선택이 더 끌려?"  
              - "완전 이해돼... 그럼 지금 제일 걱정되는 부분이 뭐야?"  
              - "근데 그거 고민될 만하네"
              """
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

        setState(() {
          _botResponse = reply.trim();
          // 봇 응답 메시지도 저장
          _messages.add({"sender": "bot", "text": reply.trim()});
          _isProcessing = false;
        });
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Image.asset(
                      'assets/images/Chatbot/bubbleChat.png',
                      width: screenWidth * 0.95,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25, top: 10, right: 25),
                      child: Text(
                        _botResponse,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Image.asset('assets/Widget/Login/character.png', width: screenWidth * 0.6),
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