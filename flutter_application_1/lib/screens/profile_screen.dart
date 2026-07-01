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
  late Future<void> _loadFuture;
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

  Future<void> _refreshProfile() async {
    setState(() {
      _loadFuture = _loadProfile();
    });
    await _loadFuture;
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF243047)),
        ),
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<void>(
                    future: _loadFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (_loadError != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            _loadError!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        );
                      }

                      final initials = _name.isNotEmpty
                          ? _name.trim().characters.first.toUpperCase()
                          : '?';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFFEFF6FF),
                                backgroundImage: _avatar.isNotEmpty
                                    ? NetworkImage(_avatar)
                                    : null,
                                child: _avatar.isEmpty
                                    ? Text(
                                        initials,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A90F0),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _name.isEmpty ? 'Sem nome' : _name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _email.isEmpty ? '-' : _email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    if (_location.isNotEmpty || _joined.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          [
                                            if (_location.isNotEmpty)
                                              _location,
                                            if (_joined.isNotEmpty)
                                              'Membro desde $_joined',
                                          ].join(' · '),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _MetricInfoCard(
                                    title: 'Pontos',
                                    value: '${_points ?? 0}',
                                    subtitle: '',
                                    icon: Icons.emoji_events_outlined,
                                    iconColor: const Color(0xFF1A90F0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _MetricInfoCard(
                                    title: 'Ranking',
                                    value: _ranking == null ? '-' : '#${_ranking!}',
                                    subtitle: '',
                                    icon: Icons.leaderboard_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                  ),
                                ),
                                _MetricInfoCard(
                                  title: 'Badges',
                                  value: '${_badges ?? 0}',
                                  subtitle: '',
                                  icon: Icons.workspace_premium_outlined,
                                  iconColor: const Color(0xFF39C65A),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _CompetenciesCard(items: _competencies),
                          const SizedBox(height: 16),
                          _RequirementsCard(items: _requirements),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
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
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: iconColor),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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
