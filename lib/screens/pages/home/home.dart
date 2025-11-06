import 'package:flutter/material.dart';
import 'dart:async'; // Timer 사용
import 'dart:convert'; // JSON 인코딩
import 'package:http/http.dart' as http; // HTTP 요청

class RunningHomePage extends StatefulWidget {
  const RunningHomePage({super.key});

  @override
  State<RunningHomePage> createState() => _RunningHomePageState();
}

class _RunningHomePageState extends State<RunningHomePage> {
  // 서버 URL (⚠️ 시뮬레이터/실기기에서는 localhost 대신 맥 IP로 변경!)
  final String baseUrl = 'http://localhost:4000';

  // 러닝 상태 변수
  bool _isRunning = false; // 현재 러닝 중인지 여부
  Timer? _timer; // 타이머 객체
  int _seconds = 0; // 측정된 시간 (초 단위)
  int? _runId; // 서버에서 받은 러닝 ID

  // 표시될 데이터
  double _distance = 0.0; // 오늘 활동한 거리 (km)
  double _donationDistance = 0.0; // 기부 가능한 거리 (km)
  String _pace = "--'--\""; // 평균 페이스
  int _calories = 0; // 칼로리 (kcal)

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 💡 Start/Stop 버튼 클릭 핸들러
  void _toggleRunning() async {
    if (_isRunning) {
      // Stop 상태로 전환
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });

      if (_runId != null) {
        await _finishRunOnServer(); // 서버로 러닝 종료 데이터 전송
      }

      print('러닝 종료. 총 거리: $_distance km');
    } else {
      // Start 상태로 전환
      setState(() {
        _isRunning = true;
        _seconds = 0;
        _distance = 0.0;
        _calories = 0;
      });

      await _startRunOnServer(); // 서버로 러닝 시작 기록
      _startTimer();
    }
  }

  // 💡 타이머 시작 로직
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;

        // 1초마다 데이터 업데이트 (더미 로직)
        if (_seconds % 10 == 0) {
          _distance += 0.1; // 10초마다 100m 증가
          _donationDistance = _distance;
        }

        // 평균 페이스 계산
        int minutes = (_seconds ~/ 60);
        int seconds = (_seconds % 60);
        _pace =
            '${minutes.toString().padLeft(2, '0')}\'${seconds.toString().padLeft(2, '0')}"';

        // 칼로리 업데이트
        _calories = (_seconds * 0.5).toInt();
      });
    });
  }

  // 💡 시간을 'MM:SS' 형식으로 포맷
  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ✅ 러닝 시작 시 서버에 기록
  Future<void> _startRunOnServer() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/runs/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1, // 나중에 로그인 기능 생기면 수정 가능
          'startedAt': DateTime.now().toUtc().toIso8601String(),
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _runId = data['runId'];
        });
        print('✅ 러닝 시작 (runId: $_runId)');
      } else {
        print('❌ 러닝 시작 실패: ${res.body}');
      }
    } catch (e) {
      print('⚠️ 서버 연결 실패 (start): $e');
    }
  }

  // ✅ 러닝 종료 시 서버에 기록
  Future<void> _finishRunOnServer() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/runs/$_runId/finish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'finishedAt': DateTime.now().toUtc().toIso8601String(),
          'totalDistanceKm': _distance,
          'totalSeconds': _seconds,
          'calories': _calories,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // ✅ 서버에서 받은 기부 누적 거리 반영
        setState(() {
          _donationDistance = (data['wallet_km_balance'] as num?)?.toDouble() ?? 0.0;
        });

        print('✅ 러닝 종료 업로드 완료: $data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('러닝 기록이 서버에 저장되었습니다 ✅')),
        );
      } else {
        print('❌ 러닝 종료 실패: ${res.body}');
      }
    } catch (e) {
      print('⚠️ 서버 연결 실패 (finish): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('기록',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // 1. 거리 및 기부 거리
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueText(
                    '오늘 활동한 거리', '${_distance.toStringAsFixed(2)} km'),
                _buildValueText(
                    '기부 가능한 거리', '${_donationDistance.toStringAsFixed(2)} km'),
              ],
            ),
            const SizedBox(height: 50),

            // 2. 평균 페이스, 시간, 칼로리
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueText(
                    '평균 페이스', _isRunning ? _pace : "--'--\""),
                _buildValueText('시간', _formatTime(_seconds)),
                _buildValueText('칼로리', '${_calories.toString()} kcal'),
              ],
            ),

            const Spacer(),

            // 3. Start/Stop 버튼
            GestureDetector(
              onTap: _toggleRunning,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRunning ? Colors.redAccent : Colors.green,
                ),
                child: Center(
                  child: _isRunning
                      ? const Icon(Icons.stop, color: Colors.white, size: 50)
                      : const Icon(Icons.play_arrow,
                          color: Colors.white, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isRunning ? 'Stop' : 'Start',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isRunning ? Colors.redAccent : Colors.green,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // 재사용 가능한 텍스트 표시 위젯
  Widget _buildValueText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
