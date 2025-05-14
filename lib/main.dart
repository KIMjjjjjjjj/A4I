import 'package:flutter/material.dart';
import 'UI/Setting/setting_page.dart';
import 'UI/Login/Start_UI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'bottom_navigation_bar.dart';
import 'UI/survey/Firstsurvey_explain.dart';
import 'UI/MainDisplay/mainDisplay.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'SplashScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        '/navigation': (context) => CustomNavigationBar(),
        '/survey' : (context) => SurveyExplainPage(),
        '/setting' : (context) => SettingPage(),
        '/main' : (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // api 파일 로드
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NaverMapSdk.instance.initialize(
    clientId: dotenv.env['NAVER_MAPS_API_KEY_ID'] ?? '',
  );
  runApp(MyApp());
}