import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../services/auth_session.dart';
import '../services/consultor_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<void> _loadFuture;
  String? _loadError;

  String _name = '';
  String _email = '';
  String _location = '';
  String _joined = '';
  String _avatar = '';
  int? _points;
  int? _ranking;
  int? _badges;

  List<_CompetencyData> _competencies = const [];
  List<_RequirementData> _requirements = const [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final accountId = await AuthSession.getAccountId();
      final profile = await ConsultorApi.instance.fetchProfile(
        accountId: accountId,
      );

      final storedName = await AuthSession.getAccountName() ?? '';
      final storedEmail = await AuthSession.getAccountEmail() ?? '';

      final competencies = _buildCompetencies(profile);
      final requirements = _buildRequirements(profile);

      if (!mounted) {
        return;
      }

      setState(() {
        _name = profile.name.isNotEmpty ? profile.name : storedName;
        _email = profile.email.isNotEmpty ? profile.email : storedEmail;
        _location = profile.location;
        _joined = profile.joined;
        _avatar = profile.avatar;
        _points = profile.points;
        _ranking = profile.ranking;
        _badges = profile.badges;
        _competencies = competencies;
        _requirements = requirements;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = 'Nao foi possivel carregar a base de dados';
      });
    }
  }

  List<_CompetencyData> _buildCompetencies(BackendProfile profile) {
    if (profile.serviceLineStats.isNotEmpty) {
      final maxBadges = math.max(
        1,
        profile.serviceLineStats
            .map((stat) => stat.badges)
            .fold<int>(0, math.max),
      );
      final colors = [
        const Color(0xFF39C65A),
        const Color(0xFF1A90F0),
        const Color(0xFF9333EA),
      ];

      return profile.serviceLineStats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        final value = stat.badges / maxBadges;
        final subtitle = '${stat.badges} badges · ${stat.points} pontos';
        return _CompetencyData(
          title: stat.serviceLine,
          subtitle: subtitle,
          value: value.clamp(0, 1),
          color: colors[index % colors.length],
        );
      }).toList(growable: false);
    }

    if (profile.skillsItems.isNotEmpty) {
      return profile.skillsItems.map((item) {
        return _CompetencyData(
          title: item.title,
          subtitle: item.subtitle,
          value: 1,
          color: const Color(0xFF1A90F0),
        );
      }).toList(growable: false);
    }

    return const [];
  }

  List<_RequirementData> _buildRequirements(BackendProfile profile) {
    if (profile.certificationsItems.isEmpty) {
      return const [];
    }

    return profile.certificationsItems.map((item) {
      return _RequirementData(
        title: item.title,
        level: item.subtitle,
        points: null,
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _name.isEmpty &&
                _competencies.isEmpty &&
                _requirements.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_loadError != null) {
              return Center(
                child: Text(
                  _loadError!,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
              );
            }

            return SingleChildScrollView(
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
                          child: _avatar.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _avatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.person, size: 76, color: Colors.white),
                                  ),
                                )
                              : const Icon(Icons.person, size: 76, color: Colors.white),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name.isEmpty ? '-' : _name,
                                style: const TextStyle(
                                  fontSize: 48 / 2,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF121A2A),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.mail_outline, size: 30),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _email.isEmpty ? '-' : _email,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 30),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _location.isEmpty ? '-' : _location,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 30),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _joined.isEmpty ? '-' : 'Membro desde $_joined',
                                      style: const TextStyle(fontSize: 17),
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
                      children: [
                        _MetricInfoCard(
                          title: 'Total de Pontos',
                          value: _points?.toString() ?? '-',
                          subtitle: '',
                          icon: Icons.task_alt,
                          iconColor: const Color(0xFF39D98A),
                        ),
                        const SizedBox(width: 14),
                        _MetricInfoCard(
                          title: 'Ranking',
                          value: _ranking == null ? '-' : '#${_ranking!}',
                          subtitle: '',
                          icon: Icons.leaderboard_rounded,
                          iconColor: const Color(0xFFF7B500),
                        ),
                        const SizedBox(width: 14),
                        _MetricInfoCard(
                          title: 'Badges',
                          value: _badges?.toString() ?? '-',
                          subtitle: '',
                          icon: Icons.workspace_premium_outlined,
                          iconColor: const Color(0xFF9B6CF2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _CompetenciesCard(items: _competencies),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _RequirementsCard(items: _requirements),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            );
          },
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

class _CompetencyData {
  const _CompetencyData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
  });

  final String title;
  final String subtitle;
  final double value;
  final Color color;
}

class _RequirementData {
  const _RequirementData({
    required this.title,
    required this.level,
    required this.points,
  });

  final String title;
  final String level;
  final int? points;
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
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompetenciesCard extends StatelessWidget {
  const _CompetenciesCard({required this.items});

  final List<_CompetencyData> items;

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
        children: [
          const Text(
            'Maiores Competências',
            style: TextStyle(
              fontSize: 24 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text(
              'Sem dados disponíveis.',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            )
          else
            ...items.expand(
              (item) => [
                _CompetencyProgress(
                  title: item.title,
                  subtitle: item.subtitle,
                  value: item.value,
                  color: item.color,
                ),
                const Divider(height: 22, color: Color(0xFFE4EAF2)),
              ],
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
  const _RequirementsCard({required this.items});

  final List<_RequirementData> items;

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
          if (items.isEmpty)
            const Text(
              'Sem dados disponíveis.',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            )
          else
            ...items.map(_RequirementItem.new),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem(this.data);

  final _RequirementData data;

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
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF243047),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.level.isEmpty ? '-' : data.level,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (data.points != null)
              Text(
                '+${data.points} pts',
                style: const TextStyle(
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
