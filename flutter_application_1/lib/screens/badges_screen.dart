import 'package:flutter/material.dart';
import 'app_shell_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import '../services/auth_session.dart';
import '../services/badges_api.dart';
import 'messages_screen.dart';
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
    required this.isSpecial,
    this.levelKey,
    this.stateId,
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
  final bool isSpecial;
  final String? levelKey;
  final String? stateId;
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
  final levelKey = badge.levelKey?.trim();
  final stateId = (badge.stateId ?? badge.status)?.trim();
  final isSpecial = levelKey == null || levelKey.isEmpty || levelKey == 'special';

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
    isSpecial: isSpecial,
    levelKey: levelKey,
    stateId: stateId,
    state: _badgeStateFromStatus(stateId),
  );
}

class _FilterOption {
  const _FilterOption(this.id, this.label);

  final String id;
  final String label;
}

const String _specialBadgeType = 'special';

const Map<String, String> _badgeLevelLabels = {
  'badge_level_junior': 'Júnior',
  'badge_level_intermediate': 'Intermédio',
  'badge_level_senior': 'Sénior',
  'badge_level_specialist': 'Especialista',
  'badge_level_knowledge_lead': 'Líder de Conhecimento',
};

const Map<String, String> _badgeStateLabels = {
  'aprovado': 'Aprovado',
  'em_validacao': 'Em Validação',
  'candidatura_em_progresso': 'Candidatura em Progresso',
  'rejeitado': 'Rejeitado',
};

const List<_FilterOption> _catalogFilters = [
  _FilterOption('todos', 'Todos'),
  _FilterOption('badge_level_junior', 'Júnior'),
  _FilterOption('badge_level_intermediate', 'Intermédio'),
  _FilterOption('badge_level_senior', 'Sénior'),
  _FilterOption('badge_level_specialist', 'Especialista'),
  _FilterOption('badge_level_knowledge_lead', 'Líder de Conhecimento'),
  _FilterOption(_specialBadgeType, 'Especial'),
];

const List<_FilterOption> _myBadgesFilters = [
  _FilterOption('todos', 'Todos'),
  _FilterOption(_specialBadgeType, 'Especial'),
  _FilterOption('aprovado', 'Aprovado'),
  _FilterOption('em_validacao', 'Em Validação'),
  _FilterOption('candidatura_em_progresso', 'Candidatura em Progresso'),
  _FilterOption('rejeitado', 'Rejeitado'),
];

const List<_FilterOption> _badgeSortOptions = [
  _FilterOption('points_desc', 'Pontos (Maior para Menor)'),
  _FilterOption('points_asc', 'Pontos (Menor para Maior)'),
  _FilterOption('area_asc', 'Area (A-Z)'),
  _FilterOption('area_desc', 'Area (Z-A)'),
];

String _normalizeKey(String? value) =>
    value?.trim().toLowerCase().replaceAll(' ', '_') ?? '';

String _levelLabelForBadge(_BadgeData badge) {
  if (badge.isSpecial) {
    return 'Especial';
  }
  final key = _normalizeKey(badge.levelKey);
  return _badgeLevelLabels[key] ?? badge.level;
}

String _stateIdForBadge(_BadgeData badge) {
  final raw = _normalizeKey(badge.stateId);
  if (raw.isNotEmpty) {
    return raw;
  }
  switch (badge.state) {
    case BadgeState.approved:
      return 'aprovado';
    case BadgeState.warning:
      return 'rejeitado';
    case BadgeState.review:
      return 'em_validacao';
    case null:
      return '';
  }
}

String _stateLabelForBadge(_BadgeData badge) {
  final stateId = _stateIdForBadge(badge);
  return _badgeStateLabels[stateId] ?? 'Sem estado';
}

