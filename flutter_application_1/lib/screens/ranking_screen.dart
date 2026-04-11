import 'package:flutter/material.dart';

import 'app_shell_screen.dart';
import 'change_password_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
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
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 84,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD8DEE9), width: 1.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 42),
                            const SizedBox(width: 12),
                            Text(
                              'Pesquisar consultor',
                              style: TextStyle(
                                fontSize: 40 / 2,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _toolButton(icon: Icons.filter_alt_outlined),
                    const SizedBox(width: 12),
                    _toolButton(icon: Icons.sort),
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
                const SizedBox(height: 14),
                const _RankingCard(
                  rank: 2,
                  name: 'Maria Santos',
                  email: 'maria.santos@gmail.pt',
                  points: 2200,
                  badges: 10,
                  avatarLetter: 'M',
                ),
                const SizedBox(height: 14),
                const _RankingCard(
                  rank: 3,
                  name: 'Pedro Mendes',
                  email: 'pedro.mendes@softinsa.pt',
                  points: 1950,
                  badges: 9,
                  avatarLetter: 'P',
                ),
                const SizedBox(height: 14),
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
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }

  Widget _toolButton({required IconData icon}) {
    return Container(
      width: 112,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8DEE9), width: 1.8),
      ),
      child: Icon(icon, size: 42),
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE3EC), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Center(child: _rankBadge(rank)),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFD1D5DB),
            child: Text(
              avatarLetter,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
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
                    fontSize: 42 / 2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      'Pontos',
                      style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
                    ),
                    SizedBox(width: 34),
                    Text(
                      'Badges',
                      style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 42 / 2,
                        color: Color(0xFF1980E6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 36),
                    Text(
                      '$badges',
                      style: const TextStyle(
                        fontSize: 42 / 2,
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
      return const Icon(Icons.emoji_events, size: 54, color: Color(0xFFF5B301));
    }
    if (rank == 2) {
      return const Icon(Icons.emoji_events, size: 54, color: Color(0xFFB8BDC7));
    }
    if (rank == 3) {
      return const Icon(Icons.emoji_events, size: 54, color: Color(0xFFC4742F));
    }
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF2F4F8),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}