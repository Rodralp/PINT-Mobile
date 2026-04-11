import 'package:flutter/material.dart';

import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';

class BadgeRequestScreen extends StatelessWidget {
  const BadgeRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsMenuScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, size: 32),
                  ),
                  Image.asset(
                    'assets/images/softinsa.png',
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsFullScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_none, size: 32),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Lista de pedidos',
                      style: TextStyle(fontSize: 44 / 2, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Text(
                      'Pedidos de Badges',
                      style: TextStyle(
                        fontSize: 48 / 2,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF243047),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: const [
                        Text(
                          'Filtrar por:',
                          style: TextStyle(fontSize: 17, color: Color(0xFF64748B)),
                        ),
                        SizedBox(width: 14),
                        _FilterChipPill(
                          label: 'Aprovado',
                          backgroundColor: Color(0xFFC9F0DE),
                          textColor: Color(0xFF05603A),
                        ),
                        SizedBox(width: 10),
                        _FilterChipPill(
                          label: 'Pendente',
                          backgroundColor: Color(0xFFF7E8BF),
                          textColor: Color(0xFF9A5C09),
                        ),
                        SizedBox(width: 10),
                        _FilterChipPill(
                          label: 'Rejeitado',
                          backgroundColor: Color(0xFFF5D8D8),
                          textColor: Color(0xFFA32424),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 14),
                  const _RequestCard(
                    title: 'UX/UI Design',
                    level: 'Especialista',
                    date: '05/12/2025',
                    status: 'Pendente',
                    statusBackgroundColor: Color(0xFFF7E8BF),
                    statusTextColor: Color(0xFF9A5C09),
                  ),
                  const SizedBox(height: 14),
                  const _RequestCard(
                    title: 'Data Analytics',
                    level: 'Intermédio',
                    date: '04/12/2025',
                    status: 'Rejeitado',
                    statusBackgroundColor: Color(0xFFF5D8D8),
                    statusTextColor: Color(0xFFA32424),
                  ),
                  const SizedBox(height: 14),
                  const _RequestCard(
                    title: 'Cloud Architecture',
                    level: 'Sénior',
                    date: '03/12/2025',
                    status: 'Aprovado',
                    statusBackgroundColor: Color(0xFFC9F0DE),
                    statusTextColor: Color(0xFF05603A),
                  ),
                  const SizedBox(height: 14),
                  const _RequestCard(
                    title: 'LowCode (Outsystems)',
                    level: 'Júnior',
                    date: '02/12/2025',
                    status: 'Pendente',
                    statusBackgroundColor: Color(0xFFF7E8BF),
                    statusTextColor: Color(0xFF9A5C09),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 17,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.level,
    required this.date,
    required this.status,
    required this.statusBackgroundColor,
    required this.statusTextColor,
  });

  final String title;
  final String level;
  final String date;
  final String status;
  final Color statusBackgroundColor;
  final Color statusTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF243047),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: statusBackgroundColor,
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 17,
                    color: statusTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Data: ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[900],
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(100, 56),
                  side: const BorderSide(color: Color(0xFF1F2937), width: 2.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ver',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
