// lib/screens/community/members_page.dart
import 'package:flutter/material.dart';

class MembersPage extends StatelessWidget {
  final String crewName;
  final List<String> initials; // 'HJ', 'SY' 같은 이니셜

  const MembersPage({
    super.key,
    required this.crewName,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text('$crewName 멤버', style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: initials.length,
        itemBuilder: (_, i) {
          final t = initials[i];
          return Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5ECFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3658CC))),
                ),
              ),
              const SizedBox(height: 8),
              Text('러너 ${i + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          );
        },
      ),
    );
  }
}