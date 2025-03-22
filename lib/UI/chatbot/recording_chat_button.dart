import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class RecordingChatButton extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final Function(String) onTextRecognized;

  const RecordingChatButton({
    Key? key,
    required this.onStart,
    required this.onStop,
    required this.onTextRecognized,
  }) : super(key: key);

  @override
  _RecordingChatButtonState createState() => _RecordingChatButtonState();
}

class _RecordingChatButtonState extends State<RecordingChatButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _soundLevel = 0.0;
  String _recognizedText = "누르고 말해주세요";
  bool _hasMicPermission = false; // 마이크 권한 상태

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkPermission();
  }

  /// 🎤 마이크 권한 확인
  Future<void> _checkPermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _hasMicPermission = true;
      print("✅ 마이크 권한 허용됨");
      _initializeSpeech();
    } else {
      _hasMicPermission = false;
      print("❌ 마이크 권한 없음");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("마이크 권한이 필요합니다. 설정에서 허용해주세요.")),
      );
    }
  }

  /// 🛠 음성 인식 초기화
  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("📢 상태 변경: $status"),
      onError: (error) => print("🚨 오류 발생: ${error.errorMsg}"),
    );

    if (!available) {
      print("❌ 음성 인식 초기화 실패");
    } else {
      print("✅ 음성 인식 초기화 성공");
    }
  }

  /// 🎤 음성 듣기 시작
  Future<void> _startListening() async {
    print("🎤 음성 인식 시작 시도");
    bool available = await _speech.initialize();
    print("✅ 음성 인식 가능 여부: $available");
    if (!_hasMicPermission) {
      print("⚠️ 마이크 권한 없음. 음성 인식 실행 불가.");
      return;
    }

    if (!_speech.isAvailable) {
      print("⚠️ 음성 인식 사용 불가능. 초기화 시도...");
      bool available = await _speech.initialize();
      print("✅ 음성 인식 가능 여부: $available");

      if (!available) {
        print("❌ 음성 인식 초기화 실패");
        return;
      }
    }

    try {
      setState(() {
        _isListening = true;
        _recognizedText = "말하는 중...";
      });

      widget.onStart();
      print("🎤 녹음 시작");

      await _speech.listen(
        localeId: "ko_KR",
        onResult: (val) {
          print("📝 인식된 텍스트: ${val.recognizedWords}");
          setState(() {
            _recognizedText = val.recognizedWords.isNotEmpty
                ? val.recognizedWords
                : "말을 인식하지 못했어요.";
          });
          widget.onTextRecognized(_recognizedText);
        },
        listenFor: Duration(seconds: 60),  // 최대 60초까지 듣기
        pauseFor: Duration(seconds: 10),    // 2초 동안 무음이면 종료
        listenOptions: stt.SpeechListenOptions(
          partialResults: true, // ✅ 최신 방식 적용
        ),
        onSoundLevelChange: (level) {
          if (level > 0.1) {
            print("🔊 현재 사운드 레벨: $level");
            setState(() {
              _soundLevel = level;
            });
          }
        },
      );

      print("✅ 음성 인식 시작됨");
    } catch (e) {
      print("🚨 listen() 오류 발생: $e");
    }
  }

  /// ⏹️ 음성 듣기 중지
  void _stopListening() async {
    print("⏹️ 음성 인식 중지 시도");
    await _speech.stop();
    print("✅ 음성 인식 중지됨");

    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
      _recognizedText = "누르고 말해주세요";
    });

    widget.onStop();
    widget.onTextRecognized(_recognizedText);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _isListening ? Colors.red : Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
