import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'board_edit_ui.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPostLiked = false; // 게시글 좋아요 상태
  Set<String> _likedComments = Set(); // 댓글 좋아요 상태 저장 (사용자의 uid)

  // 시간 차 계산
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
// 댓글을 Firebase에 저장하는 함수
  void _sendComment() async {
    if (_commentController.text.isEmpty) return;

    String commentContent = _commentController.text;
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "defaultUid";
    Timestamp timestamp = Timestamp.fromDate(DateTime.now());

    // 댓글 Firestore에 저장
    await FirebaseFirestore.instance.collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .add({
      "content": commentContent,
      "timestamp": timestamp,
      "likeCount": 0,
      "uid": uid,
    });

    // 댓글 입력 후 텍스트 필드 초기화
    _commentController.clear();
  }

// 게시글 좋아요 토글
  void _togglePostLike() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "defaultUid";
    var postRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId)
        .collection("like");

    // 이미 좋아요를 눌렀는지 확인
    var likeSnapshot = await postRef.doc(uid).get();
    if (likeSnapshot.exists) {
      // 이미 좋아요 눌렀으면 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미 추천한 게시글입니다.")),
      );
    } else {
      // 좋아요 추가
      await postRef.doc(uid).set({
        "uid": uid,
        "timestamp": Timestamp.now(),
      });

      setState(() {
        _isPostLiked = true; // 좋아요 상태 변경
      });
    }
  }

// 게시글 좋아요 수 가져오기
  Future<int> _getPostLikeCount() async {
    var postRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId)
        .collection("like");

    var likeSnapshot = await postRef.get();
    return likeSnapshot.docs.length; // like 서브컬렉션 문서 개수로 좋아요 개수 파악
  }



// 댓글 좋아요 토글
  void _toggleCommentLike(String commentId) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "defaultUid";
    var commentRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(commentId)
        .collection("like");

    // 이미 좋아요를 눌렀는지 확인
    var likeSnapshot = await commentRef.doc(uid).get();
    if (likeSnapshot.exists) {
      // 이미 좋아요 눌렀으면 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미 추천한 댓글입니다.")),
      );
    } else {
      // 좋아요 추가
      await commentRef.doc(uid).set({
        "uid": uid,
        "timestamp": Timestamp.now(),
      });

      setState(() {
        _likedComments.add(commentId); // 댓글 좋아요 상태 변경
      });
    }
  }

