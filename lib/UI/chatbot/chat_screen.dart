import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as convert;
import 'voice_chat.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, String>>? initialMessages;

  ChatScreen({Key? key, this.initialMessages}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Map<String, String>> messages;
  TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _apiKey = '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 ';

  @override
  void initState() {
    super.initState();
    messages = widget.initialMessages ?? [
      {"sender": "bot", "text": "안녕! 난 토리에요. 반가워요!"},
      {"sender": "bot", "text": "오늘 기분은 어떤가요? 고민이 있다면 편하게 이야기해주세요."},
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  void sendMessage() async {
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
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
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
    return Scaffold(
      appBar: AppBar(
        title: Text('토리의 채팅방', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor : Color(0xFFDFF8FF),
        actions: [
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
                                  Text('토리', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
    );
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

  final List<String> recentChats = [
    'AI 산업 전망',
    '대인관계 고민',
    '소화불량',
  ];
  final List<String> oldChats = [
    '1:1 대전 게임 개발',
    '피보나치 수열',
    '안녕하세요 대화',
  ];

  @override
  Widget build(BuildContext context) {
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
        Text('토리와 대화한 내역을 확인할 수 있어요', style: TextStyle(color: Colors.grey[600])),

        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              SizedBox(height: 16),
              Text('최근', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recentChats.map((chat) => ListTile(title: Text(chat))),
              Divider(),
              Text('지난 30일', style: TextStyle(fontWeight: FontWeight.bold)),
              ...oldChats.map((chat) => ListTile(title: Text(chat))),
              Divider(),
              Text('2024년', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}