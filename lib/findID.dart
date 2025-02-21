// findID.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'dart:math';
import 'package:mailer/smtp_server/gmail.dart';


class FindIDPage extends StatefulWidget {
  @override
  FindIDPageState createState() => FindIDPageState();
}

class FindIDPageState extends State<FindIDPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  String? emailErrorMessage;
  String? errorMessage;

  String? _generatedCode;
  bool _isCodeVerified = false;

  String generateRandomCode() {
    final random = Random();
    int randomNumber = 10000 + random.nextInt(90000);
    return randomNumber.toString();
  }

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
      ..from = Address(username, '가계부')
      ..recipients.add(toEmail)
      ..subject = '이메일 인증 코드'
      ..text = '당신의 인증 코드는: $randomCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 코드가 이메일로 전송되었습니다.'))
      );
    } catch (e) {
      print('메시지 전송 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 전송에 실패했습니다.'))
      );
    }
  }

  void verifyCode() {
    if (_verificationCodeController.text == _generatedCode) {
      setState(() {
        _isCodeVerified = true;
        errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증이 완료되었습니다.'))
      );
    } else {
      setState(() {
        errorMessage = '인증 코드가 일치하지 않습니다.';
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String? checkEmailErrorText() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return '이메일형식이 올바르지 않습니다.';
    }
    return null;
  }

  InputBorder customBorder(double width, Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        width: width,
        color: color,
      ),
    );
  }

  Future<void> findUserID() async {
    final emailErrorText = checkEmailErrorText();

    setState(() {
      emailErrorMessage = emailErrorText; // 이메일 오류 메시지 설정
    });

    if (emailErrorText != null) {
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        emailErrorMessage = '유저 정보가 없습니다.';
      });
      return;
    }

    if(_isCodeVerified){
      try {
        // Firestore에서 사용자 ID 검색
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('register') // 사용자 정보를 저장한 컬렉션 이름
            .where('email', isEqualTo: emailController.text.trim())
            .get();

        if (snapshot.docs.isNotEmpty) {
          var userDoc = snapshot.docs.first.data() as Map<String, dynamic>; // 첫 번째 문서의 ID 가져오기
          String userID = userDoc['id'];

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('사용자 ID'),
                content: Text('사용자 ID: $userID'),
                actions: [
                  TextButton(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            emailErrorMessage = '해당 이메일에 대한 ID를 찾을 수 없습니다.';
          });
        }
      } catch (e) {
        setState(() {
          emailErrorMessage = '아이디 찾기에 실패했습니다.';
        });
      }
    }
    else{
      setState(() {
        errorMessage = '인증되지 않았습니다.';
      });
    }
  }

  Widget emailWidget(){
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "이메일",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: emailErrorMessage,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      autovalidateMode: AutovalidateMode.always,
      onFieldSubmitted: (value) {
        debugPrint('onFieldSubmitted $value ');
      },
      onChanged: (value) {
        setState(() {
          emailErrorMessage = checkEmailErrorText(); // 변경 시 이메일 오류 메시지 업데이트
        });
      },
    );
  }

  Widget codeWidget(){
    return TextFormField(
      controller: _verificationCodeController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "인증코드",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: errorMessage,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      autovalidateMode: AutovalidateMode.always,
      onFieldSubmitted: (value) {
        debugPrint('onFieldSubmitted $value ');
      },
    );
  }

  Widget emailLine(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: emailWidget()),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            sendVerificationCode(emailController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black38,
          ),
          child: Text("인증 요청", style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget codeLine(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: codeWidget()),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
          ),
          child: Text("인증 확인", style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget findIDWidget(){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // 패딩 조정
        minimumSize: Size(double.infinity, 50), // 최소 크기 설정
      ),
      child: Text("아이디 찾기"),
      onPressed: findUserID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text('아이디 찾기'),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              emailLine(),
              SizedBox(height: 20),
              codeLine(),
              SizedBox(height: 20),
              findIDWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
