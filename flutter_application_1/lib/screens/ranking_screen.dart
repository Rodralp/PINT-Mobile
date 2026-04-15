import 'package:flutter/material.dart';

import 'app_shell_screen.dart';
import 'change_password_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_top_bar.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopBar(
                  padding: EdgeInsets.zero,
                  onSettingsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
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
                ),
                const SizedBox(height: 26),
                const Text(
                  'Ranking de Consultores',
                  style: TextStyle(
                    fontSize: 46 / 2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Todas as Service Lines',
                  style: TextStyle(fontSize: 20, color: Color(0xFF64748B)),
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
                            Icon(
                              Icons.search,
                              color: Colors.grey[500],
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pesquisar consultores',
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
                    _toolButton(icon: Icons.filter_alt_outlined),
                    const SizedBox(width: 12),
                    _toolButton(icon: Icons.tune_rounded),
                  ],
                ),
                const SizedBox(height: 18),
                const _RankingCard(
                  rank: 1,
                  name: 'João Gomes',
                  email: 'joaogomes1234@gmail.pt',
                  points: 2450,
                  badges: 12,
                  avatarLetter: 'J',
                ),
                const SizedBox(height: 10),
                const _RankingCard(
                  rank: 2,
                  name: 'Maria Santos',
                  email: 'maria.santos@gmail.pt',
                  points: 2200,
                  badges: 10,
                  avatarLetter: 'M',
                ),
                const SizedBox(height: 10),
                const _RankingCard(
                  rank: 3,
                  name: 'Pedro Mendes',
                  email: 'pedro.mendes@softinsa.pt',
                  points: 1950,
                  badges: 9,
                  avatarLetter: 'P',
                ),
                const SizedBox(height: 10),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE3EC), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 56, child: Center(child: _rankBadge(rank))),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFD1D5DB),
            child: Text(
              avatarLetter,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'Pontos',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    SizedBox(width: 24),
                    Text(
                      'Badges',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1980E6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Text(
                      '$badges',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1980E6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge(int rank) {
    if (rank == 1) {
      return const Icon(Icons.emoji_events, size: 40, color: Color(0xFFF5B301));
    }
    if (rank == 2) {
      return const Icon(Icons.emoji_events, size: 40, color: Color(0xFFB8BDC7));
    }
    if (rank == 3) {
      return const Icon(Icons.emoji_events, size: 40, color: Color(0xFFC4742F));
    }
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF2F4F8),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}
