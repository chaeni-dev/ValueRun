import 'package:flutter/material.dart';

class CrewListPage extends StatelessWidget {
  const CrewListPage({super.key});

  final List<Map<String, String>> crews = const [
    {
      "name": "부산 러너스",
      "desc": "서부산 지역 주말 달리기 모임 🏃‍♀️",
      "members": "27명"
    },
    {
      "name": "새벽크루",
      "desc": "매일 아침 6시에 함께 달려요 🌅",
      "members": "18명"
    },
    {
      "name": "가치런 공식 크루",
      "desc": "가치런 유저들이 함께하는 공식 모임 💙",
      "members": "102명"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: crews.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final crew = crews[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.people, color: Colors.white),
            ),
            title: Text(crew["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(crew["desc"]!),
            trailing: Text(
              crew["members"]!,
              style: const TextStyle(color: Colors.blueGrey),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${crew["name"]} 상세보기 준비 중...')),
              );
            },
          ),
        );
      },
    );
  }
}
