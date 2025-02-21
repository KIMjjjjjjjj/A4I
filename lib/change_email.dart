import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'loginpage.dart';
import 'main.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  String? errorMessage1;
  String? errorMessage2;

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
    String password = 'ixzc yyln amzs woku';

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
        errorMessage2 = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증이 완료되었습니다.'))
      );
    } else {
      setState(() {
        errorMessage2 = '인증 코드가 일치하지 않습니다.';
      });
    }
  }

  Future<void> changeEmail() async {
    if (_isCodeVerified) {
      try {
        User? user = _auth.currentUser;
        if (user == null) throw Exception('사용자를 찾을 수 없습니다.');

        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _currentPasswordController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);
        await FirebaseFirestore.instance
            .collection('register')
            .doc(user!.uid)
            .set(
            {'email':_newEmailController.text.trim()}, SetOptions(merge: true)
        );
        await user.updateEmail(_newEmailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일이 성공적으로 변경되었습니다.'))
        );
        await FirebaseAuth.instance.signOut();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }  catch (error) {
        setState(() {
          errorMessage1 = '현재 비밀번호가 올바르지 않습니다.';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증을 먼저 완료해주세요.'))
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '이메일 변경',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
          children: [
          const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          height: 700,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('현재 이메일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    hintText: '현재 이메일',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('새 이메일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newEmailController,
                        decoration: InputDecoration(
                          hintText: '새 이메일',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        sendVerificationCode(_newEmailController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF99A8DA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('인증 요청', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _verificationCodeController,
                        decoration: InputDecoration(
                          hintText: '인증코드',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF99A8DA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('인증 확인', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: changeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF99A8DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('이메일 변경', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
    ),

    );
  }
}
