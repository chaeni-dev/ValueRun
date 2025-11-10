// lib/screens/community/notice_list_page.dart
import 'package:flutter/material.dart';

class NoticeListPage extends StatelessWidget {
  final String crewName;
  final List<NoticeItem> notices;

  const NoticeListPage({
    super.key,
    required this.crewName,
    required this.notices,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text('$crewName 공지', style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = notices[i];
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
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event_available_rounded, color: Color(0xFF3A63FF)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(n.subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NoticeItem {
  final String title;
  final String subtitle;
  const NoticeItem({required this.title, required this.subtitle});
}