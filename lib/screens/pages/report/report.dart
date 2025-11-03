import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // fl_chart 패키지 사용

class RunningReportPage extends StatefulWidget {
  const RunningReportPage({super.key});

  @override
  State<RunningReportPage> createState() => _RunningReportPageState();
}

class _RunningReportPageState extends State<RunningReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<double> weeklyDistances = [1.7, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  final double totalDistance = 1.7;
  final int totalRuns = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '러닝레포트',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: '주간'),
            Tab(text: '월간'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyView(),
          _buildMonthlyView(),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          '2025년 11월 1주차',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true), // 그리드 추가
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['월', '화', '수', '목', '금', '토', '일'];
                        return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()],
                                style: const TextStyle(fontSize: 12)));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32, // 타이틀 공간 확보
                      interval: 1, // 1km 단위로 레이블 표시
                    ),
                  ),
                ),
                barGroups: weeklyDistances.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.blueAccent, // 색상 변경
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                // 최대 y값 설정
                maxY: (weeklyDistances.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble(),
                minY: 0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSummaryBox(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMonthlyView() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '<2025년 11월>',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AspectRatio(
            aspectRatio: 1.0, // 정사각형으로 만들어줍니다.
            child: GridView.builder(
              itemCount: 30, // 11월은 30일까지 있다고 가정
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 요일 수
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                // 더미 데이터: 3일(index 2), 4일(index 3)은 러닝 기록이 있다고 가정
                bool ranToday = (index == 2 || index == 3);
                bool isToday = (index == 2); // 예시: 3일을 오늘로 가정
                
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ranToday ? Colors.blueAccent.withOpacity(0.2) : Colors.white,
                    border: Border.all(
                      color: isToday ? Colors.blueAccent : Colors.black12,
                      width: isToday ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: ranToday ? Colors.blueAccent.shade700 : Colors.black,
                      fontWeight: ranToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSummaryBox(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('$totalDistance km', '총 거리'),
          const Text('|', style: TextStyle(fontSize: 16, color: Colors.black54)),
          _buildSummaryItem('$totalRuns 회', '총 러닝'), // '개거리'를 '회'로 수정
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}