// 댓글 좋아요 수 가져오기
  Future<int> _getCommentLikeCount(String commentId) async {
    var commentRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId)
        .collection("comments")
        .doc(commentId)
        .collection("like");

    var likeSnapshot = await commentRef.get();
    return likeSnapshot.docs.length; // comment 서브컬렉션의 like 문서 개수로 좋아요 개수 파악
  }

  // 댓글 수 가져오기
  Future<int> _getCommentCount() async {
    var commentsRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId)
        .collection("comments");

    var commentSnapshot = await commentsRef.get();
    return commentSnapshot.docs.length; // comments 서브컬렉션 문서 개수로 댓글 수 파악
  }

  // 조회수 가져오기
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

  // 삭제 로직 추가
  void _deletePost() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "defaultUid";
    var postRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId);

    // 게시글의 uid와 현재 사용자의 uid가 같으면 삭제
    var postSnapshot = await postRef.get();
    if (postSnapshot.exists && postSnapshot["uid"] == uid) {
      // 게시글 삭제
      await postRef.delete();

      // 게시글 삭제 후 이전 화면으로 돌아가기
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제할 권한이 없습니다.")),
      );
    }
  }

  // 수정 화면으로 이동하는 함수
  void _editPost() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "defaultUid";
    var postRef = FirebaseFirestore.instance
        .collection("community")
        .doc("AjeagqxuQCcafNgotPhV")
        .collection("posts")
        .doc(widget.postId);

    // 게시글의 uid와 현재 사용자의 uid가 같으면 수정 화면으로 이동
    postRef.get().then((postSnapshot) {
      if (postSnapshot.exists && postSnapshot["uid"] == uid) {
        // 수정 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPostScreen(
              postId: widget.postId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("수정할 권한이 없습니다.")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF8F8),
      appBar: AppBar(
        title: null,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editPost(); // 수정 함수 호출
              } else if (value == 'delete') {
                _deletePost(); // 삭제 함수 호출
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Text('수정')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("community")
            .doc("AjeagqxuQCcafNgotPhV")
            .collection("posts")
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("게시글을 찾을 수 없습니다."));
          }

          var post = snapshot.data!.data() as Map<String, dynamic>;
          Timestamp timestamp = post["timestamp"];
          String uid = post["uid"];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("register")
                            .doc(uid)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          var user = userSnapshot.data!.data() as Map<String, dynamic>;
                          String nickname = user["nickname"] ?? "알 수 없음";
                          String profileImage = user["profileImage"] ?? "";
                          return Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : AssetImage('assets/images/DayLine/default_profile.png') as ImageProvider,
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nickname, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_getTimeAgo(timestamp), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(post["title"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(post["content"], style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      FutureBuilder<int>(
                        future: getViewCount(widget.postId), // 조회수 가져오기
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.visibility, size: 20, color: Colors.grey), // 조회수 아이콘
                              const SizedBox(width: 5),
                              Text("${snapshot.data}", style: TextStyle(fontSize: 16)), // 조회수 카운트
                              const SizedBox(width: 10),
                              FutureBuilder<int>(
                                future: _getPostLikeCount(), // 게시글 좋아요 수
                                builder: (context, likeSnapshot) {
                                  if (likeSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.thumb_up,
                                          size: 20,
                                          color: _isPostLiked ? Colors.blue : Colors.grey,
                                        ),
                                        onPressed: _togglePostLike,
                                      ),
                                      Text("${likeSnapshot.data}"), // 좋아요 수
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              FutureBuilder<int>(
                                future: _getCommentCount(), // 댓글 수
                                builder: (context, commentSnapshot) {
                                  if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.comment, size: 20, color: Colors.grey),
                                        onPressed: () {},
                                      ),
                                      Text("${commentSnapshot.data}"), // 댓글 수 표시
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("community")
                        .doc("AjeagqxuQCcafNgotPhV")
                        .collection("posts")
                        .doc(widget.postId)
                        .collection("comments")
                        .orderBy("timestamp", descending: false)
                        .snapshots(),
                    builder: (context, commentSnapshot) {
                      if (commentSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var comments = commentSnapshot.data!.docs;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index];
                          String commentId = comment.id;
                          String commentUid = comment["uid"];
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("register")
                                .doc(commentUid)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              var user = userSnapshot.data!.data() as Map<String, dynamic>;
                              String nickname = user["nickname"] ?? "알 수 없음";
                              String profileImage = user["profileImage"] ?? "";

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: profileImage.isNotEmpty
                                            ? NetworkImage(profileImage)
                                            : AssetImage('assets/images/DayLine/default_profile.png') as ImageProvider,
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(nickname, style: TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 5),
                                                Text(_getTimeAgo(comment["timestamp"]), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                              ],
                                            ),
                                            Text(comment["content"]),
                                            const SizedBox(height: 10),
                                            FutureBuilder<int>(
                                              future: _getCommentLikeCount(commentId), // 댓글 좋아요 수
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                }
                                                return Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.thumb_up,
                                                        size: 16,
                                                        color: _likedComments.contains(commentId) ? Colors.blue : Colors.grey,
                                                      ),
                                                      onPressed: () => _toggleCommentLike(commentId),
                                                    ),
                                                    Text("${snapshot.data}"),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: '따듯한 한마디 남겨주세요',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.grey[600]),
                        onPressed: _sendComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
