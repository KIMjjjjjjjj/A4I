import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/test_page.dart';


class ExplainTestPage extends StatefulWidget {
  const ExplainTestPage({Key? key}) : super(key: key);

  @override
  _ExplainTestPageState createState() => _ExplainTestPageState();
}


class _ExplainTestPageState extends State<ExplainTestPage> {
  @override
  void initState() {
    super.initState();
  }

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
                '불안 민감성 척도 ASI',
                style: TextStyle(fontSize:25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '16문항',
                style: TextStyle(fontSize: 17, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 330,
                child: Text(
                  '이 척도는 불안과 관련된 증상을 경험할 때 그 증상으로 인해 얼마나 두렵고 염려되는가를 평가하는 검사로서 불안 증상에 대해 개인이 가지고 있는 두려움을 반영한다.'
                      .replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D'),
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestPage()),
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
