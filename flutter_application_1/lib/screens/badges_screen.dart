import 'package:flutter/material.dart';
import 'app_shell_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import '../services/auth_session.dart';
import '../services/badges_api.dart';
import '../widgets/app_top_bar.dart';

enum BadgeState { approved, warning, review }

class _BadgeData {
  const _BadgeData({
    required this.id,
    required this.title,
    required this.level,
    required this.points,
    required this.date,
    required this.frameColor,
    required this.iconBackground,
    required this.shape,
    required this.isOwned,
    this.state,
  });

  final int id;
  final String title;
  final String level;
  final int points;
  final String date;
  final Color frameColor;
  final Color iconBackground;
  final BoxShape shape;
  final bool isOwned;
  final BadgeState? state;
}

class _BadgePalette {
  const _BadgePalette({
    required this.frameColor,
    required this.iconBackground,
    required this.shape,
  });

  final Color frameColor;
  final Color iconBackground;
  final BoxShape shape;
}

_BadgePalette _paletteForLevel(String level) {
  switch (level.toLowerCase()) {
    case 'junior':
    case 'júnior':
      return const _BadgePalette(
        frameColor: Color(0xFFD67F45),
        iconBackground: Color(0xFFFFE1C9),
        shape: BoxShape.circle,
      );
    case 'intermedio':
    case 'intermédio':
      return const _BadgePalette(
        frameColor: Color(0xFFBFC4CD),
        iconBackground: Color(0xFFF0F0F0),
        shape: BoxShape.rectangle,
      );
    case 'senior':
    case 'sénior':
      return const _BadgePalette(
        frameColor: Color(0xFFF0C64A),
        iconBackground: Color(0xFFFFF1CB),
        shape: BoxShape.rectangle,
      );
    case 'especialista':
      return const _BadgePalette(
        frameColor: Color(0xFF9B6CF2),
        iconBackground: Color(0xFFDCC4FF),
        shape: BoxShape.rectangle,
      );
    case 'lider de conhecimento':
    case 'líder de conhecimento':
      return const _BadgePalette(
        frameColor: Color(0xFF39C65A),
        iconBackground: Color(0xFFDDF7E5),
        shape: BoxShape.rectangle,
      );
    default:
      return const _BadgePalette(
        frameColor: Color(0xFF1A90F0),
        iconBackground: Color(0xFFE0F0FF),
        shape: BoxShape.rectangle,
      );
  }
}

BadgeState? _badgeStateFromStatus(String? status) {
  if (status == null) {
    return null;
  }
  switch (status.toLowerCase()) {
    case 'approved':
    case 'aprovado':
      return BadgeState.approved;
    case 'warning':
    case 'reprovado':
    case 'recusado':
    case 'rejeitado':
      return BadgeState.warning;
    case 'review':
    case 'pendente':
    case 'em_analise':
    case 'em análise':
    case 'em_validacao':
    case 'em validacao':
    case 'candidatura_em_progresso':
    case 'candidatura em progresso':
      return BadgeState.review;
  }
  return null;
}

String _formatBadgeDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) {
    return '-';
  }
  final parsed = DateTime.tryParse(rawDate.trim());
  if (parsed == null) {
    return rawDate.trim();
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final month = months[parsed.month - 1];
  return '${parsed.day.toString().padLeft(2, '0')} $month ${parsed.year}';
}

