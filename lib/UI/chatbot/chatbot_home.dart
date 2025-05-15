import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../../bottom_navigation_bar.dart';
import 'character_selector.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String botName = '토리';
  bool isLoading = true;
  String selectedCharacterImage = 'assets/Widget/Login/character.png';
  String selectedPrompt = '기본 성격';

  @override
  void initState() {
    super.initState();
    _loadBotName();
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
              isLoading = false;
            });
          } else{
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('챗봇 이름 로드 오류: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _updateCharacter(String imagePath, String prompt) {
    setState(() {
      selectedCharacterImage = imagePath;
      selectedPrompt = prompt;
    });
  }

  void _showCharacterSelector() {
    double screenHeight = MediaQuery.of(context).size.height;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "캐릭터 선택",
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: screenHeight * 0.7,
              child: CharacterSelectorDialog(
                onCharacterSelected: (image, prompt) {
                  _updateCharacter(image, prompt); // 이미지와 프롬프트 저장
                },
              ), // 내부에서 Card만 보여주게 구성
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFBBEDFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) =>  CustomNavigationBar()),
                    (route) => false,
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: double.infinity,
            height: screenHeight * 0.9,
            //padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 배경 그라데이션
                Container(
                  height: screenHeight, // 필요 시 이 부분도 수정 가능
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFBBEDFF), Colors.white],
                    ),
                  ),
                ),

                // 나무 기둥
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.01),
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.7,
                    color: Color(0xFFD99880),
                  ),
                ),

                // 말풍선 텍스트 박스
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.05),
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.5,
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5D7CC),
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "안녕하세요! 저는 $botName라고 해요\n"
                              "여러분의 마음친구가 되어줄\n귀여운 고양이 챗봇이에요.\n\n"
                              "🎀 힘들 때, 외로울 때,\n$botName를 찾아주세요! 🎀\n\n"
                              "언제나 여러분의 이야기를\n귀기울여 들을 준비가 되어있어요.\n\n"
                              "🐾 \"마음을 열어보세요.\n$botName가 함께할게요!\" 🐾",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          //onPressed: _showCharacterSelector,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(selectprompt: selectedPrompt),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEEFDEA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(29),
                              side: BorderSide(color: Color(0xFFEBEEFF)),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 40,
                            ),
                          ),
                          child: Text(
                            "$botName랑 대화하기",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          "*고양이를 쓰다담어 보세요",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Color(0xFF0A2833)),
                        ),
                      ],
                    ),
                  ),
                ),

                // 고양이 이미지
                // 고양이 이미지 (터치 가능하도록 변경됨)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.6),
                    child: GestureDetector(
                      onTap: _showCharacterSelector,
                      child: Image.asset(
                        selectedCharacterImage,
                        width: screenWidth * 0.55,
                      ),
                    ),
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