import 'package:flutter/material.dart';
import 'Find_Password_UI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';
import '../survey/Firstsurvey_explain.dart';
import '../Setting/setting_page.dart';

class LoginPage extends StatefulWidget{
  @override
  LoginFormScreen createState() => LoginFormScreen();
}



class LoginFormScreen extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String errorText = "";
  String? emailErrorMessage;
  String? passwordErrorMessage;

  String checkEmailErrorText() {
    if (emailController.text.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    return ""; // 유효한 경우 null 반환
  }

  String checkPWErrorText() {
    if (passwordController.text.isEmpty) return '비밀번호를 입력해주세요.';
    return "";
  }

  // 이메일 형식 확인 로직
  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }


  void signIn() async {
    String userEmail;
    String userID;
    setState(() {
      errorText = checkEmailErrorText(); // 이메일 오류 메시지 설정
      if(!isValidEmail(emailController.text.trim()) && errorText == ""){
        errorText = '이메일 형식이 옳바르지 않습니다.';
      }
      if(errorText == ""){
        errorText = checkPWErrorText(); // 비밀번호 오류 메시지 설정
      }
    });

    if (errorText != "") {
      return;
    }

    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String username = emailController.text;
      String password = passwordController.text;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SurveyExplainPage()),
      );

      print('Username: $username');
      print('Password: $password');

      emailController.clear();
      passwordController.clear();
    } catch(e){
      setState(() {
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            print('user-not=found');
            errorText = '이메일이 일치하지 않습니다.';
          } else if (e.code == 'wrong-password') {
            print('wrong-not=found');
            errorText = '비밀번호가 일치하지 않습니다.';
          }
        }
      });
    }
  }


  Widget loginWidget(){
    return
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
              controller: emailController,
              style: TextStyle(color: Color(0xFF000000), fontSize: 20),
              decoration: InputDecoration(
                hintText: '아이디 입력',
                hintStyle: TextStyle(color: Color(0xFFCECECE), fontSize: 20),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      );
  }


  Widget passwordWidget(){
    return
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
      );
  }

  Widget loginButton(){
    return
      // 로그인 버튼
      ElevatedButton(
        onPressed: () {
          signIn();
          // 로그인 버튼 눌렀을 때 아이디와 비밀번호 출력 (디버깅)
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
      );
  }

  Widget findPassword(){
    return
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
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF8F8),
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 98),
            // 로고 이미지
            Image.asset(
              'assets/Widget/Login/logo.png',
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20), // 로고와 아이디 입력 필드 간격
            loginWidget(),
            SizedBox(height: 20), // 아이디와 비밀번호 입력 필드 간격
            passwordWidget(),// 입력 필드와 버튼 간격
            if (errorText.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 35),
                  child: Text(
                    errorText,
                    style: TextStyle(color: Color(0xFFFF6C6C), fontSize: 14),
                  ),
                ),
              ),
            SizedBox(height: 20),
            loginButton(),
            findPassword(),
          ],
        ),
      ),
    );
  }
}
