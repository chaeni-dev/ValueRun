import 'package:flutter/material.dart';

class CampaignDetailPage extends StatelessWidget {
  final String title;
  final String organization;
  final String description;
  final String imageUrl;
  final double goalKm;
  final double currentKm;

  const CampaignDetailPage({
    super.key,
    required this.title,
    required this.organization,
    required this.description,
    required this.imageUrl,
    required this.goalKm,
    required this.currentKm,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentKm / goalKm).clamp(0.0, 1.0);
    final percent = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 200, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 20),
            Text(organization,
                style: const TextStyle(fontSize: 15, color: Colors.blueAccent)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: Colors.orange,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text("진행률: $percent%  (${currentKm.toStringAsFixed(1)} / ${goalKm.toStringAsFixed(0)} km)",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text("캠페인 설명",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}