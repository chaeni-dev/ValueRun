import 'package:flutter/material.dart';
import 'crew_data.dart';

class CreateCrewPage extends StatefulWidget {
  final VoidCallback onCreated; // ✅ 콜백 추가
  const CreateCrewPage({super.key, required this.onCreated});

  @override
  State<CreateCrewPage> createState() => _CreateCrewPageState();
}

class _CreateCrewPageState extends State<CreateCrewPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _createCrew() {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
      return;
    }

    CrewData.crews.add({'name': name, 'desc': desc});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ "$name" 크루가 생성되었습니다!')),
    );

    _nameController.clear();
    _descController.clear();

    widget.onCreated(); // ✅ 콜백 호출 → 목록 탭으로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '크루 이름'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: '크루 설명'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createCrew,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('크루 생성하기'),
          ),
        ],
      ),
    );
  }
}
