import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AlarmSettingPage(),
    );
  }
}

class AlarmSettingPage extends StatefulWidget {
  const AlarmSettingPage({super.key});

  @override
  _AlarmSettingPageState createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  bool isThanksNotificationOn = true;
  bool isDiaryNotificationOn = true;

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
        title: const Text('알림 설정',style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('감사 알림', style: TextStyle(fontSize: 16)),
                    trailing: Switch(
                      value: isThanksNotificationOn,
                      onChanged: (value) {
                        setState(() {
                          isThanksNotificationOn = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  ListTile(
                    title: const Text('일기 알림', style: TextStyle(fontSize: 16)),
                    trailing: Switch(
                      value: isDiaryNotificationOn,
                      onChanged: (value) {
                        setState(() {
                          isDiaryNotificationOn = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
