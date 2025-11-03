import 'package:flutter/material.dart';

class CreateCrewPage extends StatefulWidget {
  const CreateCrewPage({super.key});

  @override
  State<CreateCrewPage> createState() => _CreateCrewPageState();
}

class _CreateCrewPageState extends State<CreateCrewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _crewNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _submitCrew() {
    if (_formKey.currentState!.validate()) {
      final name = _crewNameController.text;
      final desc = _descController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ "$name" 크루가 생성되었습니다!')),
      );

      _crewNameController.clear();
      _descController.clear();
    }
  }

  @override
  void dispose() {
    _crewNameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              '새 크루 만들기 🏃‍♂️',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _crewNameController,
              decoration: const InputDecoration(
                labelText: '크루 이름',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? '크루 이름을 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '크루 소개',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) =>
                  value == null || value.isEmpty ? '크루 소개를 입력해주세요.' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitCrew,
              icon: const Icon(Icons.add),
              label: const Text('크루 만들기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
