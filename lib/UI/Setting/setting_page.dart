import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/Setting/settings.dart';
import 'alarm_setting.dart';
import 'edit_profile.dart';
import '../Login/Login_UI.dart';
import '../chatbot/chatbot_home.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}):super(key:key);


  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? profileImage;
  String? profileImageUrl;
  final TextEditingController currentNicknameController = TextEditingController();
  final String nickname = '닉네임';
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();

    Timer.periodic(Duration(seconds: 1), (timer) async {
      await loadUserData();
    });
  }
  Future<void> loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc['profileImageUrl'];
          currentNicknameController.text = userDoc['nickname'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6BE5A0),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // Background color
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 65,
                  backgroundImage: NetworkImage(profileImageUrl!),
                )
                    : Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[400],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentNicknameController.text,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(user?.email ?? ''),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );

                        if (result != null && result['updateprofile'] == true) {
                          setState(() {
                            profileImageUrl = result['profileImageUrl'];
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green, // Background color
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        child: Text(
                          '프로필 편집',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('계정 관리'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        tileColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingacountPage()),
                          );
                        },
                      ),
                      SizedBox(height: 5),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text('알림 설정'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        tileColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AlarmSettingPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text('로그아웃'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  tileColor: Colors.white,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity(vertical: -3),
                  title: Text(
                    '버전 정보',
                    style: TextStyle(color: Colors.black, fontSize: 10, height: 1),
                  ),
                  trailing: Text(
                    '현재 버전 1.0 (최신 버전)',
                    style: TextStyle(color: Colors.grey, fontSize: 10, height: 1),
                  ),
                  tileColor: Colors.white,
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatbotScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Main/main_chatbot_banner.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
