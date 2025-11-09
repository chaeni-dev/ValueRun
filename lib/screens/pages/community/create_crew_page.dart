// lib/screens/community/create_crew_page.dart
import 'package:flutter/material.dart';
import 'crew.dart';
import 'crew_list_page.dart'; // ← 단독 실행일 때 fallback 이동용

class CreateCrewPage extends StatefulWidget {
  const CreateCrewPage({super.key});

  @override
  State<CreateCrewPage> createState() => _CreateCrewPageState();
}

class _CreateCrewPageState extends State<CreateCrewPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;

    // 키보드 내려주기(미세하지만 UX 이득)
    FocusScope.of(context).unfocus();

    final crew = Crew(
      name: _name.text.trim(),
      desc: _desc.text.trim(),
      members: 1,
    );

    if (Navigator.canPop(context)) {
      // 정상 플로우: 이전 화면(크루 목록)으로 결과 전달
      Navigator.pop(context, crew);
    } else {
      // 단독 실행 등 루트에서 열린 경우: 목록으로 안전하게 교체 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${crew.name}」 크루가 생성되었습니다.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CrewListPage()),
      );
      // 필요하면 CrewListPage가 생성자를 통해 초기 아이템을 받도록 확장 가능
      // (ex. CrewListPage(initial: [crew, ...]))
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('크루 만들기', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _LabeledField(
              label: '크루 이름',
              child: TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: '예) 부산 러너스',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '필수 입력' : null,
              ),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: '소개/설명',
              child: TextFormField(
                controller: _desc,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '예) 서부산 지역 주말 달리기 모임',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '필수 입력' : null,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _submit, // ← 여기만 호출
            child: const Text('생성', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: child,
          ),
        ),
      ],
    );
  }
}
