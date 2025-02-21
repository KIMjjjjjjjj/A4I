import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController currentNicknameController = TextEditingController();
  final TextEditingController newNicknameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  File? profileImage;
  String? profileImageUrl;

  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('register')
        .doc(user?.uid)
        .get();

    if (userDoc.exists) {
      profileImageUrl = userDoc['profileImageUrl'];
      currentNicknameController.text = userDoc['nickname'] ?? '';
    }
    setState(() {});
  }

  Future<void> pickImage() async{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (croppedImage != null) {
        setState((){
          profileImage = File(croppedImage.path);
        });
      }
    }
  }

  Future<void> updateProfile() async {
    final userNewNickname = newNicknameController.text.trim();

    if (profileImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child("profileImage/${user?.uid}.jpg");
      await storageRef.putFile(profileImage!);
      profileImageUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .update({
        'profileImageUrl':profileImageUrl,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .update({
        'profileImageUrl':profileImageUrl,
      });
    }

    if (userNewNickname.isNotEmpty){
      await FirebaseFirestore.instance
          .collection('register')
          .doc(user!.uid)
          .update({
        'nickname':userNewNickname,
      });

      setState(() {
        currentNicknameController.text = userNewNickname;
        newNicknameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFF4),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '프로필 편집',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEFEFF4),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 700,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      profileImage != null
                          ? CircleAvatar(
                        radius: 70,
                        backgroundImage: FileImage(profileImage!),
                      )
                          : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(profileImageUrl!),
                        )
                            : Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[400],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 110,
                            color: Colors.white,
                          )
                        )
                      ),

                      Positioned(
                        bottom: 3,
                        right: 3,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    children: [
                                      SimpleDialogOption(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await pickImage();
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.photo_library),
                                            SizedBox(width: 10),
                                            Text('이미지 선택'),
                                          ],
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            profileImage = null;
                                            profileImageUrl = null;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.refresh),
                                            SizedBox(width: 10),
                                            Text('기본 이미지'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            padding: EdgeInsets.all(2),
                            constraints: BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        '현재 닉네임',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: currentNicknameController,
                          enabled: false,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '새 닉네임',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: newNicknameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: '한글 및 영어로 10자 이내',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            counterText: '',
                          ),
                          maxLength: 10,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7791E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(400, 55),
                    ),
                    onPressed: () {
                      updateProfile();
                      print("프로필이 변경되었습니다.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('프로필이 변경되었습니다.')),
                      );
                    },
                    child: Text(
                      '프로필 변경',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}