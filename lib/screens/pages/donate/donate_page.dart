import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// 상세페이지 import 추가
import 'campaign_detail_page.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final String baseUrl = 'http://localhost:4000'; // ⚠️ 시뮬레이터 → localhost, 실기기 → 맥 IP
  final int userId = 1;

  double availableKm = 0;
  double donatedKm = 0;
  List<dynamic> campaigns = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _fetchCampaigns();
  }

Future<void> _fetchSummary() async {
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/api/summary/total?userId=$userId'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        // ✅ 홈화면과 동일한 기준으로 통일
        availableKm = double.tryParse(data['available_km'].toString()) ?? 0.0;
        donatedKm = double.tryParse(data['donated_km'].toString()) ?? 0.0;
      });
    } else {
      debugPrint('⚠️ 요약 데이터 불러오기 실패: ${res.body}');
    }
  } catch (e) {
    debugPrint('❌ 요약 데이터 불러오기 실패: $e');
  }
}


  // ✅ 캠페인 리스트 가져오기
  Future<void> _fetchCampaigns() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/donation/campaigns'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          campaigns = data['campaigns'] ?? [];
          isLoading = false;
        });
      } else {
        debugPrint('⚠️ 캠페인 불러오기 실패: ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ 캠페인 불러오기 실패: $e');
    }
  }

  // ✅ 기부하기 API 호출
Future<void> _donate(double km, int campaignId, String title) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/api/donation/donate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'campaignId': campaignId,
        'donateKm': km,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final updatedKm = (data['updatedKm'] as num?)?.toDouble();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ $title에 ${km.toStringAsFixed(1)}km 기부 완료!")),
      );

      // ✅ 상단 요약 다시 불러오기 (기부 가능 거리, 총 기부 거리)
      await _fetchSummary();

      // ✅ 해당 캠페인의 currentKm를 바로 갱신 (updatedKm가 있으면)
      if (updatedKm != null) {
        setState(() {
          campaigns = campaigns.map((c) {
            if (c['id'] == campaignId) {
              final m = Map<String, dynamic>.from(c);
              m['currentKm'] = updatedKm;
              return m;
            }
            return c;
          }).toList();
        });
      }

      

      // ✅ 혹시 반영이 안 될 경우 전체 캠페인 다시 불러오기
      await _fetchCampaigns();
    } else {
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ 실패: ${data['error'] ?? '기부 실패'}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚠️ 서버 연결 실패: $e')),
    );
  }
}

        

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("기부하기", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ 상단 요약 박스
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("기부 가능한 거리",
                      "${availableKm.toStringAsFixed(2)} km", Colors.blueAccent),
                  const Text('|', style: TextStyle(fontSize: 20, color: Colors.black54)),
                  _buildStatItem("기부한 거리",
                      "${donatedKm.toStringAsFixed(2)} km", Colors.orange),
                ],
              ),
            ),
          ),

          // ✅ 캠페인 리스트
          Expanded(
            child: ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                final item = campaigns[index];
                return CampaignCard(
                  campaignId: item['id'],
                  imageUrl: item['image'],
                  title: item['title'],
                  organization: item['organization'],
                  goalKm: (item['goalKm'] as num).toDouble(),
                  currentKm: (item['currentKm'] as num).toDouble(),
                  description: item['description'],
                  onDonate: (km) => _donate(km, item['id'], item['title']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}

// ✅ 캠페인 카드 위젯
class CampaignCard extends StatelessWidget {
  final int campaignId;
  final String imageUrl;
  final String title;
  final String organization;
  final double goalKm;
  final double currentKm;
  final String description;
  final void Function(double donateKm) onDonate;

  const CampaignCard({
    super.key,
    required this.campaignId,
    required this.imageUrl,
    required this.title,
    required this.organization,
    required this.goalKm,
    required this.currentKm,
    required this.description,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
  final ratio = currentKm / goalKm;
  final progress = ratio > 1 ? 1.0 : ratio; // bar는 100%까지만 꽉 차게
  final percent = (ratio * 100).toStringAsFixed(0); // %는 100 넘어도 계속 증가


    // ✅ 카드 전체를 InkWell로 감싸서 탭하면 상세페이지 이동
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetailPage(
              title: title,
              organization: organization,
              description: description,
              imageUrl: imageUrl,
              goalKm: goalKm,
              currentKm: currentKm,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(width: 70, height: 70, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(organization,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "목표 ${goalKm.toStringAsFixed(0)}km 중 ${currentKm.toStringAsFixed(1)}km 달성 ($percent%)",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _showDonationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("기부하기", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 거리 선택 다이얼로그
  void _showDonationDialog(BuildContext context) {
    double selectedKm = 0.5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("$title 기부하기",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${selectedKm.toStringAsFixed(1)} km",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Slider(
                  value: selectedKm,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  label: "${selectedKm.toStringAsFixed(1)} km",
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => selectedKm = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("취소", style: TextStyle(color: Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pop(context);
                  onDonate(selectedKm);
                },
                child:
                    const Text("기부하기", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }
}