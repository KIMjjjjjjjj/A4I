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
import '../chatbot/chatbot_home.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String userNickname = "";
  String randomMessage = "로딩 중...";
  final User? user = FirebaseAuth.instance.currentUser;

  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchUserNickname();
    fetchMainMessage();

    // 3초마다 페이지 자동 전환
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 2;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void fetchMainMessage() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('main_message')
        .doc('WcxdtReHsCEzkmxzTCSw')
        .get();
    if (doc.exists) {
      List<String> phrases = List<String>.from(doc['phrase']);
      if (phrases.isNotEmpty) {
        setState(() {
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
          userNickname = userDoc['nickname'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("앱 종료"),
            content: Text("앱을 종료하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("아니요"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("예"),
              ),
              SizedBox(height: 16),
              // Image.asset(
              //   'assets/images/Main/main_banner.png',
              //   width: double.infinity,
              //   fit: BoxFit.fitWidth,
              // ),
            ],
          ),
        );

        if (exit) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFEAEBF0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                Column(
                  children: [
                    Container(
                      height: 150,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          Image.asset(
                            'assets/images/Main/main_banner.png',
                            fit: BoxFit.fitWidth,
                          ),
                          Image.asset(
                            'assets/images/Main/main_banner2.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? Colors.black : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ],
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
                SizedBox(height: 30),
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
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatbotScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Main/main_chatbot_banner.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMainButton(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
            height: 79,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: Image.asset(
                imagePath,
                width: 79,
                height: 79,
                fit: BoxFit.cover,
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
