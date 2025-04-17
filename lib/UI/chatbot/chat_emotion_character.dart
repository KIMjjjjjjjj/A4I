import 'package:flutter/cupertino.dart';

class EmotionCharacter extends StatelessWidget {
  final String emotion;
  final double intensity;
  final double width;
  final double height;

  EmotionCharacter({
    required this.emotion,
    required this.intensity,
    required this.width,
    required this.height
  });

  // 감정에 따른 이미지 선택
  String _getImageForEmotion(String emotion, double intensity) {
    final level = (intensity >= 0.8)
        ? "3"
        : (intensity >= 0.4)
          ? "2"
          : "1";

    switch (emotion.toLowerCase()) {
      case '기쁨':
        return 'assets/images/Chatbot/VoiceChat/joy$level.png';
      case '슬픔':
        return 'assets/images/Chatbot/VoiceChat/sad$level.png';
      case '분노':
        return 'assets/images/Chatbot/VoiceChat/angry.png';
      case '두려움':
        return 'assets/images/Chatbot/VoiceChat/fear.png';
      default:
        return 'assets/images/Chatbot/VoiceChat/neutral.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImageForEmotion(emotion, intensity);

    return AnimatedSwitcher(
      duration: Duration(microseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Image.asset(
          imagePath,
          key: ValueKey(imagePath),
          width: width, height: height,
      ),
    );
  }
}