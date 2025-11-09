// lib/screens/community/crew_list_page.dart
import 'package:flutter/material.dart';
import 'crew.dart';
import 'crew_detail_page.dart';
import 'create_crew_page.dart';

class CrewListPage extends StatefulWidget {
  const CrewListPage({super.key});

  @override
  State<CrewListPage> createState() => _CrewListPageState();
}

class _CrewListPageState extends State<CrewListPage> {
  final List<Crew> crews = [
    const Crew(name: '부산 러너스', desc: '서부산 지역 주말 달리기 모임 🏃‍♀️', members: 27),
    const Crew(name: '새벽크루', desc: '매일 아침 6시에 함께 달려요 🌅', members: 18),
    const Crew(name: '가치런 공식 크루', desc: '가치런 유저들이 함께하는 공식 모임 💙', members: 102),
  ];

  Future<void> _openCreate() async {
    final created = await Navigator.push<Crew>(
      context,
      MaterialPageRoute(builder: (_) => const CreateCrewPage()),
    );
    if (created != null) {
      setState(() => crews.insert(0, created));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${created.name}」 크루가 생성되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('커뮤니티 & 크루', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: crews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = crews[i];
          return _CrewCard(
            crew: c,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CrewDetailPage(crew: c)),
              );
              if (mounted) setState(() {}); // 상세에서 상태 변경 시 반영용
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 3,
            ),
            icon: const Icon(Icons.add),
            label: const Text('크루 만들기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            onPressed: _openCreate,
          ),
        ),
      ),
    );
  }
}

class _CrewCard extends StatelessWidget {
  final Crew crew;
  final VoidCallback onTap;
  const _CrewCard({required this.crew, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F5FF),
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFFF3F6FF), Color(0xFFEFF2FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C7DFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crew.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      crew.desc,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _MemberPill(count: crew.members),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  final int count;
  const _MemberPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3ECFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Text(
        '$count명',
        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3658CC)),
      ),
    );
  }
}
