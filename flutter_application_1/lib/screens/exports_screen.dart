import 'package:flutter/material.dart';

import 'app_shell_screen.dart';
import 'change_password_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';

class ExportsScreen extends StatefulWidget {
  const ExportsScreen({super.key});

  @override
  State<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends State<ExportsScreen> {
  bool _isCertificateSelected = true;

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
                const SizedBox(height: 24),
                const Text(
                  'Exportações',
                  style: TextStyle(
                    fontSize: 52 / 2,
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
                      child: _exportTypeButton(
                        label: 'Badges',
                        selected: !_isCertificateSelected,
                        onTap: () {
                          setState(() {
                            _isCertificateSelected = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _exportTypeButton(
                        label: 'Certificado',
                        selected: _isCertificateSelected,
                        onTap: () {
                          setState(() {
                            _isCertificateSelected = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 86,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFC6D2E1), width: 1.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 42),
                            const SizedBox(width: 10),
                            Text(
                              'Pesquisar badge',
                              style: TextStyle(
                                fontSize: 40 / 2,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 110,
                      height: 86,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC6D2E1), width: 1.8),
                      ),
                      child: const Icon(Icons.filter_alt_outlined, size: 44),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Selecionar Badge',
                        style: TextStyle(
                          fontSize: 42 / 2,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left, size: 36, color: Color(0xFF64748B)),
                    SizedBox(width: 2),
                    Text(
                      '1/3',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 36, color: Color(0xFF64748B)),
                  ],
                ),
                const SizedBox(height: 10),
                _badgeItem(
                  iconShape: _BadgeShape.circle,
                  color: const Color(0xFFD67F45),
                  title: 'LowCode (Outsystems)',
                  level: 'Junior',
                ),
                const SizedBox(height: 12),
                _badgeItem(
                  iconShape: _BadgeShape.shield,
                  color: const Color(0xFFA3AAB5),
                  title: 'LowCode (Outsystems)',
                  level: 'Intermédio',
                ),
                const SizedBox(height: 12),
                _badgeItem(
                  iconShape: _BadgeShape.pentagon,
                  color: const Color(0xFFF0C64A),
                  title: 'LowCode (Outsystems)',
                  level: 'Sénior',
                ),
                const SizedBox(height: 12),
                _badgeItem(
                  iconShape: _BadgeShape.hexagon,
                  color: const Color(0xFF9B6CF2),
                  title: 'LowCode (Outsystems)',
                  level: 'Especialista',
                  highlighted: true,
                ),
                const SizedBox(height: 12),
                _badgeItem(
                  iconShape: _BadgeShape.star,
                  color: const Color(0xFF39C65A),
                  title: 'LowCode (Outsystems)',
                  level: 'Líder de Conhecimento',
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

  Widget _exportTypeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF1A90F0) : const Color(0xFFC6D2E1),
            width: selected ? 3 : 1.8,
          ),
          color: selected ? const Color(0xFFEAF2FF) : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 42 / 2,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  Widget _badgeItem({
    required _BadgeShape iconShape,
    required Color color,
    required String title,
    required String level,
    bool highlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEAF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? const Color(0xFF1A90F0) : const Color(0xFFD8E1EC),
          width: highlighted ? 2.6 : 1.7,
        ),
      ),
      child: Row(
        children: [
          _shapeIcon(iconShape, color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 42 / 2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 38 / 2,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shapeIcon(_BadgeShape shape, Color color) {
    switch (shape) {
      case _BadgeShape.circle:
        return _badgeCircle(color);
      case _BadgeShape.shield:
        return _badgeShield(color);
      case _BadgeShape.pentagon:
        return _badgePentagon(color);
      case _BadgeShape.hexagon:
        return _badgeHexagon(color);
      case _BadgeShape.star:
        return _badgeStar(color);
    }
  }

  Widget _badgeCircle(Color color) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 8),
      ),
      child: _innerBadgeSymbol(color),
    );
  }

  Widget _badgeShield(Color color) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 8),
      ),
      child: _innerBadgeSymbol(color),
    );
  }

  Widget _badgePentagon(Color color) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 8),
      ),
      child: _innerBadgeSymbol(color),
    );
  }

  Widget _badgeHexagon(Color color) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 8),
      ),
      child: _innerBadgeSymbol(color),
    );
  }

  Widget _badgeStar(Color color) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 8),
      ),
      child: _innerBadgeSymbol(color),
    );
  }

  Widget _innerBadgeSymbol(Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.workspace_premium,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}

enum _BadgeShape {
  circle,
  shield,
  pentagon,
  hexagon,
  star,
}