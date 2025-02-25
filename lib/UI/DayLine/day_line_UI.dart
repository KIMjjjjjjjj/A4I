import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_chat_UI.dart';

class DayLineScreen extends StatefulWidget {
  @override
  _DayLineScreenState createState() => _DayLineScreenState();
}

class _DayLineScreenState extends State<DayLineScreen> {
  int visitorCount = 0; // 방문자 수
  String dayTopic = "";
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String visitorsDocumentId = "I4mc3vHFE0dkWVC9dfmr";
  final String topicDocumentId = "tZsVTdoaMu3pDYagWUR1";

  @override
  void initState() {
    super.initState();
    _fetchVisitorCount();
    _fetchDayTopic();
  }

  // 방문자 수 가져오기
  Future<void> _fetchVisitorCount() async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('day_line').doc(visitorsDocumentId).get();
      if (doc.exists) {
        setState(() {
          visitorCount = doc['visitors'] ?? 0;
        });
      }
    } catch (e) {
      print("방문자 수 가져오기 오류: $e");
    }
  }

  Future<void> _fetchDayTopic() async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('day_line').doc(topicDocumentId).get();
      if (doc.exists) {
        List<String> topics = List<String>.from(doc['day_topic']);
        int today = DateTime.now().day;
        setState(() {
          dayTopic = topics[today - 1];
        });
      }
    } catch (e) {
      print("오늘의 주제 가져오기 오류: $e");
    }
  }

  // 방문자 수 증가시키기
  Future<void> _incrementVisitorCount() async {
    try {
      DocumentReference docRef =
      _firestore.collection('day_line').doc(visitorsDocumentId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("문서가 존재하지 않습니다.");
        }
        int newCount = (snapshot['visitors'] ?? 0) + 1;
        transaction.update(docRef, {'visitors': newCount});
        setState(() {
          visitorCount = newCount;
        });
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GroupChatScreen()),
      );
    } catch (e) {
      print("방문자 수 업데이트 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAEBF0),
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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 313,
            height: 670,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(27),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "오늘의 방문자 수",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$visitorCount",
                    style: TextStyle(
                      fontSize: 40,
                      height: 21 / 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 25),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/images/DayLine/speech_bubble.png'),
                    Positioned(
                      child: SizedBox(
                        width: 200, // 말풍선 내부 텍스트가 들어갈 최대 너비 설정
                        child: Text(
                          dayTopic,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center,
                          softWrap: true, // 자동 줄바꿈 허용
                          overflow: TextOverflow.ellipsis, // 길면 ... 표시
                          maxLines: 2, // 최대 2줄까지만 표시
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 0),
                Image.asset('assets/images/DayLine/letter_HARU.png'),
                SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6BE5A0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fixedSize: Size(148, 57),
                  ),
                  onPressed: _incrementVisitorCount, // 버튼 클릭 시 방문자 수 증가
                  child: Text(
                    "입장하기",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
