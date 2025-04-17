import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/Chatbot/prompts.dart';
import 'dart:convert';
import 'dart:convert' as convert;
import '../Report/day_report_process.dart';
import 'chat_analyzer.dart';
import 'voice_chat.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, String>>? initialMessages;
  final String? topicFilter; // 특정 주제를 필터링하기 위한 파라미터
  final String? userId;

  ChatScreen({Key? key, this.initialMessages, this.topicFilter, this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late List<Map<String, String>> messages;
  TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _apiKey = '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 ';
  bool isLoading = false;
  String botName = "토리";

  @override
  void initState() {
    super.initState();

    _loadBotName();

    messages = widget.initialMessages ?? [
      {"sender": "bot", "text": "안녕! 난 토리야. 반가워!"},
      {"sender": "bot", "text": "오늘 기분은 어때? 고민이 있다면 편하게 이야기해줘."},
    ];

    if (widget.topicFilter != null && widget.userId != null) {
      _loadPreviousConversation(widget.topicFilter!, widget.userId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

              if(messages.isNotEmpty && messages[0]["sender"] == "bot") {
                messages[0]["text"] = "안녕! 난 $botName야. 반가워!";
              }
            });
          }
        }
      } catch (e) {
        print('챗봇 이름 로드 오류: $e');
      }
    }
  }

  Future<void> _changeBotName(String newName) async {
    if (user != null && newName.trim().isNotEmpty){
      try{
        await FirebaseFirestore.instance
            .collection('register')
            .doc(user!.uid)
            .update({'botName': newName.trim()});

        setState(() {
          botName = newName.trim();

          messages.add({
            "sender" : "bot",
            "text" : "내 이름이 '$botName'(으)로 변경되었어! 앞으로 $botName(으)로 불러줘!"
          });
        });

        _scrollToBottom();
      } catch (e) {
        print('챗봇 이름 변경 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이름 변경 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _showCangeNameDialog() {
    TextEditingController nameController = TextEditingController(text: botName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('챗봇 이름 변경'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: '새 이름을 입력하세요',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              _changeBotName(nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[100],
            ),
            child: Text('변경'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPreviousConversation(String topic, String userId) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 해당 토픽에 관련된 대화 내역 가져오기
      final chatSnapshot = await FirebaseFirestore.instance
          .collection('register')
          .doc(userId)
          .collection('chat')
          .where('topic', isEqualTo: topic)
          .orderBy('timestamp', descending: false)
          .limit(1) // 토픽별로 가장 오래된 대화 하나만 가져옴
          .get();

      if (chatSnapshot.docs.isNotEmpty) {
        final chatData = chatSnapshot.docs.first.data();
        final summary = chatData['summary'] ?? '대화 내용이 없습니다.';
        final keywords = (chatData['keywords'] as List<dynamic>?)?.join(', ') ?? '';

        setState(() {
          messages.add({
            "sender": "bot",
            "text": "이전 대화 요약: $summary"
          });

          messages.add({
            "sender": "bot",
            "text": "관련 키워드: $keywords"
          });
        });
      }
    } catch (e) {
      print('이전 대화 로드 오류: $e');
    } finally {
      setState(() {
        isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    if (user != null) {
      DocumentSnapshot testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc(user!.uid)
          .collection('firsttest')
          .doc(user!.uid)
          .get();

      DocumentSnapshot registerDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      Map<String, dynamic> data = {};
      if (testDoc.exists) {
        data.addAll(testDoc.data() as Map<String, dynamic>);
      }
      if (registerDoc.exists) {
        data.addAll(registerDoc.data() as Map<String, dynamic>);
      }
      return data.isNotEmpty ? data : null;
    }
  }

  void sendMessage() async {
    Map<String, String> prompts = await loadPrompts();
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": userMessage});
    });
    _controller.clear();

    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "temperature": 0.85,
          "top_p": 0.9,
          "frequency_penalty": 0.7,
          "presence_penalty": 0.8,
          "messages": [
            { "role": "system",
              "content": "${prompts["chatPrompt"]} \n당신의 이름은 $botName입니다.",
            },
            ...messages.map((m) => {
              "role": m["sender"] == "user" ? "user" : "assistant",
              "content": m["text"],
            }),
          ]
        }),
      );

      if (response.statusCode == 200) {
        final utfDecoded = convert.utf8.decode(response.bodyBytes);
        final data = jsonDecode(utfDecoded);
        final reply = data['choices'][0]['message']['content'];

        setState(() {
          messages.add({"sender": "bot", "text": reply.trim()});
        });
        ChatAnalyzer.analyzeAndSaveMessage(userMessage);

      } else {
        jsonDecode(response.body);
        setState(() {
          messages.add({
            "sender": "bot",
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "bot",
        });
      });
    }
  }

  @override
  void dispose() {
    // chat 컬렉션에서 가장 최근 데이터의 timestamp 불러와서 일일보고서 생성
    DayReportProcess.generateReportFromLastChat();
    super.dispose();
  }

  void ChatHistory() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ChatHistory",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(-3, 0),
                  ),
                ],
              ),
              child: ChatHistoryPage(scrollController: ScrollController()),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1, 0),
            end: Offset(0, 0),
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope ( // 리포트 생성 후 뒤로가기 허용
      onWillPop: () async {
        await DayReportProcess.generateReportFromLastChat();
        return true; // 페이지 이동 허용
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.topicFilter != null
              ? Text('${widget.topicFilter} 대화', style: TextStyle(fontWeight: FontWeight.bold))
              : Text('$botName의 채팅방', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFFDFF8FF),
          actions: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showCangeNameDialog,
                tooltip: '챗봇 이름 변경',
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // 대화 내용 저장 함수 호출
                _summarizeAndSaveChat();
              },
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: ChatHistory,
            )
          ],
        ),

        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFDFF8FF),
              ),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "오늘 기분은 어떤가요? 고민이 있다면 편하게 이야기해주세요.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.asset(
                    'assets/Widget/Login/character.png',
                    width: 150,
                    height: 150,
                  ),
                ],
              ),
            ),
            drawCloud(),
            Positioned.fill(
              top: 220,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      padding: EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        bool isBot = msg["sender"] == "bot";
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                            children: isBot
                                ? [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage('assets/Widget/Login/character.png'),
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(botName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 3),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        msg["text"]!,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                                : [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  msg["text"]!,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // 마이크 아이콘
                        CircleAvatar(
                          backgroundColor: Colors.pink[100],
                          child: IconButton(
                            icon: Icon(Icons.mic, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => VoiceChatScreen(messages: messages)),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        // TextField
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요...',
                              filled: true,
                              fillColor: Colors.pink[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // 전송 버튼
                        CircleAvatar(
                          backgroundColor: Colors.pink[100],
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: sendMessage,
                          ),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _summarizeAndSaveChat() async {
    if (messages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대화가 너무 짧아 저장할 수 없습니다.')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 대화 내용 준비
      final conversationText = messages.map((m) {
        return "${m["sender"] == "user" ? "사용자" : botName}: ${m["text"]}";
      }).join("\n");

      // OpenAI API를 사용하여 대화 분석
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": """
              사용자의 메시지를 분석하여 사건을 중심으로 정리하는 역할을 수행해줘.
              주어진 텍스트를 기반으로 사용자의 메시지를 분석해서 핵심 정보를 추출한 후 아래 JSON 형식으로 반환해줘.

              **출력 형식 (JSON)**
              {
                "keywords": ["핵심 키워드1", "핵심 키워드2", "핵심 키워드3"],
                "topic": "주제",
                "emotion": "감정",
                "emotion_intensity": 0.0,
                "summary": "대화 요약"
              }

              **분석 기준**
              - "핵심 키워드": 메시지에서 중요한 단어를 2~3개 추출해줘
              - "주제": 대화의 주요 주제를 한 단어로 정리해줘 (예: "대인관계", "학업", "취업 및 직장")
              - "감정": 메시지에서 가장 강하게 느껴지는 감정을 하나 선택해줘 (예: "행복", "분노", "슬픔", "불안", "놀람", "평온")
              - "emotion_intensity": 감정 강도를 0~1 사이 숫자로 표현해줘
              - "대화 요약": 메시지를 요약하여 1~2문장으로 정리해줘.
              """
            },
            {
              "role": "user",
              "content": conversationText
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final utfDecoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utfDecoded);
        final result = data['choices'][0]['message']['content'];

        try {
          final Map<String, dynamic> analysisResult = jsonDecode(result);

          // Firestore에 저장
          await FirebaseFirestore.instance
              .collection("register")
              .doc(user!.uid)
              .collection("chat")
              .add({
            "timestamp": FieldValue.serverTimestamp(),
            "keywords": analysisResult["keywords"] ?? [],
            "topic": analysisResult["topic"] ?? "일반 대화",
            "emotion": analysisResult["emotion"] ?? "중립",
            "emotion_intensity": analysisResult["emotion_intensity"] ?? 0.5,
            "summary": analysisResult["summary"] ?? "대화 요약 없음",
            "botName" : botName,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('대화가 성공적으로 저장되었습니다.')),
          );
        } catch (e) {
          print('JSON 파싱 오류: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('대화 분석 중 오류가 발생했습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 연결 중 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      print('대화 저장 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대화 저장 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget drawCloud() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: Cloud(),
        child: Container(
          height: 560,
          color: Colors.pink[50],
        ),
      ),
    );
  }
}

class Cloud extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.05, 0, size.width * 0.1, 20);
    path.quadraticBezierTo(size.width * 0.15, 40, size.width * 0.2, 20);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.3, 20);
    path.quadraticBezierTo(size.width * 0.35, 40, size.width * 0.4, 20);
    path.quadraticBezierTo(size.width * 0.45, 0, size.width * 0.5, 20);
    path.quadraticBezierTo(size.width * 0.55, 40, size.width * 0.6, 20);
    path.quadraticBezierTo(size.width * 0.65, 0, size.width * 0.7, 20);
    path.quadraticBezierTo(size.width * 0.75, 40, size.width * 0.8, 20);
    path.quadraticBezierTo(size.width * 0.85, 0, size.width * 0.9, 20);
    path.quadraticBezierTo(size.width * 0.95, 40, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ChatHistoryPage extends StatelessWidget {
  final ScrollController scrollController;
  ChatHistoryPage({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('로그인이 필요합니다.'));
    }

    return Column(
      children: [
        SizedBox(height: 16),
        Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 12),
        Text('히스토리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('대화한 내역을 확인할 수 있어요', style: TextStyle(color: Colors.grey[600])),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('register')
                .doc(user.uid)
                .collection('chat')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('저장된 대화가 없습니다.'));
              }

              // 시간대별로 대화 분류
              final now = DateTime.now();
              final recentChats = <DocumentSnapshot>[];
              final last30DaysChats = <DocumentSnapshot>[];
              final olderChats = <DocumentSnapshot>[];

              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                if (timestamp == null) {
                  continue;
                }

                if (now.difference(timestamp).inDays < 7) {
                  recentChats.add(doc);
                } else if (now.difference(timestamp).inDays < 30) {
                  last30DaysChats.add(doc);
                } else {
                  olderChats.add(doc);
                }
              }

              return ListView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 16),
                  if (recentChats.isNotEmpty) ...[
                    Text('최근', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...recentChats.map((doc) => _buildChatItem(context, doc, user.uid)),
                    Divider(),
                  ],

                  if (last30DaysChats.isNotEmpty) ...[
                    Text('지난 30일', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...last30DaysChats.map((doc) => _buildChatItem(context, doc, user.uid)),
                    Divider(),
                  ],

                  if (olderChats.isNotEmpty) ...[
                    Text('2024년', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...olderChats.map((doc) => _buildChatItem(context, doc, user.uid)),
                  ],
                  SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(BuildContext context, DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    final topic = data['topic'] ?? '대화';
    final emotion = data['emotion'] ?? '중립';
    final summary = data['summary'] ?? '대화 요약 없음';

    // 감정에 따른 아이콘 설정
    IconData emotionIcon = Icons.chat;
    switch (emotion.toLowerCase()) {
      case '행복':
        emotionIcon = Icons.sentiment_very_satisfied;
        break;
      case '분노':
        emotionIcon = Icons.sentiment_very_dissatisfied;
        break;
      case '슬픔':
        emotionIcon = Icons.sentiment_dissatisfied;
        break;
      case '불안':
        emotionIcon = Icons.sentiment_neutral;
        break;
      case '놀람':
        emotionIcon = Icons.sentiment_satisfied;
        break;
      case '평온':
        emotionIcon = Icons.sentiment_satisfied_alt;
        break;
    }

    return ListTile(
      leading: Icon(emotionIcon),
      title: Text(topic),
      subtitle: Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        // 클릭하면 대화 내역 자세히 보기
        _showChatDetail(context, doc, userId);
      },
    );
  }

  void _showChatDetail(BuildContext context, DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    final topic = data['topic'] ?? '대화';
    final summary = data['summary'] ?? '대화 요약 없음';
    final keywords = (data['keywords'] as List<dynamic>?)?.join(', ') ?? '';
    final emotion = data['emotion'] ?? '중립';
    final emotionIntensity = data['emotion_intensity'] ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      topic,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('요약', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(summary),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('키워드', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(keywords),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('감정 상태', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('$emotion (강도: ${(emotionIntensity * 100).toStringAsFixed(0)}%)'),
                              Expanded(
                                child: Slider(
                                  value: emotionIntensity.toDouble(),
                                  min: 0,
                                  max: 1,
                                  divisions: 10,
                                  onChanged: null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 해당 대화 내역으로 이동
                      _loadFullConversation(context, topic, userId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[100],
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('이 대화 내역 불러오기'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _loadFullConversation(BuildContext context, String topic, String userId) {
    // ChatScreen으로 돌아가면서 해당 대화 주제에 맞는 이전 대화 내역을 불러옴

    // 1. 기존 내비게이션 스택에서 ChatScreen을 찾아 제거
    Navigator.popUntil(context, (route) => route.isFirst);

    // 2. 새로운 ChatScreen 시작 - 대화 주제를 인자로 전달
    // 이 부분은 토리 앱의 구조에 맞게 수정해야 합니다
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          initialMessages: [
            {"sender": "bot", "text": "안녕하세요. 이전에 '$topic'에 대해 이야기했던 내용을 불러왔어요."},
            {"sender": "bot", "text": "더 이야기하고 싶은 부분이 있으면 말해주세요!"},
          ],
          topicFilter: topic,
          userId: userId,
        ),
      ),
    );
  }
}