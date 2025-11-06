import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RunningReportPage extends StatefulWidget {
  const RunningReportPage({super.key});

  @override
  State<RunningReportPage> createState() => _RunningReportPageState();
}

class _RunningReportPageState extends State<RunningReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ⚙️ 서버 주소 — iOS 시뮬레이터나 실기기 테스트 시 IP 변경 필요
  final String baseUrl = 'http://localhost:4000';

  // 주간 리포트 데이터
  List<double> weeklyDistances = List.filled(7, 0.0);
  double totalDistance = 0.0;
  int totalRuns = 0;
  String weekLabel = '';

  // 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWeeklyReport(); // 페이지 진입 시 자동 호출
  }

  Future<void> _fetchWeeklyReport() async {
    try {
      setState(() => _isLoading = true);
      final res = await http.get(Uri.parse('$baseUrl/api/report/weekly?userId=1'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          weeklyDistances = List<double>.from(
              (data['dailyDistances'] as List).map((e) => (e as num).toDouble()));
          totalDistance = (data['totalDistance'] as num).toDouble();
          totalRuns = data['totalRuns'] as int;
          weekLabel = data['weekLabel'] ?? '이번 주';
        });
      } else {
        print('❌ 주간 리포트 요청 실패: ${res.body}');
      }
    } catch (e) {
      print('⚠️ 서버 연결 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
          '러닝 레포트',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWeeklyView(),
                _buildMonthlyView(), // 지금은 더미 데이터 유지
              ],
            ),
    );
  }

  // ✅ 주간 리포트 차트
  Widget _buildWeeklyView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          weekLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['월', '화', '수', '목', '금', '토', '일'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()],
                                style: const TextStyle(fontSize: 12)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                    ),
                  ),
                ),
                barGroups: weeklyDistances.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.blueAccent,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                maxY: (weeklyDistances.reduce((a, b) => a > b ? a : b) + 1)
                    .ceilToDouble(),
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

  // 📅 월간 리포트 (현재 더미)
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
            aspectRatio: 1.0,
            child: GridView.builder(
              itemCount: 30,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                bool ranToday = (index == 2 || index == 3);
                bool isToday = (index == 2);
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ranToday
                        ? Colors.blueAccent.withOpacity(0.2)
                        : Colors.white,
                    border: Border.all(
                      color: isToday ? Colors.blueAccent : Colors.black12,
                      width: isToday ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: ranToday
                          ? Colors.blueAccent.shade700
                          : Colors.black,
                      fontWeight:
                          ranToday ? FontWeight.bold : FontWeight.normal,
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

  // 📊 하단 요약 박스
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
          _buildSummaryItem('${totalDistance.toStringAsFixed(2)} km', '총 거리'),
          const Text('|',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          _buildSummaryItem('$totalRuns 회', '총 러닝'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
