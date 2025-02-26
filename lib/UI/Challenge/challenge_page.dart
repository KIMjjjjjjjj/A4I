import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChallengeBadgePage extends StatefulWidget {
  @override
  _ChallengeBadgePageState createState() => _ChallengeBadgePageState();
}

class _ChallengeBadgePageState extends State<ChallengeBadgePage> {
  final PageController pageController = PageController(initialPage: 0);
  final User? user = FirebaseAuth.instance.currentUser;
  final ChallengeService challengeService = ChallengeService();
  String? profileImageUrl;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc['profileImageUrl'];
        });
      }
    }
  }

  Future<List<bool>> fetchChallengeStatuses() async {
    if (user == null) {
      return [false, false, false];
    }

    return [
      await challengeService.isChallengeCompleted(user!.uid, "attendance100"),
      await challengeService.isChallengeCompleted(user!.uid, "diary7"),
      await challengeService.isChallengeCompleted(user!.uid, "test1"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentIndex == 0 ? '도전과제' : '칭호',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEFEFF4),
        elevation: 0,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildFixedHeader(),
              buildToggleButtons(),
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  children: [
                    buildChallengeScreen(),
                    buildBadgeScreen(),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      )
    );
  }

  Widget buildFixedHeader() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color(0xFF7BD3EA),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              children: [
                profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(profileImageUrl!),
                )
                    : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[400],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(3),
                        width: 145,
                        decoration: BoxDecoration(
                          color: Color(0xFFE6FFFD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(0xFFD9D9D9),
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.white,
                                child: Text(
                                    '100일',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 5)
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                                '100일 연속 출석',
                                style: TextStyle(fontSize: 12, color: Color(0xFF00A6FF),)
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 5),
                    Text('도전과제 달성률 : 54%'),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 230,
                      child: LinearProgressIndicator(
                        value: 0.54,
                        backgroundColor: Colors.white,
                        color: Color(0xFF6BE5A0),
                        borderRadius: BorderRadius.circular(20),
                        minHeight: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton("도전과제", 0),
        _buildToggleButton("칭호", 1),
      ],
    );
  }

  Widget _buildToggleButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(index,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: currentIndex == index ? Color(0xFF7BD3EA) : Color(0xFFE6FFFD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: currentIndex == index ? Color(0xFFE6FFFD) : Color(0xFF7BD3EA),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 도전과제 화면
  Widget buildChallengeScreen() {
    return FutureBuilder<List<bool>>(
      future: fetchChallengeStatuses(),
      builder: (context, snapshot) {
        List<bool> challengeStatuses = snapshot.data ?? [false, false, false];

        return Center(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 30,
            crossAxisSpacing: 20,
            children: [
              _buildChallengeCard('총 출석을 100일 달성', '100일', challengeStatuses[0]),
              _buildChallengeCard('', '', false),
              _buildChallengeCard('일기 연속 7일 쓰기', '7일', challengeStatuses[1]),
              _buildChallengeCard('심리테스트 1회 테스트 하기', '1회', challengeStatuses[2]),
              _buildChallengeCard('', '', false),
              _buildChallengeCard('', '', false),
              _buildChallengeCard('', '', false),
              _buildChallengeCard('', '', false),
            ],
          ),
        );
      },
    );

  }

  // 칭호 화면
  Widget buildBadgeScreen() {
    return Center(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF7BD3EA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFE6FFFD),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '내가 보유한 칭호',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20, color: Color(0xFF0091B2), fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                // 칭호 리스트
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 30,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 6,
                    children: [
                      _buildBadgeCard('100일 연속 출석', true),
                      _buildBadgeCard('일찬 한주', true),
                      _buildBadgeCard('심리테스트 초보', true),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                      _buildBadgeCard('???', false),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ]
            )
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(String title, String subtitle, bool success) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 170,
          height: 200,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: Color(0xFF7BD3EA),
              borderRadius: BorderRadius.circular(40)
          ),
          child: Container(
            width: 165,
            height: 195,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Color(0xFFE6FFFD),
                borderRadius: BorderRadius.circular(40)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFD9D9D9),
                    child: CircleAvatar(
                      radius: 31,
                      backgroundColor: Colors.white,
                      child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12)
                      ),
                    ),
                  ),
                ],
                if (title.isNotEmpty) ...[
                  SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: Text(
                      title.replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
        if (success) ...[
          Positioned(
            top: 90,
            left: 75,
            child: Image(
              image: AssetImage('assets/images/success.png'),
              height: 110,
              width: 110,
            ),
          )
        ]
      ],
    );
  }

  Widget _buildBadgeCard(String title, bool isAchieved) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAchieved ? Color(0xFFE6FFFD) : Colors.grey[400],
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, size: 16, color: isAchieved ? Colors.blue : Colors.black),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isAchieved ? Color(0xFF00A6FF) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeService {
  // 도전과제 성공 여부
  Future<bool> isChallengeCompleted(String userId, String challengeId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('register')
        .doc(userId)
        .collection('challenges')
        .doc(challengeId)
        .get();

    print("📌 $challengeId 도전과제 데이터: ${userDoc.data()}");

    return userDoc.exists && (userDoc['achieved'] ?? false);
  }

  // // 출석 기록 저장
  // Future<void> saveAttendance(String userId) async {
  //   String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
  //   await FirebaseFirestore.instance
  //       .collection('register')
  //       .doc(userId)
  //       .collection('attendance')
  //       .doc(today)
  //       .set({'date': today, 'status': 'present'});
  // }
  //
  // // 총 출석 일수
  // Future<int> getTotalAttendance(String userId) async {
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('register')
  //       .doc(userId)
  //       .collection('attendance')
  //       .get();
  //   return snapshot.docs.length; // 출석한 날의 개수
  // }

}

