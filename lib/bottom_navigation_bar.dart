import 'setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide NavigationBar;


class CustomNavigationBar extends StatefulWidget {
  final String elements;

  const CustomNavigationBar({super.key, required this.elements});

  @override
  State<CustomNavigationBar> createState() => NavigationBarState();
}

class NavigationBarState extends State<CustomNavigationBar> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      SettingPage(elements: widget.elements),
      SettingPage(elements: widget.elements),
      SettingPage(elements: widget.elements),
      SettingPage(elements: widget.elements),
    ];

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '상담'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: '프로필'),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey[200],
        onTap: (int index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
