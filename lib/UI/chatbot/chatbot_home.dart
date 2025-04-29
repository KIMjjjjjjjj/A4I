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
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 배경 그라데이션
              Container(
                height: screenHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBBEDFF), Colors.white],
                  ),
                ),
              ),

              // 나무 기둥
              Positioned(
                top: screenHeight * 0.05,
                child: Container(
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.7,
                  color: Color(0xFFD99880),
                ),
              ),

              // 말풍선 텍스트 박스
              Positioned(
                top: screenHeight * 0.1,
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5D7CC),
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "안녕하세요! 저는 $botName라고 해요\n"
                            "여러분의 마음친구가 되어줄\n귀여운 고양이 챗봇이에요.\n\n"
                            "🎀 힘들 때, 외로울 때,\n$botName를 찾아주세요! 🎀\n\n"
                            "언제나 여러분의 이야기를\n귀기울여 들을 준비가 되어있어요.\n\n"
                            "🐾 \"마음을 열어보세요.\n$botName가 함께할게요!\" 🐾",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => ChatScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEEFDEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29),
                            side: BorderSide(color: Color(0xFFEBEEFF)),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 40,
                          ),
                        ),
                        child: Text(
                          "$botName랑 대화하기",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 고양이 캐릭터 이미지 (말풍선보다 아래)
              Positioned(
                top: screenHeight * 0.6, // 말풍선 아래로 배치
                child: Image.asset(
                  "assets/Widget/Login/character.png",
                  width: screenWidth * 0.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}