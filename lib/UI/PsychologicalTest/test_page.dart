import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repos/UI/PsychologicalTest/test_result_page.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<int> selectedValues = List.filled(6, 0);
  List<String> questions = [
    '1. 남들에게 불안하게 보이지 말아야 한다.',
    '2. 집중이 잘 안되면, 이러다가 미치는 것은 아닌가 걱정한다.',
    '3. 몸이 떨리거나 휘청거리면, 겁이 난다.',
    '4. 기절할 것 같으면, 겁이 난다.',
    '5. 감정 조절은 잘 하는 것이 중요하다.',
    '6. 심장이 빨리 뛰면 겁이 난다.',
  ];
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Text(
                '불안 민감성 척도 ASI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                '0: 전혀 그렇지 않다  1: 약간 그런 편이다\n2: 중간이다  3: 꽤 그런 편이다  4: 매우 그렇다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 7),
              const Text(
                '1/2',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(questions.length, (index) {
                      return QuestionSlider(
                        question: questions[index],
                        value: selectedValues[index],
                        onChanged: (value) {
                          setState(() => selectedValues[index] = value);
                        },
                      );
                    })
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6BE5A0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        padding: const EdgeInsets.all(12.0),
                      ),
                      child: const Text(
                        '뒤로가기',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => TestPage()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6BE5A0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        padding: const EdgeInsets.all(12.0),
                      ),
                      child: const Text(
                        '다음',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
            ]
          ),
        ),
      )
    );
  }
}

class QuestionSlider extends StatelessWidget {
  final String question;
  final int value;
  final ValueChanged<int> onChanged;

  const QuestionSlider({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 16)),
        Stack(
          children: [
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFF7D3),
                  borderRadius: BorderRadius.circular(17.0),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Column(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: value,
                        onChanged: (value) => onChanged(value!),
                        activeColor: Color(0xFF6BE5A0),
                        fillColor: MaterialStateColor.resolveWith((states) => Color(0xFF6BE5A0)),
                      ),
                      Text(index.toString()),
                    ],
                  );
                }),
              ),
            )
          ],
        ),
        SizedBox(height: 10)
      ],
    );
  }
}

