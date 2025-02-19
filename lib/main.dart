import 'package:flutter/material.dart';
import 'UI/Login/Start_UI.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // 앱이 시작되면 LoginScreen이 표시됨
    );
  }
}