import 'package:flutter/material.dart';

class DayLineScreen extends StatelessWidget {
  final String visitorCount = "25"; // 방문자 수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAEBF0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(27), // 앱바 높이를 40으로 설정
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 8),
            child: BackButton(color: Colors.black),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 313,
            height: 670,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(27),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "오늘의 방문자 수",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    visitorCount,
                    style: TextStyle(
                      fontSize: 40,
                      height: 21 / 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // speech_bubble 안에 텍스트 넣기
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/DayLine/speech_bubble.png',
                    ),
                    Positioned(
                      child: Text(
                        "오늘의 감사한 일을 적어주세요",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 0),
                Image.asset(
                  'assets/images/DayLine/letter_HARU.png',
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6BE5A0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    fixedSize: Size(148, 57),
                  ),
                  onPressed: () {},
                  child: Text(
                    "입장하기",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
