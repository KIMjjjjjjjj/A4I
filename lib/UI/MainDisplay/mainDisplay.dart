import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../DayLine/day_line_UI.dart';
import '../Challenge/challenge_page.dart';
import '../PsychologicalTest/select_test.dart';
import '../diary/calender_page.dart';
import '../HelpCenter/help_center_ui.dart';
import '../Report/day_report.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String userNickname = "";
  String randomMessage = "로딩 중...";
  final String nickname = "닉네임";
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserNickname();
    fetchMainMessage();
  }
  void fetchMainMessage() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('main_message')
        .doc('WcxdtReHsCEzkmxzTCSw')
        .get();
    if (doc.exists) {
      List<String> phrases = List<String>.from(doc['phrase']);
      if (phrases.isNotEmpty) {
        setState(() { // UI 업데이트
          randomMessage = phrases[Random().nextInt(phrases.length)];
        });
      }
    }
  }
  void fetchUserNickname() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userNickname = userDoc['nickname']; // Firestore에서 닉네임 가져오기
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAEBF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거
        title: Text(
          "TODAK",
          style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              debugPrint("알람 클릭됨");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "반갑습니다 $userNickname님",
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
              SizedBox(height: 8),
              Text(
                randomMessage,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 16),
              Image.asset(
                'assets/images/Main/main_banner.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildMainButton(
                    "종합 심리 상태 평가",
                    "지난달의 나와 얼마나 달라졌을까요?",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => dayreport()),
                      );
                    },
                  ),
                  buildMainButton(
                    "심리테스트",
                    "4개의 심리테스트가 준비되어있어요",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SelectTestPage()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildSmallButton("일기", "assets/images/Main/diary.png", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarPage()),
                    );
                  }),
                  buildSmallButton("오늘 한줄", "assets/images/Main/daily_line.png", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DayLineScreen()),
                    );
                  }),
                  buildSmallButton("챌린지", "assets/images/Main/challenge.png", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChallengeBadgePage()),
                    );
                  }),
                  buildSmallButton("상담센터", "assets/images/Main/counsel_center.png", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpCenterPage()),
                    );
                  }),
                ],
              ),
              SizedBox(height: 16),
              Image.asset(
                'assets/images/Main/main_chatbot_banner.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainButton(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // 버튼 클릭 시 실행할 함수
      child: Container(
        width: 174,
        height: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                ],
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Color(0xFF585757)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildSmallButton(String label, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 79,
            height: 79, // 컨테이너 높이를 너비와 동일하게 조정
            decoration: BoxDecoration(
              color: Color(0xFFE2D1AE),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect( // 테두리에 맞게 이미지 잘림 방지
              borderRadius: BorderRadius.circular(27),
              child: Image.asset(
                imagePath,
                width: 79, // 컨테이너와 동일한 너비
                height: 79, // 컨테이너와 동일한 높이
                fit: BoxFit.cover, // 버튼 크기에 맞춰 이미지 조정
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
