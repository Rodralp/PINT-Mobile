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
                    subtitle: 'Especialista',
                    status: 'reprovado',
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'LowCode (Outsystems)',
                    subtitle: 'Sénior',
                    status: 'em_validacao',
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'LowCode (Outsystems)',
                    subtitle: 'Intermédio',
                    status: 'em_progresso',
                  ),
                  SizedBox(height: 14),
                  _ProgressItemFull(
                    title: 'C++ Mastery',
                    subtitle: 'Especialista',
                    status: 'aprovado',
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
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'aprovado':
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.green;
        break;
      case 'reprovado':
        statusIcon = Icons.report_problem_outlined;
        statusColor = Colors.red;
        break;
      case 'em_validacao':
        statusIcon = Icons.search;
        statusColor = Colors.orange;
        break;
      case 'em_progresso':
      default:
        statusIcon = Icons.access_time;
        statusColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF243047),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
        ],
      ),
    );
  }
}
