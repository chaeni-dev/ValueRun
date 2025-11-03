import 'package:flutter/material.dart';
import 'dart:async'; // Timer 사용을 위해 import

class RunningHomePage extends StatefulWidget {
  const RunningHomePage({super.key});

  @override
  State<RunningHomePage> createState() => _RunningHomePageState();
}

class _RunningHomePageState extends State<RunningHomePage> {
  // 런닝 상태 변수
  bool _isRunning = false; // 현재 러닝 중인지 여부
  Timer? _timer; // 타이머 객체
  int _seconds = 0; // 측정된 시간 (초 단위)

  // 표시될 데이터
  double _distance = 0.0; // 오늘 활동한 거리 (km)
  double _donationDistance = 0.0; // 기부 가능한 거리 (km)
  String _pace = "--'--\""; // 평균 페이스
  int _calories = 0; // 칼로리 (kcal)

  @override
  void dispose() {
    _timer?.cancel(); // 위젯이 사라질 때 타이머를 취소합니다.
    super.dispose();
  }

  // 💡 Start/Stop 버튼 클릭 핸들러
  void _toggleRunning() {
    setState(() {
      if (_isRunning) {
        // Stop 러닝
        _timer?.cancel();
        _isRunning = false;
        // 러닝 종료 후 데이터 확정/저장 로직 추가 가능
        print('러닝 종료. 총 거리: $_distance km');
      } else {
        // Start 러닝
        _isRunning = true;
        _seconds = 0; // 시간 초기화
        _distance = 0.0; // 거리 초기화
        _calories = 0; // 칼로리 초기화
        _startTimer();
      }
    });
  }

  // 💡 타이머 시작 로직
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        
        // 1초마다 데이터 업데이트 (더미 로직)
        // 실제로는 GPS 데이터를 받아 계산해야 합니다.
        
        // 1. 거리 업데이트 (예: 10초에 1km 달린다고 가정)
        if (_seconds % 10 == 0) {
            _distance += 0.1; // 10초마다 100m 증가
            _donationDistance = _distance; // 기부 거리는 일단 활동 거리와 동일하게 설정
        }

        // 2. 평균 페이스 업데이트 (예: 1km를 5분 30초로 달리는 페이스라고 가정)
        // 실제 페이스 계산은 복잡하므로 간단한 예시로 대체합니다.
        int minutes = (_seconds ~/ 60);
        int seconds = (_seconds % 60);
        _pace = '${minutes.toString().padLeft(2, '0')}\'${seconds.toString().padLeft(2, '0')}"';
        
        // 3. 칼로리 업데이트 (예: 1초당 0.5kcal 소모라고 가정)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('기록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                _buildValueText('오늘 활동한 거리', '${_distance.toStringAsFixed(2)} km'),
                _buildValueText('기부 가능한 거리', '${_donationDistance.toStringAsFixed(2)} km'),
              ],
            ),
            
            const SizedBox(height: 50),

            // 2. 평균 페이스, 시간, 칼로리
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueText('평균 페이스', _isRunning ? _pace : "--'--\""), // 러닝 중이 아닐 때 초기값 표시
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
                      : const Icon(Icons.play_arrow, color: Colors.white, size: 50),
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
            
            // 4. 하단 메뉴 버튼
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     _buildBottomMenuItem('총 기록', Icons.history),
            //     _buildBottomMenuItem('기부하기', Icons.favorite_border),
            //     _buildBottomMenuItem('커뮤니티', Icons.people_outline),
            //     _buildBottomMenuItem('전체', Icons.menu),
            //   ],
            // ),
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  // 하단 메뉴 아이템 빌드 위젯
  Widget _buildBottomMenuItem(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.black),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}