import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/test_page_asi.dart';
import 'package:repos/UI/PsychologicalTest/test_page_pss.dart';


class ExplainTestPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalCount;
  final String description;

  const ExplainTestPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.totalCount,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$subtitle $title',
                style: TextStyle(fontSize:25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$totalCount문항',
                style: TextStyle(fontSize: 17, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 330,
                child: Text(
                  description.replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Widget nextPage = TestPageAsi();

                  if (title == "ASI") {
                    nextPage = TestPageAsi();
                  } else if (title == "PSS") {
                    nextPage = TestPagePss();
                  } else if (title == "BDI") {
                    nextPage = TestPageAsi();
                  } else if (title == "SSI") {
                    nextPage = TestPageAsi();
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => nextPage),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6BE5A0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  '시작',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
