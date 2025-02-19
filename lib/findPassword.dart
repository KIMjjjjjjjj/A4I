// findID.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FindPasswordPage extends StatefulWidget {
  @override
  FindPasswordPageState createState() => FindPasswordPageState();
}



class FindPasswordPageState extends State<FindPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  String? emailErrorMessage;
  String? idErrorMessage;
  final int IDLength = 6;

  @override
  void dispose() {
    emailController.dispose();
    idController.dispose();
    super.dispose();
  }

  String? checkEmailErrorText() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return '이메일형식이 올바르지 않습니다.';
    }
    return null; // 유효한 경우 null 반환
  }

  String? checkIDErrorText() {
    final id = idController.text.trim();
    if (id.isEmpty) {
      return '아이디를 입력해주세요.';
    }
    return id.length >= IDLength ? null : "6글자 이상 입력해주세요" ; // 유효한 경우 null 반환
  }

  InputBorder customBorder(double width, Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        width: width,
        color: color,
      ),
    );
  }

  void sendEmail() async {
    final emailErrorText = checkEmailErrorText();
    final idErrorText = checkIDErrorText();
    setState(() {
      emailErrorMessage = emailErrorText;// 이메일 오류 메시지 설정
      idErrorMessage = idErrorText;
    });

    if (emailErrorMessage != null || idErrorMessage != null) {
      return;
    }

    try {
      // Firestore에서 사용자 ID 검색
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('register') // 사용자 정보를 저장한 컬렉션 이름
          .where('email', isEqualTo: emailController.text.trim())
          .get();
      if (snapshot.docs.isNotEmpty) {
        var userDoc = snapshot.docs.first.data() as Map<String, dynamic>; // 첫 번째 문서의 ID 가져오기
        String userID = userDoc['id'];
        if(userID != idController.text.trim()){
          setState(() {
            idErrorMessage = '아이디가 일치하지 않습니다.';
          });
          return;
        }
      } else {
        setState(() {
          idErrorMessage = '해당 이메일에 대한 ID를 찾을 수 없습니다.';
        });
        return;
      }
    } catch (e) {
      setState(() {
         idErrorMessage = '아이디 찾기에 실패했습니다.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      // 이메일 전송 성공 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 초기화 이메일이 전송되었습니다.')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        emailErrorMessage = '이메일 전송에 실패했습니다.';
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
        debugPrint('change $value');
      },
      validator: (value) {
        debugPrint('validator $value');
      },
    );
  }

  Widget IDWidget(){
    return TextFormField(
      controller: idController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "아이디",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: idErrorMessage,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      autovalidateMode: AutovalidateMode.always,
      onFieldSubmitted: (value) {
        debugPrint('onFieldSubmitted $value ');
      },
      onChanged: (value) {
        setState(() {
          idErrorMessage = checkIDErrorText();
        });
        debugPrint('change $value');
      },
      validator: (value) {
        debugPrint('validator $value');
      },
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
      child: Text("비밀번호 재설정"),
      onPressed: sendEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Text('비밀번호 재설정'),
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
              emailWidget(),
              SizedBox(height: 20.0),
              IDWidget(),
              SizedBox(height: 20.0),
              findIDWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
