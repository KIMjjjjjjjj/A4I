import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/diary/view_diary.dart';
import '../../bottom_navigation_bar.dart';

import 'write_diary.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<String, Future<String?>> FaceImage;
  String year = DateTime.now().year.toString();

  String selectedMonth = '02';
  List<String> monthNames = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    selectedMonth = today.month.toString().padLeft(2, '0');

    FaceImage = {};
    UpdateFace();


  }
  void UpdateFace() {
    setState(() {
      FaceImage.clear();
      int daysInMonth = DayCount(2025, int.parse(selectedMonth));
      for (int day = 1; day <= daysInMonth; day++) {
        String dayString = day.toString();
        FaceImage[dayString] = loadFace('2025', selectedMonth, dayString);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<String?> loadFace(String year, String month, String day) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('diary')
          .doc(uid)
          .collection('diary')
          .doc(year)
          .collection(month)
          .doc(day)
          .get();

      if (snapshot.exists && snapshot['face'] != null) {
        return snapshot['face'];
      }
    } catch (e) {
      print('오류');
    }

    return null;
  }

  int DayCount(int year, int month) {
    return DateTimeRange(
      start: DateTime(year, month, 1),
      end: DateTime(year, month + 1, 1),
    ).duration.inDays;
  }

  int FirstDay(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6F0FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6F0FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  CustomNavigationBar()),
                  (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 5),
            Text(
              year,
              style: TextStyle(
                fontFamily: 'PoetsenOne',
                color: Color(0xFF6E96B4),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF6E96B4)),
                  onPressed: () {
                    setState(() {
                      int currentIndex = int.parse(selectedMonth) - 1;
                      if (currentIndex > 0) {
                        selectedMonth = (currentIndex).toString().padLeft(2, '0');
                      }
                    });
                  },
                ),
                Text(
                  monthNames[int.parse(selectedMonth) - 1],
                  style: TextStyle(
                    fontFamily: 'PoetsenOne',
                    color: Color(0xFF6E96B4),
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Color(0xFF6E96B4)),
                  onPressed: () {
                    setState(() {
                      int currentIndex = int.parse(selectedMonth) - 1;
                      if (currentIndex < 11) {
                        selectedMonth = (currentIndex + 2).toString().padLeft(2, '0');
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('일'),
                Text('월'),
                Text('화'),
                Text('수'),
                Text('목'),
                Text('금'),
                Text('토'),
              ],
            ),
            SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6,
                ),
                itemCount: FirstDay(2025, int.parse(selectedMonth)) + DayCount(2025, int.parse(selectedMonth)),
                itemBuilder: (context, index) {
                  int startEmptyDays = FirstDay(2025, int.parse(selectedMonth));
                  if (index < startEmptyDays) {
                      return SizedBox.shrink();
                  } else {
                    int day = index - startEmptyDays + 1;
                    String dayString = day.toString();
                    return FutureBuilder<String?>(
                        future: loadFace('2025', selectedMonth, dayString),
                      builder: (context, snapshot) {
                        bool hasFaceImage = snapshot.hasData && snapshot.data != null;
                    return GestureDetector(
                      onTap: () async {
                        String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                        if (hasFaceImage) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewDiary(
                                userId: uid,
                                year: year,
                                month: selectedMonth,
                                day: dayString,
                              ),
                            ),
                          );
                          UpdateFace();
                        } else {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiaryEntryPage(
                                year: year,
                                month: selectedMonth,
                                day: dayString,
                              ),
                            ),
                          );
                          if (result == true) {
                            UpdateFace();
                          }
                        }
                      },
                      child: Column(
                        children: [
                          FutureBuilder<String?>(
                            future: loadFace(year, selectedMonth, dayString),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                 return CircleAvatar(
                                    radius: 18,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage(snapshot.data!),
                                  );
                              } else {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Color(0xFFD9D9D9),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 4),
                          Container(
                            child: Text(
                              '$day',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                    }
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime today = DateTime.now();
          String year = today.year.toString();
          String month = today.month.toString().padLeft(2, '0');
          String dayString = today.day.toString();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => DiaryEntryPage(year: year, month: month, day: day,)),
          // );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryEntryPage(
                year: year,
                month: selectedMonth,
                day: dayString,
              ),
            ),
          );

          if (result == true) {
            UpdateFace(); // 저장이 완료되었을 경우 다시 face 이미지 불러오기
          }
        },
        backgroundColor: Color(0xFFA8DFF3),
        child: Icon(Icons.edit, color: Colors.brown[300]),
      ),
    );
  }
}

