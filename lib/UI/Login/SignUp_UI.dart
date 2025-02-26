import 'dart:math';

import 'package:flutter/material.dart';
import 'package:repos/UI/Login/Start_UI.dart';
import 'Login_UI.dart';
import 'package:mailer/mailer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 상태 값으로 UI 컨트롤
enum SignUpStep { emailVerification, password, nickname, complete }

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SignUpStep currentStep = SignUpStep.emailVerification;

  String statusText = "안녕하세요!\n이메일을 입력해 주세요.";
  String additionalText = "";
  String captionText = "이메일";
  String hintText = "이메일을 입력해주세요.";
  String buttonText = "다음";
  String errorText = "";
  String firstPassword = "";

  //이메일 비밀번호 저장 변수
  String email = "";
  String password = "";
  String nickname = "";

  //랜덤 변수 저장
  String? _generatedCode;
  bool _isCodeVerified = false;
  bool _isValidId = true;

  bool firstPasswordStep = false;
  bool isTextFiledInputValid = false; // 텍스트 필드 입력 여부
  bool isEmailEntered = false;

  //코드 랜덤 생성
  String generateRandomCode() {
    final random = Random();
    int randomNumber = 10000 + random.nextInt(90000);
    return randomNumber.toString();
  }

  //이메일에 코드 보내기
  Future<void> sendVerificationCode(String toEmail) async {
    String randomCode = generateRandomCode();
    setState(() {
      _generatedCode = randomCode;
      _isCodeVerified = false;
    });

    String username = 'yun7171717@gmail.com';
    String password = 'hpwr frpl dsdx uqda';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'A4I 인증번호')
      ..recipients.add(toEmail)
      ..subject = '이메일 인증 코드'
      ..text = '당신의 인증 코드는: $randomCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('인증 코드가 이메일로 전송되었습니다.')));
    } catch (e) {
      print('메시지 전송 실패: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('이메일 전송에 실패했습니다.')));
    }
  }

  //확인 코드 검사
  bool verifyCode() {
    if (textController.text == _generatedCode) {
      setState(() {
        _isCodeVerified = true;
        errorText = "";
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('인증이 완료되었습니다.')));
      return false;
    } else {
      setState(() {
        textController.clear();
        errorText = '인증 코드가 일치하지 않습니다.';
      });
      return true;
    }
  }

  Future<void> saveToFireStore(String email, String password, String nickname) async {
    try {
      // Firebase Authentication을 통해 사용자 등록
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Firestore에 데이터 저장
      await _firestore.collection('register').doc(userCredential.user?.uid).set({
        'email' : email,
        'nickname': nickname,
        'profileImageUrl' : "",
        'attendanceCount': 0,
        'lastAttendanceDate' : ""
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }



  void onNextPressed() { // 컨트롤러 메소드
    setState(() {
      switch (currentStep) {
        case SignUpStep.emailVerification:
          if (!isEmailEntered) {
            if (!isValidEmail(textController.text)) {
              setState(() {
                errorText = "유효하지 않은 이메일 형식입니다.";
                isTextFiledInputValid = false;
                textController.clear();
              });
            } else {
              setState(() {
                email = textController.text.trim();
                sendVerificationCode(textController.text.trim());
                textController.clear();
                errorText = "";
                statusText = "이메일을 확인해주세요.";
                additionalText = "인증 번호를 보냈어요.";
                captionText = "인증 번호";
                hintText = "인증 번호를 입력해주세요.";
                isTextFiledInputValid = false;
                isEmailEntered = true;
              });
            }
          } else if (isEmailEntered) {
            if(!verifyCode()){
              setState(() {
                // 인증코드 검사 로직 추가
                // 입력한 인증코드가 일치하면 상태값 변경
                statusText = "비밀번호를 입력해주세요.";
                additionalText = "비밀번호는 영문, 숫자, 특수문자 등을 조합하여 길이를\n최소 8자리 이상 입력해주세요";
                captionText = "비밀번호";
                hintText = "비밀번호를 입력해주세요";
                textController.clear();
                isTextFiledInputValid = false;
                currentStep = SignUpStep.password;
              });
            }
          }
          break;
        case SignUpStep.password:
          // 입력한 비밀번호가 조건에 맞는지 검사
          if (!firstPasswordStep) {
            firstPassword = textController.text;
            if (isValidPassword(firstPassword)) {
              statusText = "비밀번호를 한번 더 입력해주세요.";
              additionalText = "비밀번호를 다시 한번 확인할게요.";
              errorText = "";
              firstPasswordStep = true;
              isTextFiledInputValid = false;
              textController.clear();
            }
            else {
              textController.clear();
              errorText = "비밀번호 형식이 맞지 않아요.";
            }
          } else {
            if (firstPassword == textController.text) {
              statusText = "마지막이에요!\n당신을 뭐라고 부를까요?";
              additionalText = "별명을 알려주세요.";
              hintText = "닉네임을 입력해주세요.";
              captionText = "닉네임";
              errorText = "";
              isTextFiledInputValid = false;
              currentStep = SignUpStep.nickname;
              password = textController.text.trim();
              textController.clear();
            }
            else {
              textController.clear();
              errorText = "비밀번호가 일치하지 않아요.";
            }
          }
          break;
        case SignUpStep.nickname:
          statusText = "축하드려요!\n회원가입에 성공했어요.";
          buttonText = "로그인";
          additionalText = "";
          currentStep = SignUpStep.complete;
          nickname = textController.text.trim();
          textController.clear();
          break;
        case SignUpStep.complete:
          // 로그인으로 이동
          saveToFireStore(email, password, nickname);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          break;

      }
    });
  }

  // 비밀번호 조건 로직
  bool isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
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
        title: Text('회원가입'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              Color iconColor = index == currentStep.index
                  ? Colors.black
                  : Color(0xFFC3C3C3);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  Icons.arrow_circle_down,
                  size: 24,
                  color: iconColor,
                ),
              );
            }),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬로 변경
            children: [
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              if (additionalText.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      additionalText,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              SizedBox(height: 10),
              // 이메일 입력 필드
              Visibility(
                visible: currentStep != SignUpStep.complete,
                child: Container(
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
                          controller: textController,
                          style: TextStyle(color: Color(0xFF000000), fontSize: 18),
                          onChanged: (value) {
                            setState(() {
                              isTextFiledInputValid = value.isNotEmpty;
                            });
                          },
                          obscureText: currentStep == SignUpStep.password,  // 비밀번호 입력일 때만 숨기기
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: TextStyle(
                              color: Color(0xFFCECECE),
                              fontSize: 18,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
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
              // Spacer를 사용하여 남은 공간 차지
              Spacer(),
              // 다음 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 30), // 아래쪽에 30 패딩 추가
                child: ElevatedButton(
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

