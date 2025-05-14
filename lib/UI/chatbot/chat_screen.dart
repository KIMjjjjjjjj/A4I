import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:repos/UI/chatbot/OpenAPI/prompts.dart';
import 'dart:convert';
import 'dart:convert' as convert;
import '../Report/day_report_process.dart';
import 'OpenAPI/call_api.dart';
import 'chat_analyzer.dart';
import 'chat_emotion_character.dart';
import 'voice_chat.dart';
import '../../bottom_navigation_bar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, String>>? initialMessages;
  final String? topicFilter; // 특정 주제를 필터링하기 위한 파라미터
  final String? userId;
  final String selectprompt;

  static List<Map<String, String>>? cachedInitialMessages;

  ChatScreen({Key? key, this.initialMessages, this.topicFilter, this.userId, required this.selectprompt}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late List<Map<String, String>> messages;
  TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  static int lastReadIndex = 0;


  String _detectedEmotion = 'neutral';
  double _detectedIntensity = 0.0;
  bool isLoading = false;
  String botName = "토리";

  @override
  void initState() {
    super.initState();

    _loadBotName();

    if (widget.initialMessages != null) {
      messages = widget.initialMessages!;
    } else if (ChatScreen.cachedInitialMessages != null && ChatScreen.cachedInitialMessages!.isNotEmpty) {
      messages = ChatScreen.cachedInitialMessages!;
    } else {
      messages = [];
      _loadLocalMessages();
    }

    if (widget.topicFilter != null && widget.userId != null) {
      _loadPreviousConversation(widget.topicFilter!, widget.userId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _loadLocalMessages() async {
    final loaded = await loadMessages();

    if (loaded.isEmpty) {
      // 기본 초기 메시지
      setState(() {
        messages = [
          {"sender": "bot", "text": "안녕! 난 $botName야. 반가워!"},
          {"sender": "bot", "text": "오늘 기분은 어때? 고민이 있다면 편하게 이야기해줘."},
        ];
        lastReadIndex = messages.length;
      });
    } else if (loaded.length > lastReadIndex) {
      // 저장된 메시지 중에서 새로운 것만 추가
      final newMessages = loaded.sublist(lastReadIndex);
      setState(() {
        messages.addAll(newMessages);
        lastReadIndex = loaded.length;
      });
    }
  }

  Future<void> appendMessage(Map<String, String> message) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_history.json');

    List<Map<String, String>> updated = [];

    if (await file.exists()) {
      final contents = await file.readAsString();
      final List decoded = jsonDecode(contents);
      updated = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    updated.add(message);
    await file.writeAsString(jsonEncode(updated));
  }

  Future<List<Map<String, String>>> loadMessages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_history.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List decoded = jsonDecode(contents);
        return decoded.map((e) => Map<String, String>.from(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("대화 기록 로드 실패: $e");
      return [];
    }
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
          maxLength: 10,
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

  void _updateChatEmotionCharacter(String newEmotion, double newIntensity) {
    setState(() {
      _detectedEmotion = newEmotion;
      _detectedIntensity = newIntensity;
    });
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
        _scrollController.position.minScrollExtent,
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
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": userMessage});
    });

    await appendMessage({"sender": "user", "text": userMessage});

    _controller.clear();

    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      Map<String, String> prompts = await loadPrompts();

      final selectedPrompt = prompts[widget.selectprompt] ?? prompts["chatPrompt"] ?? '';

      final response = await callOpenAIChat(
        prompt: selectedPrompt,
        messages: messages,
      );

      if (response != null) {
        final botMessage = {"sender": "bot", "text": response.trim()};
        setState(() {
          messages.add(botMessage);
        });

        await appendMessage(botMessage);

        Future.microtask(() async {
          final result = await ChatAnalyzer.analyzeSingleMessage(userMessage);
          final emotion = result["emotion"];
          final intensity = result["emotion_intensity"];
          _updateChatEmotionCharacter(emotion, intensity);
        });
        ChatAnalyzer.handleCombineMessage(userMessage);
      } else {
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
    _focusNode.dispose();
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
              child: ChatHistoryPage(scrollController: ScrollController(), selectprompt: '',),
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
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = keyboardHeight > 0;

    return WillPopScope ( // 리포트 생성 후 뒤로가기 허용
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('홈으로 돌아가시겠습니까?', style: TextStyle(fontSize: 20),),
            content: Text('대화를 종료하고 홈화면으로 이동합니다.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니오'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) =>  CustomNavigationBar()),
                        (route) => false,
                  );
                },
                child: Text('예'),
              ),
            ],
          )
        );

        if(shouldPop == true){
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !await ChatAnalyzer.timecheck(user.uid)) {
            await ChatAnalyzer.analyzeCombinedMessages();
          }
          await DayReportProcess.generateReportFromLastChat();
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
            /*IconButton(
              icon: Icon(Icons.save),
              onPressed: ()  {
                // 대화 분석 저장 함수 호출
                ChatAnalyzer.analyzeVisibleMessages(messages, user!.uid);
              },
            ),*/
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
              top: 0,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child:EmotionCharacter(
                  emotion: _detectedEmotion,
                  intensity: _detectedIntensity,
                  width: 200,
                  height: 200
              ),
            ),
            drawCloud(),
            Positioned.fill(
              top: isKeyboardOpen
                  ? MediaQuery.of(context).size.height * 0.15
                  : MediaQuery.of(context).size.height * 0.2,
              child: Column(
                children: [
                  Expanded(
                    child:Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        padding: EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          final msg = messages.reversed.toList()[index];
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
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                    ]
                                  )
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        _focusNode.requestFocus(); // 텍스트 필드 포커스 요청 -> 키보드 올라옴
                      },
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
                                  MaterialPageRoute(builder: (context) => VoiceChatScreen(messages: messages, selectprompt: '',)),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          // TextField
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawCloud() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final baseHeight = MediaQuery.of(context).size.height * 0.7;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipPath(
        clipper: Cloud(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: keyboardHeight > 0
            ? baseHeight - keyboardHeight * 0.85
            : baseHeight,
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
  final String selectprompt;
  ChatHistoryPage({required this.scrollController, required this.selectprompt});

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
          selectprompt: selectprompt,
        ),
      ),
    );
  }
}