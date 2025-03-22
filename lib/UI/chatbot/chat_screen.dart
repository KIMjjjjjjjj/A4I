import 'package:flutter/material.dart';
import 'voice_chat.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade100,
        title: Text(
          '토리의 채팅방',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [Icon(Icons.menu)],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.yellow.shade100,
            width: double.infinity,
            child: Text(
              '오늘 기분은 어떤가요? 고민이 있다면 편하게 이야기해주세요.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.pink.shade50,
              child: Column(
                children: [
                  Image.asset(
                    'assets/Widget/Login/character.png',
                    height: 150,
                  ),
                  ChatBubble(
                    avatar: 'assets/Widget/Login/character.png',
                    name: '토리',
                    message: '안녕! 난 토리예요. 반가워요!',
                    isUser: false,
                  ),
                  ChatBubble(
                    avatar: 'assets/Widget/Login/character.png',
                    name: '토리',
                    message: '오늘 기분은 어떤가요?',
                    isUser: false,
                  ),
                  ChatBubble(
                    avatar: '',
                    name: '사용자',
                    message: '안녕',
                    isUser: true,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.pink.shade100,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VoiceChatScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String avatar;
  final String name;
  final String message;
  final bool isUser;

  ChatBubble({required this.avatar, required this.name, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            backgroundImage: AssetImage(avatar),
            radius: 20,
          ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isUser ? Colors.white : Colors.pink.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
