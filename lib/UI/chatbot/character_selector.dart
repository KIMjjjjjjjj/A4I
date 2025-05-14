import 'package:flutter/material.dart';

import 'chat_screen.dart';

class CharacterSelectorDialog extends StatelessWidget {
  final List<Map<String, dynamic>> personalities = [
    {
      'title': '기본 성격',
      'image': 'assets/images/Chatbot/VoiceChat/neutral.png',
      'depressed': '그랬구나, 정말 힘들었겠어 지금은 좀 괜찮아?',
      'happy': '너가 기분 좋다니 나도 기뻐!',
      'description': '배려심이 깊고 공감능력이 좋음',
      'usage': '일반적인 대화',
      'color': Color(0xFFFDEAEA),
      'selectprompt': 'chatPrompt',
    },
    {
      'title': '츤데레 성격',
      'image': 'assets/images/Chatbot/VoiceChat/angry.png',
      'depressed': '딱히 너 걱정해서 한 건 아니니까! 그냥... 신경 쓰여',
      'happy': '그냥 기분 좋으면 됐지! 나도 조금 기분 좋아지긴 했어.',
      'description': '겉으로는 퉁명스럽고 차가워 보이지만 속은 따뜻하고 배려심 깊음.',
      'usage': '로맨틱 코미디 스타일 대화',
      'color': Color(0xFFF0637B),
      'selectprompt': 'chatPromptTsundere',
    },
    {
      'title': '소심한 성격',
      'image': 'assets/images/Chatbot/VoiceChat/fear.png',
      'depressed': '아... 그런 거에 대해 걱정하는 거, 잘 모르겠어요... 근데, 힘내세요...',
      'happy': '어... 진짜 좋으시겠어요. 그런 일들이 계속 있으면 좋겠어요...!',
      'description': '불안하고 자기 확신이 부족한 스타일. 항상 조심스러움.',
      'usage': '역전 매력. 공감형 대화',
      'color': Color(0xFFFFE08C),
      'selectprompt': 'chatPromptShy',
    },
    {
      'title': '사투리 성격',
      'image': 'assets/images/Chatbot/VoiceChat/joy1.png',
      'depressed': '그라믄 안 되는기라… 아이고, 참말로.',
      'happy': '헐, 잘 된 거여~!',
      'description': '시원시원하고 정 많은 스타일',
      'usage': '친근하고 인간미 있는 상담',
      'color': Color(0xFF7BD3EA),
      'selectprompt': 'chatPromptDialect',
    },
    {
      'title': '현자 스타일',
      'image': 'assets/images/Chatbot/VoiceChat/joy3.png',
      'depressed': '모든 일에는 때가 있느니라. 이 순간이 지나면 더 나은 시간이 올 것이다.',
      'happy': '그대가 이룬 것이 진심으로 기쁘니, 계속해서 그 길을 가 보거라.',
      'description': '조용하고 지혜로운 조언자 스타일.',
      'usage': '고민 상담, 철학적 대화',
      'color': Color(0xFFEAAF7B),
      'selectprompt': 'chatPromptSavant',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 550,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: personalities.length,
          separatorBuilder: (_, __) => SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = personalities[index];

            return Container(
              width: 260,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: item['color'], width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(item['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item['color'],
                          ),
                          child: Image.asset(item['image'], height: 100, width: 100),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  Text("💬 우울한 얘기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(item['depressed'], style: TextStyle(fontSize: 14)),
                  Divider(),
                  Text("🎉 즐거운 얘기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(item['happy'], style: TextStyle(fontSize: 14)),
                  Divider(),
                  Text("🧠 성격: ${item['description']}", style: TextStyle(fontSize: 14)),
                  Divider(),
                  Text("🎯 활용: ${item['usage']}", style: TextStyle(fontSize: 14)),
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(selectprompt: item['selectprompt']),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF69DEC3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("선택하기"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
