import 'package:flutter/material.dart';

import 'app_shell_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import 'messages_screen.dart';
import '../widgets/app_top_bar.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ranking de Consultores',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Todas as Service Lines',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E6F0)),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pesquisar consultores',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _toolButton(icon: Icons.filter_alt_outlined),
                  const SizedBox(width: 12),
                  _toolButton(icon: Icons.tune_rounded),
                ],
              ),
              const SizedBox(height: 24),
              const _RankingCard(
                rank: 1,
                name: 'João Gomes',
                email: 'joaogomes1234@gmail.pt',
                points: 2450,
                badges: 12,
                avatarLetter: 'J',
              ),
              const SizedBox(height: 12),
              const _RankingCard(
                rank: 2,
                name: 'Maria Santos',
                email: 'maria.santos@gmail.pt',
                points: 2200,
                badges: 10,
                avatarLetter: 'M',
              ),
              const SizedBox(height: 12),
              const _RankingCard(
                rank: 3,
                name: 'Pedro Mendes',
                email: 'pedro.mendes@softinsa.pt',
                points: 1950,
                badges: 9,
                avatarLetter: 'P',
              ),
              const SizedBox(height: 12),
              const _RankingCard(
                rank: 4,
                name: 'Ana Costa',
                email: 'ana.costa@gmail.pt',
                points: 1800,
                badges: 8,
                avatarLetter: 'A',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: NavigationBar(
        selectedIndex: 4,
        onDestinationSelected: (index) {
          if (index == 4) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AppShellScreen(initialIndex: index),
            ),
          );
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF2FF),
        height: 74,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Jornada',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'Pedidos',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
    );
  }

  Widget _toolButton({required IconData icon}) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 24, color: const Color(0xFF64748B)),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.rank,
    required this.name,
    required this.email,
    required this.points,
    required this.badges,
    required this.avatarLetter,
  });

  final int rank;
  final String name;
  final String email;
  final int points;
  final int badges;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(width: 48, child: Center(child: _rankBadge(rank))),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF1F5F9),
            child: Text(
              avatarLetter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _metricInfo('Pontos', '$points'),
                    const SizedBox(width: 24),
                    _metricInfo('Badges', '$badges'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A90F0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _rankBadge(int rank) {
    if (rank == 1) {
      return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFF5B301));
    }
    if (rank == 2) {
      return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFB8BDC7));
    }
    if (rank == 3) {
      return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFC4742F));
    }
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F5F9),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
