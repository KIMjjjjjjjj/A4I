import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 날짜 및 시간 포맷을 위해 추가
import 'dart:async';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final String defaultProfileImageUrl = 'assets/images/DayLine/default_profile.png';
  String dayTopic = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentUserUid;
  final String topicDocumentId = "tZsVTdoaMu3pDYagWUR1";
  final String textDocumentId = "oiXm2LUYnE4U20OI3VMx";
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, Map<String, String>> userCache = {};
  bool _isTextNotEmpty = false;


  List<Widget> messages = []; // 가져온 메시지 저장
  Timer? _timer;

  // 텍스트 색상 리스트
  final List<String> colorList = [
    "FFF7EF", "FFEFEF", "F7FFEF", "EFF6FF",
  ];

  @override
  void initState() {
    super.initState();
    currentUserUid = _auth.currentUser?.uid ?? '';
    _fetchDayTopic();
    _textController.addListener(_onTextChanged);
    //_startFetchingMessages(); // 1초마다 메시지 업데이트 시작
  }

  void _onTextChanged() {
    bool isNotEmpty = _textController.text.trim().isNotEmpty;
    if(_isTextNotEmpty != isNotEmpty){
      setState(() {
        _isTextNotEmpty = _textController.text.trim().isNotEmpty;
      });
    }
  }

/*  // 1초마다 메시지 업데이트
  void _startFetchingMessages() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      List<Widget> newMessages = await _fetchMessages();
      setState(() {
        messages = newMessages;
      });
    });
  }*/

  @override
  void dispose() {
    _timer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchDayTopic() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('day_line').doc(topicDocumentId).get();
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

  Future<Map<String, String>> _getUserInfo(String uid) async {
    if (userCache.containsKey(uid)) {
      return userCache[uid]!;
    } else {
      DocumentSnapshot userDoc = await _firestore.collection('register').doc(uid).get();
      String nickname = userDoc['nickname'];
      String profileImageUrl = userDoc['profileImageUrl'] ?? defaultProfileImageUrl;
      userCache[uid] = {'nickname': nickname, 'profileImageUrl': profileImageUrl};
      return userCache[uid]!;
    }
  }

/*
  Future<List<Widget>> _fetchMessages() async {
    List<Widget> messageWidgets = [];
    try {
      print("메시지 가져오기 시작...");  // 디버깅: 시작 출력

      QuerySnapshot snapshot = await _firestore.collection('day_line')
          .doc(textDocumentId)
          .collection('messages')
          .orderBy('text_time', descending: false)
          .get();

      print("메시지 가져오기 완료, 총 ${snapshot.docs.length}개의 메시지");  // 디버깅: 가져온 메시지 개수 출력

      for (var doc in snapshot.docs) {
        try {
          String uid = doc['uid'];
          String lineText = doc['line_text'];
          String lineColor = doc['line_color'];
          Timestamp timestamp = doc['text_time'];

          print("메시지 데이터: uid=$uid, lineText=$lineText, lineColor=$lineColor, timestamp=$timestamp"); // 디버깅: 각 메시지 데이터 출력

          // 사용자 정보 가져오기
          DocumentSnapshot userDoc = await _firestore.collection('register').doc(uid).get();
          String nickname = userDoc['nickname'];
          String? profileImageUrl = userDoc['profileImageUrl'];

          // profileImageUrl이 null일 경우 기본 이미지 URL 사용
          String imageUrlToUse = profileImageUrl ?? defaultProfileImageUrl;

          print("사용자 정보: nickname=$nickname, profileImageUrl=$profileImageUrl"); // 디버깅: 사용자 정보 출력

          // 현재 사용자 채팅 패널과 다른 사용자 채팅 패널을 구분
          if (uid == currentUserUid) {
            messageWidgets.add(currentUserChatPanel(nickname, imageUrlToUse, lineColor, lineText, timestamp));
          } else {
            messageWidgets.add(otherUserChatPanel(nickname, imageUrlToUse, lineColor, lineText, timestamp));
          }
        } catch (e) {
          print("메시지 처리 중 오류: $e");  // 디버깅: 메시지 처리 오류 출력
        }
      }
    } catch (e) {
      print("메시지 가져오기 오류: $e");  // 디버깅: 메시지 가져오기 오류 출력
    }
    return messageWidgets;
  }*/



  // 메시지 전송 시간 계산 (분, 시간, 일 단위로 출력)
  String _getTimeAgo(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    Duration diff = DateTime.now().difference(messageTime);
    if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inMinutes}분 전';
    }
  }

