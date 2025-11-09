import 'package:flutter/material.dart';
import 'crew_data.dart';

class CrewListPage extends StatefulWidget {
  const CrewListPage({super.key});

  @override
  State<CrewListPage> createState() => _CrewListPageState();
}

class _CrewListPageState extends State<CrewListPage> {
  void _deleteCrew(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('"${CrewData.crews[index]['name']}" 크루를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                CrewData.crews.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ 크루가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: CrewData.crews.length,
      itemBuilder: (context, index) {
        final crew = CrewData.crews[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(crew['name']),
            subtitle: Text(crew['desc']),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrewDetailPage(crew: crew),
                ),
              ).then((_) => setState(() {}));
            },
            onLongPress: () => _deleteCrew(index), // 👈 길게 누르면 삭제
          ),
        );
      },
    );
  }
}

class CrewDetailPage extends StatelessWidget {
  final Map<String, dynamic> crew;
  const CrewDetailPage({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(crew['name'])),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crew['desc'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🎉 ${crew['name']} 크루에 참여했습니다!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('크루 참여하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
