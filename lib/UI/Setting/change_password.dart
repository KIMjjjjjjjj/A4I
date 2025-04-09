import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Login/Login_UI.dart';

  class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? errorMessage1;
  String? errorMessage2;

  Future<void> _changePassword() async {
    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        errorMessage2 = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    setState(() {
      errorMessage2 = null;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('사용자를 찾을 수 없습니다.');

      String email = user.email!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(_newPasswordController.text.trim());

      setState(() {
        errorMessage1 = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '현재 비밀번호가 틀렸습니다.';
          setState(() {
            errorMessage1 = errorMessage;
          });
          break;
        case 'weak-password':
          errorMessage = '비밀번호는 6자 이상이어야 합니다.';
          setState(() {
            errorMessage1 = errorMessage;
          });
          break;
        default:
          errorMessage = '비밀번호 변경에 실패했습니다: ${e.message}';
          setState(() {
            errorMessage1 = errorMessage;
          });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
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
          '비밀번호 변경',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
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
                    const Text('현재 비밀번호', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        hintText: '현재 비밀번호',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('새 비밀번호', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        hintText: '새 비밀번호',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: '새 비밀번호 확인',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF99A8DA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('비밀번호 변경', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text('                   비밀번호를 잊으셨나요?', style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
