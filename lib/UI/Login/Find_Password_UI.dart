import 'package:flutter/material.dart';
import 'Login_UI.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String statusText = "이메일을 입력해 주세요.";
  String additionalText = "";
  String captionText = "이메일";
  String hintText = "이메일을 입력해주세요.";
  String buttonText = "다음";
  String errorText = "";
  bool isTextFiledInputValid = false; // 텍스트 필드 입력 여부
  bool isEmailEntered = false;
  bool isCodeEntered = false;

  void onNextPressed() {
    if (!isEmailEntered) {
      if (!isValidEmail(emailController.text)) {
        setState(() {
          errorText = "유효하지 않은 이메일 형식입니다.";
          isTextFiledInputValid = false;
          emailController.clear();
        });
      }
      else {
        setState(() {
          errorText = "";
          statusText = "이메일을 확인해주세요.";
          additionalText = "인증 번호를 보냈어요.";
          captionText = "인증 번호";
          hintText = "인증 번호를 입력해주세요.";
          isTextFiledInputValid = false;
          emailController.clear();
          isEmailEntered = true;
        });
      }
    } else if (isEmailEntered && !isCodeEntered) {
      setState(() {
        statusText = "비밀번호를 확인하세요.";
        captionText = "비밀 번호";
        hintText = "비밀번호입니다.";
        additionalText = "";
        buttonText = "로그인";
        emailController.clear();
        isCodeEntered = true;
      });
    } else if (isEmailEntered && isCodeEntered) {
      // 로그인 버튼 눌렀을 때 로그인 UI로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginFormScreen()),
      );
    }
  }
  // 이메일 형식 확인 로직
  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 찾기'),
        centerTitle: true, // 제목을 가운데 정렬
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft, // 왼쪽 정렬
                child: Padding(
                  padding: EdgeInsets.only(left: 10), // 오른쪽으로 10만큼 이동
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              if (additionalText.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft, // 왼쪽 정렬
                  child: Padding(
                    padding: EdgeInsets.only(left: 15), // 오른쪽으로 15만큼 이동
                    child: Text(
                      additionalText,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              SizedBox(height: 10),
              // 이메일 입력 필드
              Container(
                width: 335,
                height: 89,
                decoration: BoxDecoration(
                  color: Color(0xFFF0EFFA),
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        captionText,
                        style: TextStyle(color: Color(0xFF2719ED), fontSize: 12),
                      ),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Color(0xFF000000), fontSize: 18),
                        enabled: !isCodeEntered, // 비밀번호 입력 시 비활성화
                        onChanged: (value) {
                          setState(() {
                            isTextFiledInputValid = value.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: isCodeEntered ? Color(0xFF000000) : Color(0xFFCECECE), // 비밀번호 단계에서 검은색 힌트
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // 에러 출력
              if (errorText.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      errorText,
                      style: TextStyle(color: Color(0xFFFF6C6C), fontSize: 14),
                    ),
                  ),
                ),
              // 다음 버튼
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child : ElevatedButton(
                  onPressed: isTextFiledInputValid ? onNextPressed : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(320, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    backgroundColor: isTextFiledInputValid
                        ? Color(0xFF6BE5A0)
                        : Color(0xFFB3EFCC),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

