import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'survey_explain.dart';
import 'bottom_navigation_bar.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (context) => SurveyExplainPage(),
        '/navigation': (context) {
          final elements = ModalRoute.of(context)?.settings.arguments as String? ?? 'element';
          return CustomNavigationBar(elements: elements);
        },
      },
    );
  }
}

