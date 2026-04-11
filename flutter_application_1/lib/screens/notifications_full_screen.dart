import 'package:flutter/material.dart';

class NotificationsFullScreen extends StatelessWidget {
  const NotificationsFullScreen({super.key});

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
                    'Notificações',
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
                  _NotificationItemFull(
                    message: 'Conferir requisitos enviados.',
                    date: '01 Dez 2025',
                    color: Color(0xFF39C65A),
                  ),
                  SizedBox(height: 12),
                  _NotificationItemFull(
                    message: 'Badge "C++ Mastery" expira em 30 dias.',
                    date: '29 Nov 2025',
                    color: Color(0xFFF7B500),
                  ),
                  SizedBox(height: 12),
                  _NotificationItemFull(
                    message: 'Novo badge disponível: Hybrid Cloud',
                    date: '25 Nov 2025',
                    color: Color(0xFF1A90F0),
                  ),
                  SizedBox(height: 12),
                  _NotificationItemFull(
                    message: 'Progresso atualizado em LowCode (Outsystems)',
                    date: '20 Nov 2025',
                    color: Color(0xFF39C65A),
                  ),
                  SizedBox(height: 12),
                  _NotificationItemFull(
                    message: 'Ranking atualizado - você subiu 5 posições!',
                    date: '15 Nov 2025',
                    color: Color(0xFF1A90F0),
                  ),
                  SizedBox(height: 12),
                  _NotificationItemFull(
                    message: 'Certificado aprovado para Cloud Architecture',
                    date: '10 Nov 2025',
                    color: Color(0xFF39C65A),
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

class _NotificationItemFull extends StatelessWidget {
  const _NotificationItemFull({
    required this.message,
    required this.date,
    required this.color,
  });

  final String message;
  final String date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3.5),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF243047),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.info_outline, color: color, size: 28),
        ],
      ),
    );
  }
}
