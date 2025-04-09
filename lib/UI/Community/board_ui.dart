import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'board_write_ui.dart';
import 'board_post_ui.dart';

class BoardScreen extends StatefulWidget {
  final String title;

  const BoardScreen({super.key, required this.title});

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  int selectedIndex = 0; // 선택된 탭 인덱스

  @override
  void initState() {
    super.initState();
    if (widget.title == "자유 게시판") {
      selectedIndex = 0;
    } else if (widget.title == "일기 게시판") {
      selectedIndex = 1;
    } else if (widget.title == "고민 게시판") {
      selectedIndex = 2;
    } else if (widget.title == "후기 게시판") {
      selectedIndex = 3;
    }
  }



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
          "게시판",
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
          Column(
            children: [
              // 탭바
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildTabButton("자유", 0),
                    buildTabButton("일기", 1),
                    buildTabButton("고민", 2),
                    buildTabButton("후기", 3),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Firestore에서 데이터 가져오기
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getBoardPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("게시글이 없습니다."));
                    }

                    var posts = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        var post = posts[index];
                        String postId = post.id; // Firestore 자동 생성된 ID (postId)
                        String uid = post["uid"]; // 게시글 작성자 uid
                        return Center(
                          child: postPanel(
                            post["title"], // 제목
                            post["content"], // 내용
                            postId, // postId로 변경
                            uid, // uid도 추가
                            post["timestamp"], // 작성 시간
                            postId, // 이제 조회수를 view 컬렉션으로 계산
                            panelHeight,
                            panelWidth,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 글쓰기 버튼
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                List<String> boardNames = ["자유게시판", "일기게시판", "고민게시판", "후기게시판"];
                String selectedBoard = boardNames[selectedIndex];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WritePostScreen(boardName: selectedBoard),
                  ),
                );
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

  // Firestore에서 현재 선택된 게시판의 글 목록 가져오기
  Stream<QuerySnapshot> getBoardPosts() {
    List<String> boardNames = ["자유게시판", "일기게시판", "고민게시판", "후기게시판"];
    String selectedBoard = boardNames[selectedIndex];

    try {
      return FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts")
          .where("boardName", isEqualTo: selectedBoard) // 선택한 게시판 필터링
          .orderBy("timestamp", descending: true) // 최신 글 순 정렬
          .snapshots();
    } catch (e) {
      print("Firestore 쿼리 오류: $e");
      return const Stream.empty(); // 오류 발생 시 빈 스트림 반환
    }
  }

  // 탭 버튼 위젯
  Widget buildTabButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selectedIndex == index ? Colors.black : Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 메시지 전송 시간 계산 (분, 시간, 일 단위로 출력)
  String _getTimeAgo(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    Duration diff = DateTime.now().difference(messageTime);
    if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inMinutes}분 전';
    }
  }

  Widget postPanel(String title, String content, String postId, String uid, Timestamp date, String postIdForView, double height, double width) {
    return FutureBuilder<String>(
      future: getUserNickname(uid), // Firestore에서 닉네임 가져오기
      builder: (context, snapshot) {
        String nickname = snapshot.data ?? "로딩 중...";

        return GestureDetector(  // GestureDetector로 감싸서 클릭 이벤트 처리
          onTap: () async {
            // 클릭 시 조회수 기록
            await addView(postIdForView, uid);

            // 게시글 상세 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(postId: postId), // 상세 화면으로 이동, uid와 postId 전달
              ),
            );
          },
          child: Column(
            children: [
              Divider(height: 0, thickness: 1, color: const Color(0xFFCBCBCB)),
              Container(
                height: height,
                width: width,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(content, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("작성자: $nickname", style: const TextStyle(fontSize: 12, color: Colors.grey)), // 닉네임 추가
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getTimeAgo(date), style: const TextStyle(fontSize: 14, color: Color(0xFFCBCBCB))),
                        Row(
                          children: [
                            // 조회수 아이콘과 텍스트
                            Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                            FutureBuilder<int>(
                              future: getViewCount(postIdForView), // 조회수 가져오기
                              builder: (context, snapshot) {
                                return Text("${snapshot.data ?? 0}");
                              },
                            ),
                            const SizedBox(width: 5,),
                            // 좋아요 아이콘과 텍스트
                            Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                            FutureBuilder<int>(
                              future: getLikeCount(postIdForView), // 좋아요 개수 가져오기
                              builder: (context, snapshot) {
                                return Text("${snapshot.data ?? 0}");
                              },
                            ),
                            const SizedBox(width: 5,),
                            // 댓글 개수 아이콘과 텍스트
                            Icon(Icons.comment, size: 16, color: Colors.grey),
                            FutureBuilder<int>(
                              future: getCommentCount(postIdForView), // 댓글 개수 가져오기
                              builder: (context, snapshot) {
                                return Text("${snapshot.data ?? 0}");
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 0, thickness: 1, color: const Color(0xFFCBCBCB)),
            ],
          ),
        );
      },
    );
  }

  Future<void> addView(String postId, String uid) async {
    final viewDocRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(postId)
        .collection("view")
        .doc(uid);

    // 유저가 이미 조회한 기록이 없다면 새로운 document를 생성
    var docSnapshot = await viewDocRef.get();
    if (!docSnapshot.exists) {
      await viewDocRef.set({
        "uid": uid,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<int> getViewCount(String postId) async {
    final viewSnapshot = await FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(postId)
        .collection("view")
        .get();

    return viewSnapshot.docs.length;
  }

  Future<String> getUserNickname(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("register") // register 컬렉션에서
          .doc(uid) // 해당 uid 문서 가져오기
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc["nickname"] ?? "알 수 없음"; // 닉네임이 없으면 "알 수 없음" 반환
      } else {
        return "알 수 없음";
      }
    } catch (e) {
      print("닉네임 가져오기 오류: $e");
      return "오류 발생";
    }
  }
  // 좋아요 개수 가져오기
  Future<int> getLikeCount(String postId) async {
    try {
      QuerySnapshot likeSnapshot = await FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts")
          .doc(postId)
          .collection("like")  // like 서브컬렉션에서
          .get();

      return likeSnapshot.docs.length;  // 좋아요의 개수 반환
    } catch (e) {
      print("좋아요 개수 가져오기 오류: $e");
      return 0;  // 오류 발생 시 0 반환
    }
  }

// 댓글 개수 가져오기
  Future<int> getCommentCount(String postId) async {
    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .get();

      return commentSnapshot.docs.length; // 댓글의 개수 반환
    } catch (e) {
      print("댓글 개수 가져오기 오류: $e");
      return 0; // 오류 발생 시 0 반환
    }
  }
}
