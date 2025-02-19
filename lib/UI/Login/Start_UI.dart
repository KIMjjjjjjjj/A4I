import 'package:flutter/material.dart';
import 'Login_UI.dart';  // 새로운 화면 클래스를 import
import 'SignUp_UI.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF8F8), // 배경 색상 변경
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 캐릭터
            Image.asset(
              'assets/Widget/Login/character.png',
              width: 195,
              height: 195,
            ),
            // 문구 이미지
            Image.asset(
              'assets/Widget/Login/phrase.png',
              width: 200,
              height: 100,
            ),
            SizedBox(height: 50), // 이미지 간격 / 현재 중앙 정렬
            // 회원가입 버튼
            ElevatedButton(
              onPressed: () {
                // 회원가입 버튼 클릭 시 이벤트 처리 -> 회원가입 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(150, 50),
                backgroundColor: Colors.transparent, // 배경을 투명하게
              ),
              child: Image.asset(
                'assets/Widget/Login/button1.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20), // 버튼 간격
            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                // 로그인 버튼 클릭 시 이벤트 처리 - > 로그인 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginFormScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(150, 50),
                backgroundColor: Colors.transparent,
              ),
              child: Image.asset(
                'assets/Widget/Login/button2.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