_BadgeData _badgeDataFromBackend(
  BackendBadge badge, {
  bool? isOwnedOverride,
}) {
  final palette = _paletteForLevel(badge.level);
  final owned = isOwnedOverride ?? badge.owned;
  final title = (badge.area != null && badge.area!.trim().isNotEmpty)
      ? badge.area!.trim()
      : badge.title;
  return _BadgeData(
    id: badge.id,
    title: title,
    level: badge.level,
    points: badge.points,
    date: _formatBadgeDate(badge.date),
    frameColor: palette.frameColor,
    iconBackground: palette.iconBackground,
    shape: palette.shape,
    isOwned: owned,
    state: _badgeStateFromStatus(badge.stateId ?? badge.status),
  );
}

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  late final Future<List<_BadgeData>> _catalogFuture;
  late final Future<List<_BadgeData>> _myBadgesFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = _loadCatalogBadges();
    _myBadgesFuture = _loadMyBadges();
  }

  Future<List<_BadgeData>> _loadCatalogBadges() async {
    final items = await BadgesApi.instance.fetchCatalog();
    return items.map(_badgeDataFromBackend).toList(growable: false);
  }

  Future<List<_BadgeData>> _loadMyBadges() async {
    final accountId = await AuthSession.getAccountId();
    if (accountId == null) {
      return const <_BadgeData>[];
    }
    final items = await BadgesApi.instance.fetchMyBadges(accountId: accountId);
    return items
        .map((badge) => _badgeDataFromBackend(badge, isOwnedOverride: true))
        .toList(growable: false);
  }

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BadgeCatalogScreen(catalogFuture: _catalogFuture),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDDE5EF),
                      width: 1.2,
                    ),
                    color: const Color(0xFFFAFCFF),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Catálogo de Badges Completo',
                          style: TextStyle(
                            fontSize: 28 / 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[500],
                        size: 22,
                      ),
                    ],
                  ),
                ),
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
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pesquisar badges',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _toolbarButton(Icons.filter_alt_outlined),
                  const SizedBox(width: 10),
                  _toolbarButton(Icons.tune_rounded),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 16.0;
                  final itemWidth = (constraints.maxWidth - gap) / 2;
                  return FutureBuilder<List<_BadgeData>>(
                    future: _myBadgesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return _buildInlineLoading();
                      }
                      if (snapshot.hasError) {
                        return _buildInlineMessage(
                          'Nao foi possivel carregar a base de dados.',
                        );
                      }
                      final ownedBadges =
                          snapshot.data ?? const <_BadgeData>[];
                      if (ownedBadges.isEmpty) {
                        return _buildInlineMessage('Ainda nao tem badges.');
                      }
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: ownedBadges
                            .map(
                              (badge) => _OwnedBadgeCard(
                                width: itemWidth,
                                badge: badge,
                              ),
                            )
                            .toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildInlineMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 22),
    );
  }
}

class BadgeCatalogScreen extends StatelessWidget {
  const BadgeCatalogScreen({
    super.key,
    required this.catalogFuture,
  });

  final Future<List<_BadgeData>> catalogFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF243047)),
        ),
        title: const Text(
          'Catálogo de Badges',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE0E6F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey[500],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pesquisar badges',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _toolButton(Icons.filter_alt_outlined),
                const SizedBox(width: 10),
                _toolButton(Icons.tune_rounded),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 16.0;
                final itemWidth = (constraints.maxWidth - gap) / 2;
                return FutureBuilder<List<_BadgeData>>(
                  future: catalogFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Nao foi possivel carregar a base de dados.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }
                    final badges = snapshot.data ?? const <_BadgeData>[];
                    if (badges.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Catalogo vazio.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: badges
                          .map(
                            (badge) => _CatalogBadgeCard(
                              width: itemWidth,
                              badge: badge,
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 22),
    );
  }
}

class _CatalogBadgeCard extends StatelessWidget {
  const _CatalogBadgeCard({required this.width, required this.badge});

  final double width;
  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BadgeLiveDetailScreen(badge: badge),
          ),
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _badgeBackgroundColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.frameColor.withOpacity(0.28),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: badge.iconBackground.withOpacity(0.3),
                shape: badge.shape,
                border: Border.all(color: badge.frameColor, width: 6),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 40,
                color: badge.frameColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.level,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${badge.points}pt',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          badge.date,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _stateColor(badge.state),
                      width: 1.5,
                    ),
                    color: _stateColor(badge.state).withOpacity(0.08),
                  ),
                  child: Icon(
                    _stateIcon(badge.state),
                    color: _stateColor(badge.state),
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _stateIcon(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return Icons.check_rounded;
      case BadgeState.warning:
        return Icons.warning_amber_rounded;
      case BadgeState.review:
        return Icons.manage_search_outlined;
      case null:
        return Icons.radio_button_unchecked;
    }
  }

  Color _stateColor(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return const Color(0xFF16C524);
      case BadgeState.warning:
        return const Color(0xFFFF3B30);
      case BadgeState.review:
        return const Color(0xFFF7B500);
      case null:
        return const Color(0xFFC7CFD8);
    }
  }

  Color _badgeBackgroundColor() {
    switch (badge.state) {
      case BadgeState.approved:
        return const Color(0xFFF0F9F4);
      case BadgeState.warning:
        return const Color(0xFFFCF4F1);
      case BadgeState.review:
        return const Color(0xFFFFFAF0);
      case null:
        return const Color(0xFFF9FBFD);
    }
  }
}

class _OwnedBadgeCard extends StatelessWidget {
  const _OwnedBadgeCard({required this.width, required this.badge});

