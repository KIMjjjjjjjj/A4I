import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  final String title;

  const BoardScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double panelWidth = screenWidth * 0.95;
    final double panelHeight = panelWidth * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Center(
                      child: postPanel(
                        "게시글 제목 $index",
                        "내용",
                        "${index + 1}일 전",
                        panelHeight,
                        panelWidth,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                print("글 작성 버튼 클릭됨");
              },
              child: Image.asset(
                "assets/Widget/Community/write.png",
                width: 60,
                height: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget postPanel(String title, String context, String date, double height, double width) {
    return Column(
      children: [
        Divider(height: 0, thickness: 1, color: Color(0xFFCBCBCB)), // 위쪽 선
        Container(
          height: height,
          width: width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFFFFCFC),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFCBCBCB),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("0", style: TextStyle(fontSize: 14, color: Colors.black)),
                      SizedBox(width: 10),
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("0", style: TextStyle(fontSize: 14, color: Colors.black)),
                      SizedBox(width: 10),
                      Icon(Icons.comment, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("0", style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        Divider(height: 0, thickness: 1, color: Color(0xFFCBCBCB)), // 아래쪽 선
      ],
    );
  }
}