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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // 앱이 시작되면 LoginScreen이 표시됨
      routes: {
        '/' : (context) => LoginScreen(),
        '/navigation': (context) => CustomNavigationBar(),
        '/survey' : (context) => SurveyExplainPage(),
        '/setting' : (context) => SettingPage(),
        '/main' : (context) => MainScreen(),
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