import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget{
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final int passwordLength = 6;
  final int IDLength = 6;

  String? idErrorMessage;
  String? passwordErrorMessage;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? checkIDErrorText() {
    if (idController.text.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    return null; // 유효한 경우 null 반환
  }

  String? checkPWErrorText() {
    if (passwordController.text.isEmpty) return '비밀번호를 입력해주세요.';
    return passwordController.text.length >= passwordLength ? null : "6글자 이상 입력해주세요.";
  }

  InputBorder customBorder(double width, Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        width: width,
        color: color,
      ),
    );
  }

  void signIn() async {
    final idErrorText = checkIDErrorText();
    final passwordErrorText = checkPWErrorText();
    String userEmail;
    String userID;
    setState(() {
      idErrorMessage = idErrorText; // 이메일 오류 메시지 설정
      passwordErrorMessage = passwordErrorText; // 비밀번호 오류 메시지 설정
    });

    if (idErrorText != null || passwordErrorText != null) {
      return;
    }

    try {
      // Firestore에서 사용자 ID 검색
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('register') // 사용자 정보를 저장한 컬렉션 이름
          .where('id', isEqualTo: idController.text.trim())
          .get();
      if (snapshot.docs.isNotEmpty) {
        var userDoc = snapshot.docs.first.data() as Map<String, dynamic>; // 첫 번째 문서의 ID 가져오기
        userID = userDoc['id'];
        userEmail = userDoc['email'];
        if(userID != idController.text.trim()){
          setState(() {
            idErrorMessage = '아이디가 일치하지 않습니다.';
          });
          return;
        }
      } else {
        setState(() {
          idErrorMessage = '해당 ID를 찾을 수 없습니다.';
        });
        return;
      }
    } catch (e) {
      setState(() {
        idErrorMessage = '아이디 찾기에 실패했습니다.';
      });
      return;
    }


    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: userEmail.trim(),
        password: passwordController.value.text.trim(),
      );
      idController.clear();
      passwordController.clear();
      Navigator.pushNamed(context, '/RoomSelect');
    } catch(e){
      setState(() {
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            idErrorMessage = '이메일이 일치하지 않습니다.';
            passwordErrorMessage = null; // 비밀번호 오류 메시지 초기화
          } else if (e.code == 'wrong-password') {
            passwordErrorMessage = '비밀번호가 일치하지 않습니다.';
            idErrorMessage = null; // 이메일 오류 메시지 초기화
          }
        }
      });
    }
  }

  Widget userIdWidget(){
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
          idErrorMessage = checkIDErrorText(); // 변경 시 이메일 오류 메시지 업데이트
        });
        debugPrint('change $value');
      },
      validator: (value) {
        debugPrint('validator $value');
      },
    );
  }

  Widget passwordWidget(){
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "비밀번호",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: passwordErrorMessage,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      autovalidateMode: AutovalidateMode.always,
      onFieldSubmitted: (value) {
        debugPrint('onFieldSubmitted $value ');
      },
      onChanged: (value) {
        setState(() {
          passwordErrorMessage = checkPWErrorText(); // 변경 시 비밀번호 오류 메시지 업데이트
        });
        debugPrint('change $value');
      },
      validator: (value) {
        debugPrint('validator $value');
      },
    );
  }

  Widget loginButtonWidget(){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 160.0),
      ),
      child: Text("로그인"),
      onPressed: signIn,
    );
  }

  Widget smallButtonWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            child: Text(
              "회원가입",
              style: TextStyle(fontSize: 12),
            ),
            onTap: ()=> Navigator.pushNamed(context, '/signUp')
        ),
        SizedBox(width: 200),
        GestureDetector(
            child: Text(
              "아이디",
              style: TextStyle(fontSize: 12),
            ),
            onTap: ()=> Navigator.pushNamed(context, '/findID')
        ),
        Text(
          " / ",
          style: TextStyle(fontSize: 12),
        ),
        GestureDetector(
            child: Text(
              "비밀번호 찾기",
              style: TextStyle(fontSize: 12),
            ),
            onTap: ()=> Navigator.pushNamed(context, '/findPassword')
        ),
      ],
    );
  }

  Widget titleText() {
    return Text(
      "가계부기",
      style: TextStyle(fontSize: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                children: [
                  SizedBox(height: 100),
                  titleText(),
                  SizedBox(height: 20.0),
                  Image.asset('assets/sangsang.png'),
                  userIdWidget(),
                  SizedBox(height: 20.0),
                  passwordWidget(),
                  SizedBox(height: 20.0),
                  loginButtonWidget(),
                  SizedBox(height: 10.0),
                  smallButtonWidget(),
                ]
            ),
          )
      ),
    );
  }
}
