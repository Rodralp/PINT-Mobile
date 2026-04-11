import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/achievement_center.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  static const String firstLoginPreferencesDoneKey =
      'first_login_preferences_done';

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final List<_PreferenceArea> _areas = [
    _PreferenceArea(
      title: 'LowCode (Outsystems)',
      subtitle: 'Desenvolvimento de aplicações com plataformas low-code',
      icon: Icons.laptop,
      color: Color(0xFF8A2BE2),
      selected: false,
    ),
    _PreferenceArea(
      title: 'DevSecOps & IT Automation',
      subtitle: 'Automação, segurança e práticas DevOps',
      icon: Icons.build,
      color: Color(0xFFFF7A00),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Sourcing & Talent Management',
      subtitle: 'Gestão de talento e recrutamento',
      icon: Icons.groups,
      color: Color(0xFF3B82F6),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Cloud & Infrastructure',
      subtitle: 'Arquitetura e infraestrutura cloud',
      icon: Icons.cloud,
      color: Color(0xFF06B6D4),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Data & Analytics',
      subtitle: 'Análise de dados e business intelligence',
      icon: Icons.bar_chart,
      color: Color(0xFF22C55E),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Cybersecurity',
      subtitle: 'Segurança da informação e proteção de dados',
      icon: Icons.lock,
      color: Color(0xFFFF2D3B),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Agile & Project Management',
      subtitle: 'Metodologias ágeis e gestão de projetos',
      icon: Icons.assignment,
      color: Color(0xFFEC4899),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Frontend Development',
      subtitle: 'Desenvolvimento de interfaces e experiência do utilizador',
      icon: Icons.palette,
      color: Color(0xFF6366F1),
      selected: false,
    ),
    _PreferenceArea(
      title: 'Backend Development',
      subtitle: 'Desenvolvimento de APIs e serviços',
      icon: Icons.settings,
      color: Color(0xFFEAB308),
      selected: false,
    ),
  ];

  bool _saving = false;

  int get _selectedCount => _areas.where((area) => area.selected).length;

  Future<void> _saveAndContinue() async {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma área de interesse.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesScreen.firstLoginPreferencesDoneKey, true);

    AchievementCenter.instance.unlock(
      const AchievementUnlock(
        id: 'welcome-achievement',
        title: 'Bem-vindo a Bordo',
        description:
            'Bem-vindo a plataforma de badges da Softinsa. Esta conquista celebra o seu primeiro login e o inicio da sua jornada.',
        points: 50,
        badgesCount: 1,
        imageAsset: 'assets/images/welcome.png',
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, '/app');
  }

  void _resetSelections() {
    setState(() {
      for (final area in _areas) {
        area.selected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF1A90F0), width: 1.5),
                    ),
                    child: const Icon(Icons.settings_outlined, size: 24),
                  ),
                  Image.asset(
                    'assets/images/softinsa.png',
                    width: 106,
                    fit: BoxFit.contain,
                  ),
                  Row(
                    children: const [
                      Icon(Icons.notifications_none, size: 26),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Pesquisar área',
                  hintStyle:
                      const TextStyle(fontSize: 16, color: Color(0xFF98A2B3)),
                  prefixIcon:
                      const Icon(Icons.search, size: 24, color: Color(0xFF98A2B3)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFBFC6D1), width: 1.3),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFBFC6D1), width: 1.3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 8),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFC6D1), width: 1.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_alt_outlined,
                        size: 24, color: Color(0xFF475569)),
                    SizedBox(width: 8),
                    Text(
                      'Filtrar pesquisa',
                      style: TextStyle(fontSize: 16, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFCCD4E0)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _areas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final area = _areas[index];
                  return _PreferenceCard(
                    area: area,
                    onTap: () {
                      setState(() {
                        area.selected = !area.selected;
                      });
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _resetSelections,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar Alterações',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A90F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Salvar Alterações',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: 2,
          onDestinationSelected: (_) {},
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEAF2FF),
          height: 74,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.workspace_premium_outlined), label: 'Badges'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Jornada'),
            NavigationDestination(icon: Icon(Icons.history_outlined), label: 'Pedidos'),
            NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
          ],
        ),
      ),
    );
  }
}

class _PreferenceArea {
  _PreferenceArea({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  bool selected;
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.area,
    required this.onTap,
  });

  final _PreferenceArea area;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD3D9E3), width: 1.3),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: area.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(area.icon, color: Colors.white, size: 27),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    area.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667085),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: area.selected ? const Color(0xFF1A90F0) : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color:
                      area.selected ? const Color(0xFF1A90F0) : const Color(0xFFC5CCD7),
                  width: 1.7,
                ),
              ),
              child: area.selected
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
