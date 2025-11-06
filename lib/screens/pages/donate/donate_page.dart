import 'package:flutter/material.dart';

class DonatePage extends StatelessWidget {
  DonatePage({super.key});

// 캠페인 리스트
  final List<Map<String, dynamic>> campaigns = [
    {
      "image": "[https://example.com/goodneighbors.png](https://example.com/goodneighbors.png)",
      "title": "굿네이버스 레이스",
      "organization": "굿네이버스",
      "progress": 0.85,
    },
    {
      "image": "[https://example.com/inoen.png](https://example.com/inoen.png)",
      "title": "걸음걸이이노엔 시즌8",
      "organization": "HK이노엔",
      "progress": 1.14,
    },
  ];

// 챌린지 리스트
  final List<Map<String, dynamic>> challenges = [
    {
      "image": "[https://example.com/run10k.png](https://example.com/run10k.png)",
      "title": "10km 달리기 챌린지",
      "organization": "러닝클럽",
      "progress": 0.5,
    },
    {
      "image": "[https://example.com/run21k.png](https://example.com/run21k.png)",
      "title": "하프 마라톤 챌린지",
      "organization": "마라톤협회",
      "progress": 0.3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // 캠페인 / 챌린지
        child: Scaffold(
          appBar: AppBar(
            title: const Text("기부"),
            centerTitle: true,
            elevation: 0,
            bottom: const TabBar(
              tabs: [
                Tab(text: "캠페인"),
                Tab(text: "챌린지"),
              ],
            ),
          ),
          body: Column(
              children: [
// 상단 기부 현황 박스
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("달린 거리: ___ km", style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text("기부 가능 금액: ___ 원", style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text("기부 현황: ___ 원", style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),


    // 탭뷰 영역
    Expanded(
    child: TabBarView(
    children: [
        _buildListView(campaigns),
    _buildListView(challenges),
    ],
    ),
    ),
    ],
    ),
    ),
    );

  }

// 리스트뷰 빌드 공용 함수
  Widget _buildListView(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CampaignCard(
          imageUrl: item["image"],
          title: item["title"],
          organization: item["organization"],
          progress: item["progress"],
        );
      },
    );
  }
}

class CampaignCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String organization;
  final double progress;

  const CampaignCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.organization,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);

    return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
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
    fontSize: 17, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(organization,
    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
    const SizedBox(height: 8),
    LinearProgressIndicator(
    value: progress > 1 ? 1 : progress,
    minHeight: 6,
    backgroundColor: Colors.grey[300],
    color: Colors.orange,
    ),
    ],
    ),
    ),
    Column(
    children: [
    const Icon(Icons.favorite, color: Colors.redAccent, size: 30),
    Text("$percent%",
    style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
    ),
    ],
    ),
    ),
    );

  }
}