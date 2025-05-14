//import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:repos/UI/Chatbot/OpenAPI/prompts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'OpenAPI/call_api.dart';
import 'chat_analyzer.dart';
import 'chat_emotion_character.dart';
import 'chat_screen.dart';
import 'sound_wave_painter.dart';
import 'recording_chat_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as convert;
import 'package:just_audio/just_audio.dart';


class VoiceChatScreen extends StatefulWidget {
  final List<Map<String, String>> messages;
  final String selectprompt;

  // 메시지 목록을 받아오는 생성자 추가
  VoiceChatScreen({Key? key, required this.messages, required this.selectprompt}) : super(key: key);

  @override
  _VoiceChatScreenState createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _detectedEmotion = 'neutral';
  double _detectedIntensity = 0.0;
  String _recognizedText = "누르고 말해주세요";
  String _botResponse = "오늘 기분은 어때? 고민이 있으면 편하게 이야기해줘";
  bool _isRecording = false;
  bool _isProcessing = false;
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  int _currentStartOffset = 0;
  int _currentEndOffset = 0;

  late AnimationController _animationController;
  // 채팅 메시지 저장할 리스트
  late List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
    //initializeTTS();
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

  /*void initializeTTS() async {
    await flutterTts.setLanguage("ko-KR"); // 언어 설정
    await flutterTts.setPitch(1.0); // 음성 높낮이 설정
    await flutterTts.setSpeechRate(0.7); // 음성 속도 설정

    // 진행 상태 모니터링
    flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    // 구간별 텍스트 읽기를 위한 설정
    flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      setState(() {
        _currentStartOffset = startOffset;
        _currentEndOffset = endOffset;
      });
    });
  }*/
/*

  void textToSpeech(String text) {
    flutterTts.speak(text);
  }
*/

  Future<void> textToSpeech(String text) async {
    final String _apiKey = dotenv.env['GOOGLE_CLOUD_TTS_API_KEY'] ?? '';
    if (_apiKey == null || _apiKey.isEmpty) {
      print("API 키가 없습니다.");
      return;
    }

    final body = jsonEncode({
      "input": {"text": text},
      "voice": {
        "languageCode": "ko-KR", // 한국어
        "name": "ko-KR-Chirp3-HD-Leda" // ko-KR-Chirp3-HD-Zephyr
      },
      "audioConfig": {
        "audioEncoding": "MP3"
      }
    });

    final response = await http.post(
      Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String audioContent = data['audioContent'];

      // base64 디코딩 후 메모리에 저장
      final bytes = base64Decode(audioContent);

      // 메모리에 바로 로딩해서 재생
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg'),
        ),
      );
      await _audioPlayer.play();
    } else {
      print('TTS API 호출 실패: ${response.statusCode}');
    }
  }


  Widget _buildHighlightedText() {
    if (_botResponse.isEmpty) return Text("");

    if (!_isSpeaking) {
      // TTS가 재생 중이 아니면 일반 텍스트로 표시
      return Text(
        _botResponse,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 16, color: Colors.black),
      );
    }

    try {
      // 현재 읽고 있는 구간과 나머지 부분을 분리
      String beforeText = _botResponse.substring(0, _currentStartOffset);
      String highlightedText = _botResponse.substring(_currentStartOffset, _currentEndOffset);
      String afterText = _botResponse.substring(_currentEndOffset);

      return RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: [
            TextSpan(
              text: beforeText,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            TextSpan(
              text: highlightedText,
              style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: afterText,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      );
    } catch (e) {
      // 인덱스 오류 발생 시 일반 텍스트로 표시
      return Text(
        _botResponse,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 16, color: Colors.black),
      );
    }
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

    try {
      final response = await callOpenAIChat(
        prompt: prompts["chatPrompt"] ?? "",
        messages: _messages,
      );


      if (response != null) {
        final trimmedReply = response.trim();

        setState(() {
          _botResponse = trimmedReply;
          // 봇 응답 메시지도 저장
          _messages.add({"sender": "bot", "text": trimmedReply});
          _isProcessing = false;
        });


        final result = await ChatAnalyzer.analyzeSingleMessage(message);
        final emotion = result["emotion"];
        final intensity = result["emotion_intensity"];
        _updateEmotionCharacter(emotion, intensity);
        Future.microtask(() => textToSpeech(trimmedReply));
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
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
          // 상단 영역 (봇 응답 + 캐릭터)
          Column(
            children: [
              // 봇 응답 컨테이너 (스크롤 가능하고 높이 고정)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 텍스트 스타일 정의
                    TextStyle textStyle = TextStyle(fontSize: 16, color: Colors.black);

                    // 텍스트 스팬 생성
                    TextSpan textSpan = TextSpan(
                      text: _botResponse,
                      style: textStyle,
                    );

                    // 텍스트 페인터 생성
                    TextPainter textPainter = TextPainter(
                      text: textSpan,
                      textDirection: TextDirection.ltr,
                      maxLines: 100, // 최대 라인 수
                    );

                    // 텍스트 레이아웃 계산
                    textPainter.layout(maxWidth: constraints.maxWidth - 30); // 패딩 고려

                    // 텍스트 높이 계산 (최소 80, 최대 screenHeight * 0.4)
                    double textHeight = textPainter.height + 30; // 패딩 추가
                    double containerHeight = textHeight.clamp(80.0, screenHeight * 0.2);

                    return Container(
                      width: screenWidth * 0.95,
                      height: containerHeight,
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
                        ],
                      ),
                      // 스크롤 가능한 텍스트 영역
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: _buildHighlightedText(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 캐릭터 이미지
              EmotionCharacter(emotion: _detectedEmotion, intensity: _detectedIntensity, width: 300, height: 300),
            ],
          ),

          // 하단 영역 (음성 파형, 마이크 버튼, 텍스트)
          Positioned(
            bottom: 80, // 하단 탐색 버튼 위의 여백
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: screenWidth * 0.6,
                  height: 40,
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
          ),
        ],
      ),

      // 하단 버튼 (변경 없음)
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(initialMessages: _messages, selectprompt: widget.selectprompt,),
            ),
          );
        },
        child: Container(
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
    );
  }
}