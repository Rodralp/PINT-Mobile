import 'package:flutter/material.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE0E6F0)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 30),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Catálogo de Badges Completo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[500], size: 30),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E6F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[500], size: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pesquisar badges',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _toolbarButton(Icons.filter_alt_outlined),
                    const SizedBox(width: 12),
                    _toolbarButton(Icons.tune_rounded),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 16.0;
                    final itemWidth = (constraints.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        _BadgeCard(
                          width: itemWidth,
                          iconBackground: const Color(0xFFFFE1C9),
                          frameColor: const Color(0xFFD67F45),
                          title: 'LowCode (Outsystems)',
                          level: 'Júnior',
                          points: '100 pontos',
                          date: '12 Jan 2026',
                          statusColor: const Color(0xFF20D43C),
                          statusIcon: Icons.check_rounded,
                        ),
                        _BadgeCard(
                          width: itemWidth,
                          iconBackground: const Color(0xFFDCC4FF),
                          frameColor: const Color(0xFF9B6CF2),
                          title: 'C++ Mastery',
                          level: 'Especialista',
                          points: '250 pontos',
                          date: '12 Jan 2026',
                          statusColor: const Color(0xFF20D43C),
                          statusIcon: Icons.check_rounded,
                        ),
                        _BadgeCard(
                          width: itemWidth,
                          iconBackground: const Color(0xFFFFE7E7),
                          frameColor: const Color(0xFFF0A7BF),
                          title: 'LowCode (Outsystems)',
                          level: 'Sénior',
                          points: '200 pontos',
                          date: '12 Jan 2026',
                          statusColor: const Color(0xFFFF3B30),
                          statusIcon: Icons.warning_amber_rounded,
                        ),
                        _BadgeCard(
                          width: itemWidth,
                          iconBackground: const Color(0xFFFFF1CB),
                          frameColor: const Color(0xFFF0C64A),
                          title: 'C++ Mastery',
                          level: 'Especialista',
                          points: '300 pontos',
                          date: '12 Jan 2026',
                          statusColor: const Color(0xFFF7B500),
                          statusIcon: Icons.manage_search_outlined,
                        ),
                        _BadgeCard(
                          width: itemWidth,
                          iconBackground: const Color(0xFFF0F0F0),
                          frameColor: const Color(0xFFBFC4CD),
                          title: 'Cloud Architecture',
                          level: 'Intermédio',
                          points: '150 pontos',
                          date: '12 Jan 2026',
                          statusColor: const Color(0xFFF7B500),
                          statusIcon: Icons.manage_search_outlined,
                        ),
                        _BadgeCard(
                          width: itemWidth,
                          iconBackground: const Color(0xFFFFE1C9),
                          frameColor: const Color(0xFFD67F45),
                          title: 'Cloud Architecture',
                          level: 'Júnior',
                          points: '100 pontos',
                          date: '12 Jan 2026',
                          statusColor: const Color(0xFFF7B500),
                          statusIcon: Icons.manage_search_outlined,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon) {
    return Container(
      width: 66,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 30),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.width,
    required this.iconBackground,
    required this.frameColor,
    required this.title,
    required this.level,
    required this.points,
    required this.date,
    required this.statusColor,
    required this.statusIcon,
  });

  final double width;
  final Color iconBackground;
  final Color frameColor;
  final String title;
  final String level;
  final String points;
  final String date;
  final Color statusColor;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: frameColor.withOpacity(0.42), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: iconBackground.withOpacity(0.24),
              shape: BoxShape.circle,
              border: Border.all(color: frameColor, width: 10),
            ),
            child: Icon(Icons.workspace_premium_outlined, size: 42, color: frameColor),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            level,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  points,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_outlined, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: statusColor, width: 3),
              ),
              child: Icon(statusIcon, color: statusColor, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}