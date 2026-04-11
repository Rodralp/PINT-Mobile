import 'package:flutter/material.dart';

class ProgressFullScreen extends StatelessWidget {
  const ProgressFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 36),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Em Progresso',
                    style: TextStyle(
                      fontSize: 48 / 2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF243047),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                children: const [
                  _ProgressItemFull(
                    title: 'LowCode (Outsystems)',
                    progress: 0.72,
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'C++ Mastery',
                    progress: 0.45,
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'Hybrid Cloud',
                    progress: 0.20,
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'Cloud Architecture',
                    progress: 0.88,
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'Application Operations',
                    progress: 0.15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItemFull extends StatelessWidget {
  const _ProgressItemFull({
    required this.title,
    required this.progress,
  });

  final String title;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium_outlined, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF243047),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso: ${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
