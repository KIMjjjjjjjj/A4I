import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'board_post_ui.dart';
import 'board_ui.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<Map<String, int>> getPostCounts(String postId) async {
    Map<String, int> counts = {
      'likeCount': 0,
      'commentCount': 0,
      'viewCount': 0,
    };

    try {
      // 좋아요 수 가져오기
      QuerySnapshot likeSnapshot = await FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts")
          .doc(postId)
          .collection("like")
          .get();

      counts['likeCount'] = likeSnapshot.docs.length;

      // 댓글 수 가져오기
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .get();

      counts['commentCount'] = commentSnapshot.docs.length;

      // 조회수 가져오기
      QuerySnapshot viewSnapshot = await FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts")
          .doc(postId)
          .collection("view")
          .get();

      counts['viewCount'] = viewSnapshot.docs.length;
    } catch (e) {
      print("Error getting post counts: $e");
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double panelWidth = screenWidth * 0.8;
    final double panelHeight = panelWidth * 0.7;
    final double buttonPanelWidth = screenWidth * 0.9;
    final double buttonPanelHeight = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "TODAK",
          style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "오늘의 추천글",
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: panelWidth,
                height: panelHeight,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("community")
                      .doc("AjeagqxuQCcafNgotPhV")
                      .collection("posts")
                      .orderBy("likeCount", descending: true)
                      .limit(3)
                      .get(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("오류 발생: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("추천글이 없습니다."));
                    }

                    snapshot.data!.docs.forEach((doc) {
                      print("Title: ${doc["title"]}, LikeCount: ${doc["likeCount"]}");
                    });



                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: Future.wait(
                        snapshot.data!.docs.map((doc) async {
                          Map<String, int> counts = await getPostCounts(doc.id);
                          return {
                            'doc': doc,
                            'counts': counts,
                          };
                        }).toList(),
                      ),
                      builder: (context, postsWithCountsSnapshot) {
                        if (postsWithCountsSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!postsWithCountsSnapshot.hasData) {
                          return Center(child: Text("데이터를 가져오는 중 오류가 발생했습니다."));
                        }

                        List<Widget> postWidgets = postsWithCountsSnapshot.data!.map((item) {
                          var doc = item['doc'];
                          var counts = item['counts'];

                          return GestureDetector(
                            onTap: () {
                              // 게시글 상세 페이지로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(postId: doc.id), // 게시글 ID 전달
                                ),
                              );
                            },
                            child: postPanel(
                              doc["title"],
                              doc["boardName"],
                              panelHeight * 0.8 / 3,
                              panelWidth * 0.9,
                              counts['viewCount']!,
                              counts['likeCount']!,
                              counts['commentCount']!,
                            ),
                          );
                        }).toList();

                        // 게시글 수에 따라 Divider 추가
                        List<Widget> finalWidgets = [];
                        for (int i = 0; i < postWidgets.length; i++) {
                          finalWidgets.add(postWidgets[i]);
                          if (i < postWidgets.length - 1) {
                            finalWidgets.add(Divider(color: Colors.black, thickness: 1, indent: 10, endIndent: 10));
                          }
                        }

                        return Column(children: finalWidgets);
                      },
                    );
                  }
                )
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: buttonPanelWidth,
                height: buttonPanelHeight,
                decoration: BoxDecoration(
                  color: Color(0xFFFAF8F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    categoryButton(context, "자유 게시판", "assets/Widget/Community/smile.png"),
                    categoryButton(context, "일기 게시판", "assets/Widget/Community/diary.png"),
                    categoryButton(context, "고민 게시판", "assets/Widget/Community/help.png"),
                    categoryButton(context, "후기 게시판", "assets/Widget/Community/review.png"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget postPanel(String title, String category, double height, double width, int viewCount, int likeCount, int commentCount) {
    print(viewCount);
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6BE5A0),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(viewCount.toString(), style: TextStyle(fontSize: 14, color: Colors.black)),
                  SizedBox(width: 10),
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(likeCount.toString(), style: TextStyle(fontSize: 14, color: Colors.black)),
                  SizedBox(width: 10),
                  Icon(Icons.comment, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(commentCount.toString(), style: TextStyle(fontSize: 14, color: Colors.black)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }


  Widget categoryButton(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BoardScreen(title: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 60, height: 60),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
