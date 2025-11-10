// lib/screens/community/crew_detail_page.dart
import 'package:flutter/material.dart';
import 'crew.dart';
import 'notice_list_page.dart';
import 'members_page.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // Hero card
          _HeroCard(title: c.name, desc: c.desc, members: c.members),

          const SizedBox(height: 16),

          // Stats chips
          Row(
            children: [
              _StatChip(icon: Icons.people_alt_rounded, label: '인원', value: '${c.members}명'),
              const SizedBox(width: 8),
              const _StatChip(icon: Icons.flag_rounded, label: '상태', value: '모집중'),
              const SizedBox(width: 8),
              const _StatChip(icon: Icons.place_rounded, label: '지역', value: '부산'),
            ],
          ),

          const SizedBox(height: 20),

          // 소개
          _Section(
            icon: Icons.info_outline_rounded,
            title: '크루 소개',
            child: Text(
              c.desc,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF374151)),
            ),
          ),

          const SizedBox(height: 14),

          // 공지
          _Section(
            icon: Icons.campaign_rounded,
            title: '공지',
            trailing: TextButton(
              onPressed: () { Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoticeListPage(
          crewName: c.name,
          notices: const [
            NoticeItem(title: '부산 하단 러닝', subtitle: '11월 3일(월) 20:00 | 5km 러닝'),
            NoticeItem(title: '신규 멤버 OT',  subtitle: '11월 10일(월) 19:30 | 온라인 ZOOM'),
          ],
        ),
      ),
    );},
              child: const Text('더보기'),
            ),
            child: Column(
              children: const [
                _NoticeCard(
                  title: '부산 하단 러닝',
                  subtitle: '11월 3일(월) 20:00 | 5km 러닝',
                ),
                SizedBox(height: 10),
                _NoticeCard(
                  title: '신규 멤버 OT',
                  subtitle: '11월 10일(월) 19:30 | 온라인 ZOOM',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 멤버 프리뷰
          _Section(
            icon: Icons.groups_2_rounded,
            title: '멤버',
            trailing: TextButton(
              onPressed: () {Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MembersPage(
          crewName: c.name,
          initials: const ['HJ','SY','GH','YD','MJ','AR','LK','PN','QS','TT'],
        ),
      ),
    );},
              child: const Text('전체 보기'),
            ),
            child: Row(
              children: [
                const _Avatar(name: 'HJ'),
                const _Avatar(name: 'SY'),
                const _Avatar(name: 'GH'),
                const _Avatar(name: 'YD'),
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('+${(c.members - 4).clamp(0, 999)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF325BFF))),
                )
              ],
            ),
          ),
        ],
      ),

      // Sticky CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _BottomCTA(
          joined: joined,
          onPressed: () {
            setState(() => joined = !joined);
            final msg = joined ? '참여 완료! 크루 채팅에 인사해요 🙌' : '참여 취소했습니다.';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          },
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String desc;
  final int members;

  const _HeroCard({required this.title, required this.desc, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4C7DFF), Color(0xFF7FA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4C7DFF).withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -10,
            child: Icon(Icons.directions_run_rounded, size: 140, color: Colors.white.withOpacity(0.12)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.groups_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                        child: Text('$members명 참여 중',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2B4CC3))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4C7DFF)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
    }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({required this.icon, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF4C7DFF)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: child),
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _NoticeCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7FAFF),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDFE8FF)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_available_rounded, color: Color(0xFF3A63FF)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name; // 이니셜 2글자만 넘겨 사용
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFE5ECFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3658CC)),
        ),
      ),
    );
  }
}

class _BottomCTA extends StatelessWidget {
  final bool joined;
  final VoidCallback onPressed;
  const _BottomCTA({required this.joined, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: joined ? const Color(0xFF16A34A) : const Color(0xFF4C7DFF),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: Text(
            joined ? '참여 완료' : '크루 참여하기',
            key: ValueKey(joined),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

