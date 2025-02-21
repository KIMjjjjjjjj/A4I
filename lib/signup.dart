import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'loginPage.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SignUpPage extends StatefulWidget {
  @override
  signUpPageState createState() => signUpPageState();
}

class signUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
  TextEditingController();
  final _nicknameController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? emailErrorMessage;
  String? errorMessage;
  String? nickNameErrorMessage; // 오류 메시지를 저장할 변수

  String? _generatedCode;
  bool _isCodeVerified = false;
  bool _isValidId = true;

  String? _passwordError; // 비밀번호 유효성 검사 결과
  String? _confirmPasswordError; // 비밀번호 일치 검사 결과

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('인증 코드가 이메일로 전송되었습니다.')));
    } catch (e) {
      print('메시지 전송 실패: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('이메일 전송에 실패했습니다.')));
    }
  }

  void verifyCode() {
    if (_verificationCodeController.text == _generatedCode) {
      setState(() {
        _isCodeVerified = true;
        errorMessage = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('인증이 완료되었습니다.')));
    } else {
      setState(() {
        errorMessage = '인증 코드가 일치하지 않습니다.';
      });
    }
  }

  //  닉네임 유효성 검사
  bool validateNickName(String nickName) {
    // 10자 이상일 경우 false
    if (nickName.length > 10) {
      nickNameErrorMessage = "닉네임은 최대 10자까지 입력 가능합니다.";
      return false;
    }

    // 한글 및 영어 이외의 문자 포함 여부 확인
    final validCharPattern = RegExp(r'^[가-힣a-zA-Z]+$');
    if (!validCharPattern.hasMatch(nickName)) {
      nickNameErrorMessage = "닉네임은 한글과 영어만 사용할 수 있습니다.";
      return false;
    }

    // 유효하면 오류 메시지 초기화
    nickNameErrorMessage = null;
    return true;
  }

  //  id 유효성 검사 & 중복 검사.
  Future<bool> _validateId(String id) async {
    // 조건: 영문자와 숫자를 포함하여 최소 6글자 이상
    if (id.length < 6 || !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$').hasMatch(id)) {
      return false;
    }

    // Firestore에서 중복 검사
    final querySnapshot = await _firestore
        .collection('users') // 사용하려는 Firestore 컬렉션 이름
        .where('id', isEqualTo: id)
        .get();

    // Firestore에서 동일한 ID가 이미 존재하면 중복
    if (querySnapshot.docs.isNotEmpty) {
      return false;
    }

    return true; // 유효한 ID
  }

  /// ID 검사 후 결과 표시 함수
  Future<void> _checkAndShowIdValidation() async {
    final id = _idController.text;

    final isValid = await _validateId(id);
    setState(() {
      _isValidId = isValid;
    });

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용 가능한 아이디입니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('중복되었거나 조건을 만족하지 않습니다')),
      );
    }
  }

  /// 비밀번호 유효성 검사 함수
  Future<bool> _validatePassword(String password) async {
    // 최소 8자, 영문자, 숫자, 특수문자 포함
    if (password.length < 8 ||
        !RegExp(
          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,}$',
          caseSensitive: true,
          multiLine: false,)
            .hasMatch (password)
    ) {
      return false; // 조건 불만족
    }
    return
      true; // 조건 만족
  }

  /// 입력값 확인 및 에러 메시지 업데이트 함수
  Future<void> _checkValidation() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 비밀번호 유효성 검사
    final isPasswordValid = await _validatePassword(password);

    setState(() {
      // 조건 불만족 시 에러 메시지 표시
      _passwordError = isPasswordValid ? null : '영어,숫자,특수문자를 포함하여 8글자 이상 입력해주세요';

      // 비밀번호 확인 일치 검사
      _confirmPasswordError = password == confirmPassword
          ? null
          : '비밀번호가 일치하지 않습니다';
    });
  }

  String? checkEmailErrorText() {
    final email = _emailController.text.trim();
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

  // 닉네임 id password 저장
  Future<void> saveToFireStore() async {
    final nickname = _nicknameController.text;
    final id = _idController.text;
    final password = _passwordController.text;
    final email= _emailController.text;
    final profileImageUrl = null;

    if (email.isEmpty || nickname.isEmpty || id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    try {
      // Firebase Authentication을 통해 사용자 등록
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Firestore에 데이터 저장
      await _firestore.collection('register').doc(userCredential.user?.uid).set({
        'email' : email,
        'nickname': nickname,
        'id': id,
        'profileImageUrl':profileImageUrl
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장되었습니다!')),
      );

      // 폼 초기화
      _nicknameController.clear();
      _idController.clear();
      _passwordController.clear();
      _emailController.clear();
      _confirmPasswordController.clear();
      _verificationCodeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
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

    if (_isCodeVerified) {
      try {
        // Firestore에서 사용자 ID 검색
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users') // 사용자 정보를 저장한 컬렉션 이름
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (snapshot.docs.isNotEmpty) {
          var userDoc = snapshot.docs.first.data()
          as Map<String, dynamic>; // 첫 번째 문서의 ID 가져오기
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
    } else {
      setState(() {
        errorMessage = '인증되지 않았습니다.';
      });
    }
  }

  Widget emailWidget() {
    return TextFormField(
      controller: _emailController,
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

  Widget codeWidget() {
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

  Widget emailLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: emailWidget()),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            sendVerificationCode(_emailController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black38,
          ),
          child: Text("인증 요청",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget codeLine() {
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
          child: Text("인증 확인",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget findIDWidget() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        // 패딩 조정
        minimumSize: Size(double.infinity, 50), // 최소 크기 설정
      ),
      child: Text("아이디 찾기"),
      onPressed: findUserID,
    );
  }

  Widget codeNickWidget() {
    return TextFormField(
      controller: _nicknameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: "닉네임",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: nickNameErrorMessage,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      autovalidateMode: AutovalidateMode.always,
      onFieldSubmitted: (value) {
        debugPrint('onFieldSubmitted $value ');
      },
      // 닉네임 변경 시 유효성 검사 실행
      onChanged: (value) {
        setState(() {
          validateNickName(value);
        });
      },
    );
  }

  Widget nickNameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: codeNickWidget()),
      ],
    );
  }

  Widget idLine() {
    return TextFormField(
      controller: _idController,
      decoration: InputDecoration(
        labelText: "아이디",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: _isValidId ? null : '영어와 숫자를 포함하여 최소 6글자이상 입력해주세요',
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
    );
  }

  Widget idWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: idLine()),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: _checkAndShowIdValidation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
          ),
          child: Text("중복 확인",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  //비밀번호 란
  Widget passwordLine() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: "비밀번호",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: _passwordError,
        //////
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      obscureText: true,
      onChanged: (value) {
        _checkValidation(); // 입력 시마다 유효성 검사
      },

    );
  }

  Widget passwordWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: passwordLine()),
      ],
    );
  }

//비밀번호 란
  Widget passwordCheckLine() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: "비밀번호 확인",
        enabledBorder: customBorder(2, Colors.blue),
        errorBorder: customBorder(2, Colors.red),
        focusedErrorBorder: customBorder(4, Colors.red),
        errorText: _confirmPasswordError,
        //////
        errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
        errorMaxLines: 1,
      ),
      obscureText: true,
      onChanged: (value) {
        _checkValidation(); // 입력 시마다 유효성 검사
      },
    );
  }

  Widget passwordCheckWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: passwordCheckLine()),
      ],
    );
  }

  Widget signUpButtonWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
              ),
              onPressed: saveToFireStore,
              child: Text("회원 가입",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text('회원가입'),
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
              SizedBox(height: 10),
              nickNameWidget(),
              SizedBox(height: 20),
              idWidget(),
              SizedBox(height: 20),
              passwordWidget(),
              SizedBox(height: 20),
              passwordCheckWidget(),
              SizedBox(height: 20),
              signUpButtonWidget()
            ],
          ),
        ),
      ),
    );
  }
}