import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDiary extends StatefulWidget {
  final String userId;
  final String year;
  final String month;
  final String day;

  const ViewDiary({
    Key? key,
    required this.userId,
    required this.year,
    required this.month,
    required this.day,
  }) : super(key: key);

  @override
  _ViewDiaryState createState() => _ViewDiaryState();
}

class _ViewDiaryState extends State<ViewDiary> {
  String facePath = 'assets/default.png';
  String date = '';
  String title = '';
  String content = '';
  String imgPath = '';

  @override
  void initState() {
    super.initState();
    _fetchDiaryData();
  }

  Future<void> _fetchDiaryData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('diary')
          .doc(widget.userId)
          .collection('diary')
          .doc(widget.year)
          .collection(widget.month)
          .doc(widget.day)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          facePath = data['face'] ?? '';
          imgPath = data['imagePath'] ?? '';
          title = data['title'] ?? '';
          content = data['content'] ?? '';
        });
      }
    } catch (e) {
      print('오류');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F3FF),
      appBar: AppBar(
        title: Text(
          widget.year,
          style: TextStyle(
            fontFamily: 'SingleDay',
            color: Color(0xFF3F5C7E),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFE6F0FA),
      ),
    body: SingleChildScrollView(
    child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              height: 750,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        facePath,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported);
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${widget.month}월 ${widget.day}일',
                        style: TextStyle(
                          fontFamily: 'SingleDay',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (imgPath.isNotEmpty)
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: imgPath.startsWith('http')
                          ? Image.network(
                        imgPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                        },
                      )
                          : Image.asset(
                        imgPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                        },
                      ),
                    ),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 200, // 필요에 따라 높이 조절
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
