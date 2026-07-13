import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../services/auth_session.dart';
import '../services/badges_api.dart';
import '../services/consultor_api.dart';
import '../widgets/badge_artwork.dart';
import '../utils/avatar_image.dart';
import '../l10n/app_localizations.dart';
import 'badges_screen.dart';

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
  List<BackendBadge> _ownedBadges = const [];

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

      final competencies = _buildCompetencies(profile, context);

      List<BackendBadge> ownedBadges = const [];
      if (accountId != null) {
        try {
          ownedBadges = await BadgesApi.instance.fetchVitrine(accountId: accountId);
        } catch (_) {}
      }

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
        _ownedBadges = ownedBadges;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = AppLocalizations.of(context)!.profileLoadError;
      });
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _loadFuture = _loadProfile();
    });
    await _loadFuture;
  }

  List<_CompetencyData> _buildCompetencies(BackendProfile profile, BuildContext context) {
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
        final subtitle = AppLocalizations.of(context)!.badgesCount(stat.badges, stat.points);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF243047)),
        ),
        title: Text(
          AppLocalizations.of(context)!.profileTitle,
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
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                        final avatarProvider = avatarImageProvider(_avatar);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  backgroundImage: avatarProvider,
                                  child: avatarProvider == null
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
                                        _name.isEmpty ? AppLocalizations.of(context)!.noName : _name,
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
                                      if (_joined.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            AppLocalizations.of(context)!.memberSince(_joined),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ),
                                      if (_location.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            _location,
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
                                    title: AppLocalizations.of(context)!.pointsLabel,
                                    value: '${_points ?? 0}',
                                    subtitle: '',
                                    icon: Icons.emoji_events_outlined,
                                    iconColor: const Color(0xFF1A90F0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _MetricInfoCard(
                                    title: AppLocalizations.of(context)!.rankingLabel,
                                    value: _ranking == null ? '-' : '#${_ranking!}',
                                    subtitle: '',
                                    icon: Icons.leaderboard_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                  ),
                                ),
                                _MetricInfoCard(
                                  title: AppLocalizations.of(context)!.badgesLabel,
                                  value: '${_badges ?? 0}',
                                  subtitle: '',
                                  icon: Icons.workspace_premium_outlined,
                                  iconColor: const Color(0xFF39C65A),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _CompetenciesCard(items: _competencies),
                          if (_ownedBadges.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _BadgeShowcaseCard(badges: _ownedBadges),
                          ],
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

class _BadgeShowcaseCard extends StatelessWidget {
  const _BadgeShowcaseCard({required this.badges});

  final List<BackendBadge> badges;

  Color _frameColor(String? levelKey) {
    switch (levelKey?.toLowerCase()) {
      case 'badge_level_junior':
        return const Color(0xFFD67F45);
      case 'badge_level_intermediate':
        return const Color(0xFFBFC4CD);
      case 'badge_level_senior':
        return const Color(0xFFF0C64A);
      case 'badge_level_specialist':
        return const Color(0xFF9B6CF2);
      case 'badge_level_knowledge_lead':
        return const Color(0xFF39C65A);
      default:
        return const Color(0xFF1A90F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.badgesShowcase,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF243047),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final color = _frameColor(badge.levelKey);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BadgeLiveDetailScreen(
                            badge: BadgeData(
                              id: badge.id,
                              title: badge.title,
                              level: badge.level,
                              points: badge.points,
                              date: badge.date ?? '-',
                              badgeImage: badge.badgeImage,
                              frameColor: color,
                              iconBackground: color.withOpacity(0.2),
                              shape: BoxShape.circle,
                              isOwned: true,
                              isSpecial: badge.levelKey == null ||
                                  badge.levelKey!.isEmpty ||
                                  badge.levelKey == 'special',
                              levelKey: badge.levelKey,
                              stateId: badge.stateId,
                              state: null,
                              requestId: badge.requestId,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: BadgeArtwork(
                            size: 60,
                            frameColor: color,
                            backgroundColor: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                            borderWidth: 0,
                            iconSize: 28,
                            badgeImage: badge.badgeImage,
                            levelKey: badge.levelKey,
                            title: badge.title,
                            subtitle: badge.level,
                            isSpecial: badge.levelKey == null ||
                                badge.levelKey!.isEmpty ||
                                badge.levelKey == 'special',
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 72,
                          child: Text(
                            badge.area ?? badge.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF243047),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.topCompetencies,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243047),
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              AppLocalizations.of(context)!.noDataAvailable,
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243047),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
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
