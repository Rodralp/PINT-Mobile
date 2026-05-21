import 'package:flutter/material.dart';

import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import 'messages_screen.dart';
import '../widgets/app_top_bar.dart';

enum _RequestStatus { approved, pending, rejected }

class _RequestData {
  const _RequestData({
    required this.title,
    required this.level,
    required this.date,
    required this.status,
  });

  final String title;
  final String level;
  final String date;
  final _RequestStatus status;
}

const List<_RequestData> _allRequests = [
  _RequestData(
    title: 'UX/UI Design',
    level: 'Especialista',
    date: '05/12/2025',
    status: _RequestStatus.pending,
  ),
  _RequestData(
    title: 'Data Analytics',
    level: 'Intermédio',
    date: '04/12/2025',
    status: _RequestStatus.rejected,
  ),
  _RequestData(
    title: 'Cloud Architecture',
    level: 'Sénior',
    date: '03/12/2025',
    status: _RequestStatus.approved,
  ),
  _RequestData(
    title: 'LowCode (Outsystems)',
    level: 'Júnior',
    date: '02/12/2025',
    status: _RequestStatus.pending,
  ),
];

extension on _RequestStatus {
  String get label {
    switch (this) {
      case _RequestStatus.approved:
        return 'Aprovado';
      case _RequestStatus.pending:
        return 'Pendente';
      case _RequestStatus.rejected:
        return 'Rejeitado';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case _RequestStatus.approved:
        return const Color(0xFFC9F0DE);
      case _RequestStatus.pending:
        return const Color(0xFFF7E8BF);
      case _RequestStatus.rejected:
        return const Color(0xFFF5D8D8);
    }
  }

  Color get textColor {
    switch (this) {
      case _RequestStatus.approved:
        return const Color(0xFF05603A);
      case _RequestStatus.pending:
        return const Color(0xFF9A5C09);
      case _RequestStatus.rejected:
        return const Color(0xFFA32424);
    }
  }
}

class BadgeRequestScreen extends StatefulWidget {
  const BadgeRequestScreen({super.key});

  @override
  State<BadgeRequestScreen> createState() => _BadgeRequestScreenState();
}

class _BadgeRequestScreenState extends State<BadgeRequestScreen> {
  final Set<_RequestStatus> _activeStatuses = Set<_RequestStatus>.from(
    _RequestStatus.values,
  );

  List<_RequestData> get _filteredRequests {
    return _allRequests
        .where((request) => _activeStatuses.contains(request.status))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              onSettingsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsMenuScreen(),
                  ),
                );
              },
              onNotificationsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsFullScreen(),
                  ),
                );
              },
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              onMessagesTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessagesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Text(
                      'Lista de pedidos',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Text(
                      'Pedidos de Badges',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF243047),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrar por:',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _RequestStatus.values
                              .map(
                                (status) => _FilterChipPill(
                                  label: status.label,
                                  backgroundColor: status.backgroundColor,
                                  textColor: status.textColor,
                                  selected: _activeStatuses.contains(status),
                                  onTap: () {
                                    setState(() {
                                      if (_activeStatuses.contains(status)) {
                                        _activeStatuses.remove(status);
                                      } else {
                                        _activeStatuses.add(status);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),
                  ..._filteredRequests.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key == _filteredRequests.length - 1
                            ? 0
                            : 10,
                      ),
                      child: _RequestCard(request: entry.value),
                    ),
                  ),
                  const SizedBox(height: 14),
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const inactiveBackgroundColor = Color(0xFFF1F5F9);
    const inactiveTextColor = Color(0xFF64748B);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? backgroundColor : inactiveBackgroundColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: selected ? textColor : inactiveTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final _RequestData request;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
                      request.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF243047),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.level,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: request.status.backgroundColor,
                ),
                child: Text(
                  request.status.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: request.status.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Data: ',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
              ),
              Text(
                request.date,
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(82, 44),
                  side: const BorderSide(color: Color(0xFF1F2937), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ver',
                  style: TextStyle(
                    fontSize: 17,
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
