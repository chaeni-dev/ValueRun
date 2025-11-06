import 'package:flutter/material.dart';

class TotalPage extends StatelessWidget {
  const TotalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '전체',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1️⃣ 나의 누적 기록
          _sectionTitle('나의 누적 기록'),
          _recordCard(
            distance: 42.3,
            donation: 28500,
            calories: 980,
          ),
          const SizedBox(height: 20),

          // 2️⃣ 진행 중인 챌린지
          _sectionTitle('진행 중인 챌린지'),
          _challengeList(),
          const SizedBox(height: 20),

          // 3️⃣ 최근 기부 내역
          _sectionTitle('최근 기부 내역'),
          _donationHistory(),
          const SizedBox(height: 20),

          // 4️⃣ 앱 안내
          _sectionTitle('앱 이용 안내'),
          const Text(
            '가치런은 달리기를 통해 사회에 선한 영향을 전하는 플랫폼입니다.\n'
                '달린 거리만큼 기부가 적립되고, 챌린지 참여로 다른 사람들과 선행을 이어갈 수 있습니다.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 구역 제목 위젯
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  );

  // 누적 기록 카드
  Widget _recordCard({
    required double distance,
    required int donation,
    required int calories,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.directions_run, '거리', '${distance.toStringAsFixed(1)} km'),
          _statItem(Icons.volunteer_activism, '기부', _km(donation)),
          _statItem(Icons.local_fire_department, '칼로리', '$calories kcal'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blueAccent),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  String _km(int n) =>
      '${n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km';

  // 진행 중인 챌린지 예시
  Widget _challengeList() {
    final List<Map<String, String>> challenges = [
      {'title': '탄소중립 달리기', 'period': '10.01~11.01'},
      {'title': '따뜻한 마음 5km', 'period': '10.10~11.10'},
    ];

    return Column(
      children: challenges
          .map(
            (c) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.flag, color: Colors.blueAccent),
            title: Text(c['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('기간: ${c['period']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 챌린지 상세 화면으로 이동 가능
            },
          ),
        ),
      )
          .toList(),
    );
  }

  // ✅ 기부 내역 (타입 명시)
  Widget _donationHistory() {
    final List<Map<String, dynamic>> donations = [
      {'date': '2025-10-20', 'amount': 5000},
      {'date': '2025-10-25', 'amount': 3200},
      {'date': '2025-11-02', 'amount': 7200},
    ];

    return Column(
      children: donations.map((d) {
        final String date = d['date'] as String;
        final int amount = d['amount'] as int;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 14)),
              Text(
                _km(amount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