  final double width;
  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BadgeLiveDetailScreen(badge: badge),
          ),
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: _badgeBackgroundColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: badge.frameColor.withOpacity(0.32),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: badge.iconBackground.withOpacity(0.24),
                shape: badge.shape,
                border: Border.all(color: badge.frameColor, width: 5),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 31,
                color: badge.frameColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.level,
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${badge.points} pontos',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              badge.date,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _stateColor(badge.state),
                      width: 1.8,
                    ),
                    color: const Color(0xFFFFFFFF),
                  ),
                  child: Icon(
                    _stateIcon(badge.state),
                    color: _stateColor(badge.state),
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _stateIcon(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return Icons.check_rounded;
      case BadgeState.warning:
        return Icons.warning_amber_rounded;
      case BadgeState.review:
        return Icons.manage_search_outlined;
      case null:
        return Icons.radio_button_unchecked;
    }
  }

  Color _stateColor(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return const Color(0xFF16C524);
      case BadgeState.warning:
        return const Color(0xFFFF3B30);
      case BadgeState.review:
        return const Color(0xFFF7B500);
      case null:
        return const Color(0xFFC7CFD8);
    }
  }

  Color _badgeBackgroundColor() {
    switch (badge.state) {
      case BadgeState.approved:
        return const Color(0xFFF0F9F4);
      case BadgeState.warning:
        return const Color(0xFFFCF4F1);
      case BadgeState.review:
        return const Color(0xFFFFFAF0);
      case null:
        return const Color(0xFFF9FBFD);
    }
  }
}

class BadgeLiveDetailScreen extends StatefulWidget {
  const BadgeLiveDetailScreen({
    super.key,
    required this.badge,
    this.selectedBottomNavIndex = 1,
  });

  final _BadgeData badge;
  final int selectedBottomNavIndex;

  @override
  State<BadgeLiveDetailScreen> createState() => _BadgeLiveDetailScreenState();
}

class _BadgeLiveDetailScreenState extends State<BadgeLiveDetailScreen> {
  late final Future<List<BackendBadgeRequirement>> _requirementsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.badge.id > 0) {
      _requirementsFuture = BadgesApi.instance
          .fetchBadgeRequirements(badgeId: widget.badge.id);
    } else {
      _requirementsFuture = Future.value(const <BackendBadgeRequirement>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final statusText = _statusLabel(badge.state);
    final statusColor = _statusColor(badge.state);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF243047)),
        ),
        title: const Text(
          'Badge',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: FutureBuilder<List<BackendBadgeRequirement>>(
        future: _requirementsFuture,
        builder: (context, snapshot) {
          final requirements = snapshot.data ?? const <BackendBadgeRequirement>[];
          final hasError = snapshot.hasError;
          final errorText = snapshot.error?.toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD9E2EC),
                      width: 1.6,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: badge.iconBackground.withOpacity(0.35),
                          shape: badge.shape,
                          border: Border.all(
                            color: badge.frameColor,
                            width: 10,
                          ),
                        ),
                        child: Icon(
                          Icons.workspace_premium_outlined,
                          size: 74,
                          color: badge.frameColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF243047),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nível ${badge.level}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF243047),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _metaItem(Icons.schedule, 'Expira ${badge.date}'),
                          _metaItem(
                            Icons.emoji_events_outlined,
                            '${badge.points} pontos',
                          ),
                          _metaItem(
                            Icons.description_outlined,
                            '${requirements.length} requisitos',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statusColor,
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timelapse,
                              color: statusColor,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFD9E2EC),
                      width: 1.6,
                    ),
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
                      if (snapshot.connectionState != ConnectionState.done)
                        const Center(child: CircularProgressIndicator())
                      else if (hasError)
                        const Text(
                          'Nao foi possivel carregar a base de dados.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        )
                      else if (requirements.isEmpty)
                        const Text(
                          'Sem requisitos associados.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        )
                      else
                        ...requirements.asMap().entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.value.text,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.visibility,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: widget.selectedBottomNavIndex,
          onDestinationSelected: (index) {
            if (index == widget.selectedBottomNavIndex) {
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
      ),
    );
  }

  String _statusLabel(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return 'Aprovado';
      case BadgeState.warning:
        return 'Rejeitado';
      case BadgeState.review:
        return 'Em validacao';
      case null:
        return 'Sem estado';
    }
  }

  Color _statusColor(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return const Color(0xFF16C524);
      case BadgeState.warning:
        return const Color(0xFFFF3B30);
      case BadgeState.review:
        return const Color(0xFFF7B500);
      case null:
        return const Color(0xFFC7CFD8);
    }
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

