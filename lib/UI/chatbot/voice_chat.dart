import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'sound_wave_painter.dart';
import 'recording_chat_button.dart';

class VoiceChatScreen extends StatefulWidget {
  @override
  _VoiceChatScreenState createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with SingleTickerProviderStateMixin {
  String _recognizedText = "누르고 말해주세요";
  bool _isRecording = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
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
    });
  }

  void _onTextRecognized(String text) {
    setState(() {
      _recognizedText = text;
    });
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
                      '오늘 기분은 어떤가요? 고민이 있으면 편하게 이야기 해주세요.\n',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16,color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Image.asset('assets/Widget/Login/character.png', width: screenWidth * 0.6),
              SizedBox(height: 30),

              // 🎨 애니메이션 적용
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
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