// 현재 사용자 채팅 패널
  Widget otherUserChatPanel(String nickname, String profileImageUrl, String lineColor, String lineText, Timestamp timestamp) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundImage: profileImageUrl == defaultProfileImageUrl
                ? AssetImage(defaultProfileImageUrl) as ImageProvider
                : NetworkImage(profileImageUrl),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              SizedBox(height: 5),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6, // ✅ 최대 너비 제한
                ),
                decoration: BoxDecoration(
                  color: Color(int.parse("0xFF$lineColor")),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  lineText,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 5),
              Text(
                _getTimeAgo(timestamp),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // 다른 사용자 채팅 패널
  Widget currentUserChatPanel(String nickname, String profileImageUrl, String lineColor, String lineText, Timestamp timestamp) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nickname,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              SizedBox(height: 5),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6, // ✅ 최대 너비 제한
                ),
                decoration: BoxDecoration(
                  color: Color(int.parse("0xFF$lineColor")),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  lineText,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 5),
              Text(
                _getTimeAgo(timestamp),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 23,
            backgroundImage: profileImageUrl == defaultProfileImageUrl
                ? AssetImage(defaultProfileImageUrl) as ImageProvider
                : NetworkImage(profileImageUrl),
          ),
        ],
      ),
    );
  }



  void _sendMessage() async {
    if(_textController.text.isEmpty)
      return;
    String message = _textController.text;
    if (message.trim().isNotEmpty) {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String color = (colorList..shuffle()).first;  // 색상 랜덤으로 선택
      Timestamp timestamp = Timestamp.now();

      try {
        await _firestore.collection('day_line').doc('oiXm2LUYnE4U20OI3VMx').collection('messages').add({
          'line_color': color,
          'line_text': message,
          'text_time': timestamp,
          'uid': uid,
        });

        print("메시지 전송 완료!");
        _textController.clear();
      } catch (e) {
        print("메시지 전송 오류: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFE6FFFD),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 0,
                child: Image.asset(
                  'assets/images/DayLine/topic_cloud.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              ),
              Positioned(
                bottom: 30,
                child: Text(
                  dayTopic,
                  style: TextStyle(fontSize: 18, height: 21 / 20, color: Color(0xFF4F4949)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 63, // 입력창보다 살짝 위로 배치
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/DayLine/background_image.png',
                fit: BoxFit.none, // 원본 크기 유지
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child:GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('day_line')
                        .doc(textDocumentId)
                        .collection('messages')
                        .orderBy('text_time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("오류 발생: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("메시지가 없습니다."));
                      }
                      List<Widget> messageWidgets = snapshot.data!.docs.map((doc) {
                        String uid = doc['uid'];
                        String lineText = doc['line_text'];
                        String lineColor = doc['line_color'];
                        Timestamp timestamp = doc['text_time'];

                        // 사용자 정보 가져오기
                        return FutureBuilder<Map<String, String>>(
                          future: _getUserInfo(uid),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return SizedBox(); // 로딩 중인 경우 빈 위젯 반환
                            }
                            String nickname = userSnapshot.data!['nickname']!;
                            String profileImageUrl = userSnapshot.data!['profileImageUrl']!;

                            if (uid == currentUserUid) {
                              return currentUserChatPanel(nickname, profileImageUrl, lineColor, lineText, timestamp);
                            } else {
                              return otherUserChatPanel(nickname, profileImageUrl, lineColor, lineText, timestamp);
                            }
                          },
                        );
                      }).toList();

                      _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                      );

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ListView(
                          reverse: true,
                          shrinkWrap: true,
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          children: messageWidgets,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: Color(0xFFD9AEAE).withOpacity(0.9),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                        color: Color(0xFFE6BCA9),
                        borderRadius: BorderRadius.circular(21.5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: "자유롭게 한 줄을 적어보세요.",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (value){//엔터 입력시 메세지 전송
                                if(_isTextNotEmpty){
                                  _sendMessage();
                                }
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: _isTextNotEmpty ? _sendMessage : null,
                            child: Icon(
                              Icons.send,
                              color: _isTextNotEmpty ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
