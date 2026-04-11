import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Perfil',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5D8DD),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.person, size: 76, color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'João Gomes',
                            style: TextStyle(
                              fontSize: 48 / 2,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF121A2A),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Row(
                            children: [
                              Icon(Icons.mail_outline, size: 30),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'joaogomes1234@gmail.com',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 30),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Membro desde 3/12/2025',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _iconActionButton(
                          icon: Icons.remove_red_eye_outlined,
                          color: const Color(0xFF1A90F0),
                        ),
                        const SizedBox(height: 12),
                        _iconActionButton(
                          icon: Icons.edit_outlined,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: const [
                    _MetricInfoCard(
                      title: 'Total de Pontos',
                      value: '1234',
                      subtitle: '150 concluídos',
                      icon: Icons.task_alt,
                      iconColor: Color(0xFF39D98A),
                    ),
                    SizedBox(width: 14),
                    _MetricInfoCard(
                      title: 'Ranking',
                      value: '#15',
                      subtitle: '+3 posições este mês',
                      icon: Icons.leaderboard_rounded,
                      iconColor: Color(0xFFF7B500),
                    ),
                    SizedBox(width: 14),
                    _MetricInfoCard(
                      title: 'Badges',
                      value: '12',
                      subtitle: '2 este mês',
                      icon: Icons.workspace_premium_outlined,
                      iconColor: Color(0xFF9B6CF2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _CompetenciesCard(),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _RequirementsCard(),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconActionButton({required IconData icon, required Color color}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}

class _MetricInfoCard extends StatelessWidget {
  const _MetricInfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 304,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E1EC), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 48),
              const SizedBox(width: 14),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 66 / 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetenciesCard extends StatelessWidget {
  const _CompetenciesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E1EC), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Maiores Competências',
            style: TextStyle(
              fontSize: 24 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          _CompetencyProgress(
            title: 'Sourcing & Talent Management',
            subtitle: 'Área Completada',
            value: 1,
            color: Color(0xFF39C65A),
          ),
          Divider(height: 22, color: Color(0xFFE4EAF2)),
          _CompetencyProgress(
            title: 'C++ Mastery',
            subtitle: '4 de 5 badges obtidas',
            value: 0.8,
            color: Color(0xFF1A90F0),
          ),
          Divider(height: 22, color: Color(0xFFE4EAF2)),
          _CompetencyProgress(
            title: 'Hybrid Cloud',
            subtitle: '1 de 5 badges obtidas',
            value: 0.2,
            color: Color(0xFF1A90F0),
          ),
        ],
      ),
    );
  }
}

class _CompetencyProgress extends StatelessWidget {
  const _CompetencyProgress({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
  });

  final String title;
  final String subtitle;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF243047),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value,
            backgroundColor: const Color(0xFFE2E5EA),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E1EC), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requisitos',
            style: TextStyle(
              fontSize: 24 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            4,
            (index) => const _RequirementItem(),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFEFE3FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFF9333EA),
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LowCode (Outsystems)',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF243047),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Especialista',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '+150 pts',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF7E22CE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFE4EAF2)),
        const SizedBox(height: 14),
      ],
    );
  }
}
