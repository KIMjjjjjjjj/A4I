import 'package:flutter/material.dart';
import 'Find_Password_UI.dart';

class LoginFormScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF8F8),
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 로고 이미지
            Image.asset(
              'assets/Widget/Login/logo.png',
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20), // 로고와 아이디 입력 필드 간격

            // 아이디 입력 필드 - input_frame 이미지 위에 배치
            Stack(
              alignment: Alignment.center,
              children: [
                // input_frame 이미지
                Image.asset(
                  'assets/Widget/Login/input_frame.png',
                  fit: BoxFit.cover,
                ),
                // 아이디 입력 필드
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: usernameController,
                    style: TextStyle(color: Color(0xFF000000), fontSize: 20),
                    decoration: InputDecoration(
                      hintText: '아이디 입력',
                      hintStyle: TextStyle(color: Color(0xFFCECECE), fontSize: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20), // 아이디와 비밀번호 입력 필드 간격

            // 비밀번호 입력 필드 - input_frame 이미지 위에 배치
            Stack(
              alignment: Alignment.center,
              children: [
                // input_frame 이미지
                Image.asset(
                  'assets/Widget/Login/input_frame.png',
                  fit: BoxFit.cover,
                ),
                // 비밀번호 입력 필드
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Color(0xFF000000), fontSize: 20),
                    decoration: InputDecoration(
                      hintText: '비밀번호 입력',
                      hintStyle: TextStyle(color: Color(0xFFCECECE), fontSize: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20), // 입력 필드와 버튼 간격

            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                // 로그인 버튼 눌렀을 때 아이디와 비밀번호 출력 (디버깅)
                String username = usernameController.text;
                String password = passwordController.text;
                print('Username: $username');
                print('Password: $password');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(300, 60),
                backgroundColor: Colors.transparent,
              ),
              child: Image.asset(
                'assets/Widget/Login/login_button.png',
                fit: BoxFit.cover,
              ),
            ),

            // 비밀번호 찾기 텍스트 버튼
            TextButton(
              // 클릭시 디버깅 출력
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
