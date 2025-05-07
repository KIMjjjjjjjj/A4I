import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class DiaryEntryPage extends StatefulWidget {
  final String year;
  final String month;
  final String day;

  const DiaryEntryPage({Key? key, required this.year, required this.month, required this.day,}) : super(key: key);

  @override
  _DiaryEntryPageState createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  String selectedFace = 'assets/face/face1.png';
  File? _selectedImage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> imagePaths = [
    'assets/face/face1.png',
    'assets/face/face2.png',
    'assets/face/face3.png',
    'assets/face/face4.png',
    'assets/face/face5.png',
    'assets/face/face6.png',
    'assets/face/face7.png',
    'assets/face/face8.png',
    'assets/face/face9.png',
    'assets/face/face10.png',
    'assets/face/face11.png',
    'assets/face/face12.png',
    'assets/face/face13.png',
    'assets/face/face14.png',
    'assets/face/face15.png',
    'assets/face/face16.png',
    'assets/face/face17.png',
    'assets/face/face18.png',
    'assets/face/face19.png',
    'assets/face/face20.png',
    'assets/face/face21.png',
    'assets/face/face22.png',
    'assets/face/face23.png',
    'assets/face/face24.png',
    'assets/face/face25.png',
    'assets/face/face26.png',
    'assets/face/face27.png',
    'assets/face/face28.png',
    'assets/face/face29.png',
    'assets/face/face30.png',


  ];

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (croppedImage != null) {
        setState((){
          _selectedImage = File(croppedImage.path);
        });
      }
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('diary_images/$fileName.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> SaveDiary() async {
    try {
      // 제목이나 내용이 비어 있으면 저장 안 함
      if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
        );
        return; // 저장 중단
      }

      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String year = widget.year;
      String month = widget.month;
      String day = widget.day;
      String Date = '$year-$month-$day';

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      await FirebaseFirestore.instance
          .collection('diary')
          .doc(uid)
          .collection('diary')
          .doc(year)
          .collection(month)
          .doc(day)
          .set({
        'title': _titleController.text,
        'content': _contentController.text,
        'date': Date,
        'face': selectedFace,
        'imagePath': imageUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류')),
      );
    }
  }


  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return GridView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFace = imagePaths[index];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePaths[index],
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F3FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showEmojiPicker,
                              child: Container(
                                child: Center(
                                  child: selectedFace.isNotEmpty
                                      ? Image.asset(
                                    selectedFace,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  )
                                      : Icon(
                                    Icons.add_circle,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('${widget.month}월 ${widget.day}일', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Center(
                          child: _selectedImage != null
                              ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 300,
                          )
                              : Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: '제목',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 1),
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: '일기를 작성해보세요',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // ← 무제한 줄넘김 허용
                      minLines: 5, // ← 최소 높이 설정
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF71ABE8), width: 1.5),
                            ),
                            child: Text('취소', style: TextStyle(color: Colors.black54)),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: SaveDiary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[200],
                            ),
                            child: Text('저장'),
                          ),
                        ),
                      ],
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


