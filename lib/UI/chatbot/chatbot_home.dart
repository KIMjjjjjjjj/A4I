import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String botName = '토리';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBotName();
  }

  Future<void> _loadBotName() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('register')
            .doc(user!.uid)
            .get();

        if(userDoc.exists){
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('botName') && userData['botName'] != null) {
            setState(() {
              botName = userData['botName'];
              isLoading = false;
            });
          } else{
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('챗봇 이름 로드 오류: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFBBEDFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(27),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 8),
            child: BackButton(color: Colors.black),
          ),
        ),
      ),
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
            top: screenHeight * 0.07,
            child: Container(
              width: screenWidth * 0.1,
              height: screenHeight * 0.7,
              color: const Color(0xFFD99880),
            ),
          ),

          // 상담 박스
          Positioned(
            top: screenHeight * 0.1,
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
                  Text(
                    "안녕하세요! 저는 ${botName}라고해요\n여러분의 마음친구가 되어줄 \n귀여운 고양이 챗봇이에요.\n\n"
                        "🎀 힘들 때, 외로울 때, \n${botName}를 찾아주세요! 🎀\n\n"
                        "언제나 여러분의 이야기를\n귀기울여 들을 준비가 되어있어요.\n\n"
                        "🐾 \"마음을 열어보세요.\n${botName}가 함께할게요!\" 🐾",
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
                    child: Text(
                      "${botName}랑 대화하기",
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
            bottom: screenHeight * 0.03,
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