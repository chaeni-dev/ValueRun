// lib/screens/community/crew_detail_page.dart
import 'package:flutter/material.dart';
import 'crew.dart';

class CrewDetailPage extends StatefulWidget {
  final Crew crew;
  const CrewDetailPage({super.key, required this.crew});

  @override
  State<CrewDetailPage> createState() => _CrewDetailPageState();
}

class _CrewDetailPageState extends State<CrewDetailPage> {
  bool joined = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.crew;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoTile(
            icon: Icons.info_outline,
            title: '크루 소개',
            child: Text(c.desc, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.event_available,
            title: '예시 공지',
            child: const Text('부산 하단동 | 11월 3일 20시 러닝 모집합니다 🏃‍♂️'),
          ),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.people_alt_outlined,
            title: '현재 인원',
            child: Text('${c.members}명', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: joined ? const Color(0xFF16A34A) : const Color(0xFF4C7DFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              setState(() => joined = !joined);
              final msg = joined ? '참여 완료! 크루 채팅에 인사해요 🙌' : '참여 취소했습니다.';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            },
            child: Text(joined ? '참여 완료' : '크루 참여하기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoTile({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF4C7DFF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
