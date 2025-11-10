import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RunningHomePage extends StatefulWidget {
  const RunningHomePage({super.key});

  @override
  State<RunningHomePage> createState() => _RunningHomePageState();
}

class _RunningHomePageState extends State<RunningHomePage> {
  final String baseUrl = 'http://localhost:4000';
  final int userId = 1;

  bool _isRunning = false;
  Timer? _timer;
  int _seconds = 0;
  int? _runId;

  double _distance = 0.0;
  double _donationDistance = 0.0;
  String _pace = "--'--\"";
  int _calories = 0;

  @override
  void initState() {
    super.initState();
    _fetchDonationBalance();
  }
  
    // ✅ 여기에 추가
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 다른 탭에서 돌아올 때 자동으로 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDonationBalance();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDonationBalance() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/summary/total?userId=$userId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _donationDistance = double.tryParse(data['available_km'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      print('❌ 서버 연결 실패 (_fetchDonationBalance): $e');
    }
  }

  void _toggleRunning() async {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      if (_runId != null) await _finishRunOnServer();
    } else {
      setState(() {
        _isRunning = true;
      setState(() {
        _isRunning = true;
        _seconds = 0;
        _distance = 0.0;
        _calories = 0;
      });

        _calories = 0;
      });
      await _startRunOnServer();
      _startTimer();
    }
  }

void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      _seconds++;
      if (_seconds % 10 == 0) _distance += 0.1;

      // ✅ 페이스 계산 제거 (고정)
      _pace = "--'--\"";

      _calories = (_seconds * 0.5).toInt();
    });
  });
}


  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startRunOnServer() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/runs/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'startedAt': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _runId = data['runId']);
      }
    } catch (e) {
      print('⚠️ 서버 연결 실패 (start): $e');
    }
  }

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
        setState(() {
          _donationDistance = (data['wallet_km_balance'] as num?)?.toDouble() ?? 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('러닝 기록이 서버에 저장되었습니다 ✅')),
        );
      }
    } catch (e) {
      print('⚠️ 서버 연결 실패 (finish): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF15B3DA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('기록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // 🔹 상단 카드 (거리 / 기부)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard('오늘 활동한 거리', '${_distance.toStringAsFixed(2)} km', brandColor),
                _buildCard('기부 가능한 거리', '${_donationDistance.toStringAsFixed(2)} km', Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 40),

            // 🔹 중간 정보 3개 (페이스 / 시간 / 칼로리)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo('평균 페이스', _isRunning ? _pace : "--'--\""),
                _buildInfo('시간', _formatTime(_seconds)),
                _buildInfo('칼로리', '$_calories kcal'),
              ],
            ),
            const Spacer(),

            // 🔹 하단 버튼
            GestureDetector(
              onTap: _toggleRunning,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isRunning
                        ? [Colors.redAccent, Colors.red]
                        : [brandColor.withOpacity(0.8), brandColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isRunning ? Colors.redAccent.withOpacity(0.4) : brandColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                    Text(
                      _isRunning ? 'STOP' : 'START',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String label, String value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}