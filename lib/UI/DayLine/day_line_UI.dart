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
  bool visitDataClear = false;

  @override
  void initState() {
    super.initState();
    _fetchVisitorCount();
    _fetchDayTopic();
    if (!visitDataClear) {
      _clearOldVisitors(); // 하루 한 번 초기화
      visitDataClear = true;
    }

  }

  // 오늘 날짜 가져오기 (시간 제외)
  String _getTodayDateString() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month}.${now.day}";
  }
  // 방문자 수 가져오기
  Future<void> _fetchVisitorCount() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('day_line')
          .doc(visitorsDocumentId)
          .collection('visitor')
          .get();

      setState(() {
        visitorCount = snapshot.size; // 문서 개수를 방문자 수로 사용
      });
    } catch (e) {
      print("방문자 수 가져오기 오류: $e");
    }
  }

  // 오늘 날짜가 아닌 방문자 문서 삭제 (
  Future<void> _clearOldVisitors() async {
    try {
      CollectionReference visitorCollection = _firestore
          .collection('day_line')
          .doc(visitorsDocumentId)
          .collection('visitor');

      QuerySnapshot snapshot = await visitorCollection.get();
      DateTime today = DateTime.now();

      for (var doc in snapshot.docs) {
        Timestamp timeStamp = doc['timeStamp'];
        DateTime visitDate = timeStamp.toDate();

        // 오늘 날짜 아니면 삭제
        if (visitDate.year != today.year ||
            visitDate.month != today.month ||
            visitDate.day != today.day) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("이전 방문자 데이터 삭제 오류: $e");
    }
  }

  // 방문자 문서 추가 (uid 기반으로 중복 방지)
  Future<void> _incrementVisitorCount() async {
    if (user == null) return;

    try {
      DocumentReference visitorDocRef = _firestore
          .collection('day_line')
          .doc(visitorsDocumentId)
          .collection('visitor')
          .doc(user!.uid);

      DocumentSnapshot visitorSnapshot = await visitorDocRef.get();

      // 같은 uid 없으면 추가 (첫 방문)
      if (!visitorSnapshot.exists) {
        await visitorDocRef.set({
          'timeStamp' : FieldValue.serverTimestamp(),
        });

        // 방문자 수 다시 가져오기
        _fetchVisitorCount();
      }

      // 페이지 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GroupChatScreen()),
      );
    } catch (e) {
      print("방문자 수 업데이트 오류: $e");
    }
  }

  // 오늘의 주제 가져오기
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
