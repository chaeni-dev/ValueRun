import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TotalPage extends StatefulWidget {
  const TotalPage({super.key});

  @override
  State<TotalPage> createState() => _TotalPageState();
}

class _TotalPageState extends State<TotalPage> {
  final String baseUrl =
      'http://localhost:4000'; // ⚠️ 시뮬레이터 → localhost, 실기기 → Mac IP
  final int userId = 1;

  double totalDistanceKm = 0;
  double donatedKm = 0;
  double availableKm = 0;
  List<dynamic> activeCampaigns = [];
  List<dynamic> donationHistory = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // 📡 모든 데이터 한번에 로드
  Future<void> _loadAllData() async {
    await Future.wait([
      _fetchSummary(),
      _fetchCampaigns(),
      _fetchDonationHistory(),
    ]);
    setState(() => isLoading = false);
  }

  // ✅ 누적 기록 데이터
  Future<void> _fetchSummary() async {
    try {
      final res =
          await http.get(Uri.parse('$baseUrl/api/summary/total?userId=$userId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          totalDistanceKm =
              double.tryParse(data['total_distance_km'].toString()) ?? 0.0;
          donatedKm =
              double.tryParse(data['donated_km'].toString()) ?? 0.0;
          availableKm =
              double.tryParse(data['available_km'].toString()) ?? 0.0;
        });
      } else {
        debugPrint("⚠️ 요약 불러오기 실패: ${res.body}");
      }
    } catch (e) {
      debugPrint('❌ 서버 통신 오류(_fetchSummary): $e');
    }
  }

  // ✅ 캠페인 목록
  Future<void> _fetchCampaigns() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/donation/campaigns'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          activeCampaigns = data['campaigns'] ?? [];
        });
      } else {
        debugPrint("⚠️ 캠페인 불러오기 실패: ${res.body}");
      }
    } catch (e) {
      debugPrint('❌ 서버 통신 오류(_fetchCampaigns): $e');
    }
  }

  // ✅ 최근 기부 내역
  Future<void> _fetchDonationHistory() async {
    try {
      final res =
          await http.get(Uri.parse('$baseUrl/api/donation/recent?userId=$userId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          donationHistory = data['history'] ?? data['donations'] ?? [];
        });
      } else {
        debugPrint("⚠️ 기부 내역 불러오기 실패: ${res.body}");
      }
    } catch (e) {
      debugPrint('❌ 서버 통신 오류(_fetchDonationHistory): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '전체',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1️⃣ 나의 누적 기록
            _sectionTitle('나의 누적 기록'),
            _recordCard(
              totalDistance: totalDistanceKm,
              donatedKm: donatedKm,
              availableKm: availableKm,
            ),
            const SizedBox(height: 20),

            // 2️⃣ 진행 중인 캠페인
            _sectionTitle('진행 중인 캠페인'),
            _campaignList(activeCampaigns),
            const SizedBox(height: 20),

            // 3️⃣ 최근 기부 내역
            _sectionTitle('최근 기부 내역'),
            _donationHistory(donationHistory),
            const SizedBox(height: 20),

            // 4️⃣ 앱 안내
            _sectionTitle('앱 이용 안내'),
            const Text(
              '가치런은 달리기를 통해 사회에 선한 영향을 전하는 플랫폼입니다.\n'
              '달린 거리만큼 기부가 적립되고, 챌린지 참여로 다른 사람들과 선행을 이어갈 수 있습니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // 📍 구역 제목 위젯
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      );

  // 📊 누적 기록 카드
  Widget _recordCard({
    required double totalDistance,
    required double donatedKm,
    required double availableKm,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.directions_run, '전체 거리',
              '${totalDistance.toStringAsFixed(1)} km'),
          _statItem(Icons.volunteer_activism, '기부한 거리',
              '${donatedKm.toStringAsFixed(1)} km'),
          _statItem(Icons.favorite, '기부 가능 거리',
              '${availableKm.toStringAsFixed(1)} km'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blueAccent),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // 📍 진행 중인 캠페인 리스트
  Widget _campaignList(List<dynamic> campaigns) {
    if (campaigns.isEmpty) {
      return const Text("진행 중인 캠페인이 없습니다.",
          style: TextStyle(color: Colors.grey));
    }
    return Column(
      children: campaigns
          .map(
            (c) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.flag, color: Colors.blueAccent),
                title: Text(c['title'] ?? '무제 캠페인',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('기간: ${c['period'] ?? '상시 진행'}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          )
          .toList(),
    );
  }

  // ✅ 최근 기부 내역
  Widget _donationHistory(List<dynamic> donations) {
    if (donations.isEmpty) {
      return const Text("최근 기부 내역이 없습니다.",
          style: TextStyle(color: Colors.grey));
    }
    return Column(
      children: donations.map((d) {
        final date = d['created_at'] ?? d['date'] ?? '-';
        final distance = double.tryParse(
                (d['amount_km'] ?? d['distance'] ?? 0).toString()) ??
            0.0;

        return Container(
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 14)),
              Text(
                '${distance.toStringAsFixed(1)} km',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}