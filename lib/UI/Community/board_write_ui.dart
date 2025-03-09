import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WritePostScreen extends StatefulWidget {
  final String boardName;

  const WritePostScreen({super.key, required this.boardName});

  @override
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool isSaving = false; // 저장 중 여부

  Future<void> savePost() async {
    String title = titleController.text.trim();
    String content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목과 본문을 입력해주세요.")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("로그인이 필요합니다.");
      }

      String uid = user.uid; // 현재 로그인한 사용자 UID
      CollectionReference postsRef = FirebaseFirestore.instance
          .collection("community")
          .doc("AjeagqxuQCcafNgotPhV")
          .collection("posts"); // ✅ 여러 개의 글 저장 가능

      await postsRef.add({
        "boardName": widget.boardName, // 게시판 이름
        "title": title,                // 제목
        "content": content,            // 본문
        "timestamp": FieldValue.serverTimestamp(), // 작성 시간
        "viewCount": 0,                // 조회수 (초기값 0)
        "likeCount": 0,                // 좋아요 개수 (초기값 0)
        "uid": uid,                    // 작성자 UID
      });

      Navigator.pop(context); // 저장 후 뒤로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "글쓰기",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isSaving ? null : savePost,
            child: Text(
              isSaving ? "저장 중..." : "완료",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSaving ? Colors.grey : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "제목을 입력해주세요.",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Color(0xFFCBCBCB)),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: "내용을 입력해주세요.",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
