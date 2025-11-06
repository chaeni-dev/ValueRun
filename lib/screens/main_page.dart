// lib/screens/main_page.dart
import 'package:flutter/material.dart';

// 같은 프로젝트 내부 경로 import (파일 이름과 경로에 맞춰 수정)
import 'pages/home/home.dart';             // HomePage
import 'pages/report/report.dart';         // ReportPage
import 'pages/donate/donate_page.dart';    // DonatePage
import 'pages/community/community_page.dart'; // CommunityPage
import 'pages/total/total.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // const 제거: 각 페이지 생성자가 const가 아닐 수 있음
  final List<Widget> _pages = [
    RunningHomePage(),
    RunningReportPage(),
    DonatePage(),
    CommunityPage(),
    TotalPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: '기부하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '전체',
          ),
        ],
      ),
    );
  }
}