List<_BadgeData> _sortBadges(List<_BadgeData> badges, String sortBy) {
  final items = [...badges];
  switch (sortBy) {
    case 'points_asc':
      items.sort((a, b) => a.points.compareTo(b.points));
      break;
    case 'area_asc':
      items.sort((a, b) => a.title.compareTo(b.title));
      break;
    case 'area_desc':
      items.sort((a, b) => b.title.compareTo(a.title));
      break;
    case 'points_desc':
    default:
      items.sort((a, b) => b.points.compareTo(a.points));
      break;
  }
  return items;
}

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  late final Future<List<_BadgeData>> _catalogFuture;
  late final Future<List<_BadgeData>> _myBadgesFuture;
  final TextEditingController _myBadgesSearchController = TextEditingController();
  String _myBadgesSearchTerm = '';
  String _myBadgesFilter = 'todos';
  String _myBadgesSort = 'points_desc';

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
  void dispose() {
    _myBadgesSearchController.dispose();
    super.dispose();
  }

  List<_BadgeData> _applyMyBadgesFilters(List<_BadgeData> badges) {
    final normalizedSearch = _myBadgesSearchTerm.trim().toLowerCase();
    final filtered = badges.where((badge) {
      final matchesFilter = _myBadgesFilter == 'todos'
          || (_myBadgesFilter == _specialBadgeType
              ? badge.isSpecial
              : _stateIdForBadge(badge) == _myBadgesFilter);
      final searchMatch = normalizedSearch.isEmpty
          || badge.title.toLowerCase().contains(normalizedSearch)
          || _levelLabelForBadge(badge).toLowerCase().contains(normalizedSearch)
          || _stateLabelForBadge(badge).toLowerCase().contains(normalizedSearch);
      return matchesFilter && searchMatch;
    }).toList();

    return _sortBadges(filtered, _myBadgesSort);
  }

  void _showMyBadgesFilterSheet() {
    _showOptionsSheet(
      title: 'Filtrar badges',
      options: _myBadgesFilters,
      selectedId: _myBadgesFilter,
      onSelected: (value) {
        setState(() {
          _myBadgesFilter = value;
        });
      },
    );
  }

  void _showMyBadgesSortSheet() {
    _showOptionsSheet(
      title: 'Ordenar badges',
      options: _badgeSortOptions,
      selectedId: _myBadgesSort,
      onSelected: (value) {
        setState(() {
          _myBadgesSort = value;
        });
      },
    );
  }

  void _showOptionsSheet({
    required String title,
    required List<_FilterOption> options,
    required String selectedId,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    trailing: selectedId == option.id
                        ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(option.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        onMessagesTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessagesScreen(),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                          child: TextField(
                            controller: _myBadgesSearchController,
                            decoration: const InputDecoration(
                              hintText: 'Pesquisar badges',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _myBadgesSearchTerm = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _toolButton(Icons.filter_alt_outlined, onTap: _showMyBadgesFilterSheet),
                const SizedBox(width: 10),
                _toolButton(Icons.tune_rounded, onTap: _showMyBadgesSortSheet),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 16.0;
                final itemWidth = (constraints.maxWidth - gap) / 2;
                return FutureBuilder<List<_BadgeData>>(
                  future: _myBadgesFuture,
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
                    final ownedBadges =
                        snapshot.data ?? const <_BadgeData>[];
                    if (ownedBadges.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Ainda nao tem badges.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }
                    final visibleBadges = _applyMyBadgesFilters(ownedBadges);
                    if (visibleBadges.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Nenhum badge encontrado com os filtros escolhidos.',
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
                      children: visibleBadges
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
    );
  }

  Widget _toolButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          color: Colors.white,
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
}

class BadgeCatalogScreen extends StatefulWidget {
  const BadgeCatalogScreen({
    super.key,
    required this.catalogFuture,
  });

  final Future<List<_BadgeData>> catalogFuture;

  @override
  State<BadgeCatalogScreen> createState() => _BadgeCatalogScreenState();
}

class _BadgeCatalogScreenState extends State<BadgeCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _activeFilter = 'todos';
  String _sortBy = 'points_desc';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_BadgeData> _applyCatalogFilters(List<_BadgeData> badges) {
    final normalizedSearch = _searchTerm.trim().toLowerCase();
    final filtered = badges.where((badge) {
      final typeId = badge.isSpecial ? _specialBadgeType : _normalizeKey(badge.levelKey);
      final matchesFilter =
          _activeFilter == 'todos' || typeId == _activeFilter;
      final searchMatch = normalizedSearch.isEmpty
          || badge.title.toLowerCase().contains(normalizedSearch)
          || _levelLabelForBadge(badge).toLowerCase().contains(normalizedSearch);
      return matchesFilter && searchMatch;
    }).toList();

    return _sortBadges(filtered, _sortBy);
  }

  void _showFilterSheet() {
    _showOptionsSheet(
      title: 'Filtrar badges',
      options: _catalogFilters,
      selectedId: _activeFilter,
      onSelected: (value) {
        setState(() {
          _activeFilter = value;
        });
      },
    );
  }

  void _showSortSheet() {
    _showOptionsSheet(
      title: 'Ordenar badges',
      options: _badgeSortOptions,
      selectedId: _sortBy,
      onSelected: (value) {
        setState(() {
          _sortBy = value;
        });
      },
    );
  }

  void _showOptionsSheet({
    required String title,
    required List<_FilterOption> options,
    required String selectedId,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    trailing: selectedId == option.id
                        ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(option.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Pesquisar badges',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchTerm = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _toolButton(Icons.filter_alt_outlined, onTap: _showFilterSheet),
                const SizedBox(width: 10),
                _toolButton(Icons.tune_rounded, onTap: _showSortSheet),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 16.0;
                final itemWidth = (constraints.maxWidth - gap) / 2;
                return FutureBuilder<List<_BadgeData>>(
                  future: widget.catalogFuture,
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
                    final visibleBadges = _applyCatalogFilters(badges);
                    if (visibleBadges.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Nenhum badge encontrado com os filtros escolhidos.',
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
                      children: visibleBadges
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

  Widget _toolButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          color: Colors.white,
        ),
        child: Icon(icon, size: 22),
      ),
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
