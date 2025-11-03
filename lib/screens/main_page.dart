import 'package:flutter/material.dart';
import '../screens/pages/community/community_page.dart'; // ✅ 커뮤니티 페이지
import '../screens/pages/report/report.dart'; // ✅ 러닝 리포트 페이지 (파일명: report.dart)
import '../screens/pages/home/home.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // ✅ RecordPage() → RunningReportPage() 로 교체
  final List<Widget> _pages = const [
    RunningHomePage(),
    RunningReportPage(), // ✅ 러닝 리포트 페이지 연결
    DonationPage(),
    CommunityPage(),
    MorePage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: '기부하기'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: '전체'),
        ],
      ),
    );
  }
}

// ✅ 이하 기본 페이지들은 그대로 유지
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//   @override
//   Widget build(BuildContext context) => const Center(
//         child: Text('🏃‍♀️ 가치런 홈 화면',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//       );
// }

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('🤝 기부하기 페이지'));
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('☰ 전체 메뉴'));
}
