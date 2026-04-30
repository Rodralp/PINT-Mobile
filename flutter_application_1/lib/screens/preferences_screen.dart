import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/achievement_center.dart';
import '../services/auth_api.dart';
import '../services/auth_session.dart';
import '../theme/softinsa_theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  static const String firstLoginPreferencesDoneKey = 'first_login_preferences_done';

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final List<_PreferenceArea> _areas = [
    _PreferenceArea(
      title: 'LowCode (Outsystems)',
      subtitle: 'Desenvolvimento de aplicações com plataformas low-code',
      icon: Icons.laptop,
      color: const Color(0xFF2F80ED),
    ),
    _PreferenceArea(
      title: 'DevSecOps & IT Automation',
      subtitle: 'Automação, segurança e práticas DevOps',
      icon: Icons.build_circle_outlined,
      color: const Color(0xFFEF7D32),
    ),
    _PreferenceArea(
      title: 'Sourcing & Talent Management',
      subtitle: 'Gestão de talento e recrutamento',
      icon: Icons.groups_2_outlined,
      color: const Color(0xFF8B5CF6),
    ),
    _PreferenceArea(
      title: 'Cloud & Infrastructure',
      subtitle: 'Arquitetura e infraestrutura cloud',
      icon: Icons.cloud_outlined,
      color: const Color(0xFF06B6D4),
    ),
    _PreferenceArea(
      title: 'Data & Analytics',
      subtitle: 'Análise de dados e business intelligence',
      icon: Icons.bar_chart_outlined,
      color: const Color(0xFF16A34A),
    ),
    _PreferenceArea(
      title: 'Cybersecurity',
      subtitle: 'Segurança da informação e proteção de dados',
      icon: Icons.lock_outline,
      color: const Color(0xFFDC2626),
    ),
    _PreferenceArea(
      title: 'Agile & Project Management',
      subtitle: 'Metodologias ágeis e gestão de projetos',
      icon: Icons.assignment_outlined,
      color: const Color(0xFFDB2777),
    ),
    _PreferenceArea(
      title: 'Frontend Development',
      subtitle: 'Desenvolvimento de interfaces e experiência do utilizador',
      icon: Icons.palette_outlined,
      color: const Color(0xFF4F46E5),
    ),
    _PreferenceArea(
      title: 'Backend Development',
      subtitle: 'Desenvolvimento de APIs e serviços',
      icon: Icons.settings_outlined,
      color: const Color(0xFFD4A017),
    ),
  ];

  bool _saving = false;

  int get _selectedCount => _areas.where((area) => area.selected).length;

  Future<List<int>> _resolveSelectedAreaIds(int accountId) async {
    final backendAreas = await AuthApi.instance.fetchPreferenceAreas(accountId: accountId);
    final areaIdByName = <String, int>{
      for (final area in backendAreas) area.name.trim().toLowerCase(): area.id,
    };

    final selectedIds = <int>[];
    for (final area in _areas.where((area) => area.selected)) {
      final areaId = areaIdByName[area.title.trim().toLowerCase()];
      if (areaId != null) {
        selectedIds.add(areaId);
      }
    }

    return selectedIds.toSet().toList(growable: false);
  }

  void _toggleArea(_PreferenceArea area) {
    setState(() {
      area.selected = !area.selected;
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma área de interesse.')),
      );
      return;
    }

    final accountId = await AuthSession.getAccountId();
    if (!mounted) return;

    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar a conta ativa.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final selectedAreaIds = await _resolveSelectedAreaIds(accountId);
      if (selectedAreaIds.isEmpty) {
        throw const FormatException('No matching backend areas were found.');
      }

      await AuthApi.instance.savePreferences(accountId: accountId, areaIds: selectedAreaIds);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PreferencesScreen.firstLoginPreferencesDoneKey, true);
      await AuthSession.setHasPreferences(true);

      AchievementCenter.instance.unlock(
        const AchievementUnlock(
          id: 'welcome-achievement',
          title: 'Bem-vindo a Bordo',
          description: 'Bem-vindo a plataforma de badges da Softinsa. Esta conquista celebra o seu primeiro login e o inicio da sua jornada.',
          points: 50,
          badgesCount: 1,
          imageAsset: 'assets/images/welcome.png',
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/app');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível guardar as preferências.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
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
      backgroundColor: SoftinsaColors.surfaceAlt,
      body: Container(
        decoration: const BoxDecoration(gradient: SoftinsaColors.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/softinsa.png', width: 30, fit: BoxFit.contain),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: Text(
                        '$_selectedCount selecionadas',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escolha as suas áreas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Isto ajuda a personalizar badges, conteúdos e recomendações no mobile e no web.',
                        style: TextStyle(color: Colors.white, height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving ? null : _resetSelections,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                              ),
                              child: const Text('Limpar seleção'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saving ? null : _saveAndContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: SoftinsaColors.blueDark,
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2.2),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _areas.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final area = _areas[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _saving ? null : () => _toggleArea(area),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: area.selected ? area.color : SoftinsaColors.border,
                                width: area.selected ? 1.8 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: area.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(area.icon, color: area.color),
                                    ),
                                    const Spacer(),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: area.selected ? area.color : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: area.selected ? area.color : SoftinsaColors.border,
                                        ),
                                      ),
                                      child: area.selected
                                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                          : null,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  area.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: SoftinsaColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  area.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: SoftinsaColors.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  bool selected = false;
}
