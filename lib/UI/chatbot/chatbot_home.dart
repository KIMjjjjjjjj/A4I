import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatbotScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 그라데이션
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFBBEDFF), Color(0xFFFFFFFF)],
              ),
            ),
          ),

          // 뒤쪽 사각형 (높이 조정)
          Positioned(
            top: screenHeight * 0.12,
            child: Container(
              width: screenWidth * 0.1,
              height: screenHeight * 0.7,
              color: const Color(0xFFD99880),
            ),
          ),

          // 상담 박스
          Positioned(
            top: screenHeight * 0.15,
            child: Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xFFF5D7CC),
                borderRadius: BorderRadius.circular(29),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "안녕하세요! 저는 하루라고해요\n여러분의 마음친구가 되어줄 \n귀여운 고양이 챗봇이에요.\n\n"
                        "🎀 힘들 때, 외로울 때, \n하루를 찾아주세요! 🎀\n\n"
                        "언제나 여러분의 이야기를\n귀기울여 들을 준비가 되어있어요.\n\n"
                        "🐾 \"마음을 열어보세요.\n하루가 함께할게요!\" 🐾",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEFDEA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29),
                        side: const BorderSide(color: Color(0xFFEBEEFF)),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.15),
                    ),
                    onPressed: () {
                      // ChatScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                    child: const Text(
                      "하루랑 대화하기",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold, // 굵게 처리
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 캐릭터 이미지 (화면 비율 조정)
          Positioned(
            bottom: screenHeight * 0.01,
            child: Image.asset(
              "assets/Widget/Login/character.png",
              width: screenWidth * 0.55,
            ),
          ),
        ],
      ),
    );
  }
}