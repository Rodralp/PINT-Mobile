import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'app_shell_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import '../services/auth_session.dart';
import '../services/badges_api.dart';
import '../services/consultor_api.dart';
import 'messages_screen.dart';
import '../widgets/badge_artwork.dart';
import '../widgets/app_top_bar.dart';

enum BadgeState { approved, warning, review, inProgress }

class BadgeData {
  const BadgeData({
    required this.id,
    required this.title,
    required this.level,
    required this.points,
    required this.date,
    required this.badgeImage,
    required this.frameColor,
    required this.iconBackground,
    required this.shape,
    required this.isOwned,
    required this.isSpecial,
    this.levelKey,
    this.stateId,
    this.state,
    this.requestId,
  });

  final int id;
  final String title;
  final String level;
  final int points;
  final String date;
  final String? badgeImage;
  final Color frameColor;
  final Color iconBackground;
  final BoxShape shape;
  final bool isOwned;
  final bool isSpecial;
  final String? levelKey;
  final String? stateId;
  final BadgeState? state;
  final int? requestId;
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
    case 'candidatura_em_progresso':
    case 'candidatura em progresso':
      return BadgeState.inProgress;
    case 'review':
    case 'pendente':
    case 'em_analise':
    case 'em análise':
    case 'em_validacao':
    case 'em validacao':
    case 'pendente-tm':
    case 'pendente-sll':
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
    'Dec',
  ];
  final month = months[parsed.month - 1];
  return '${parsed.day.toString().padLeft(2, '0')} $month ${parsed.year}';
}

BadgeData _badgeDataFromBackend(BackendBadge badge, {bool? isOwnedOverride}) {
  final palette = _paletteForLevel(badge.level);
  final stateId = (badge.stateId ?? badge.status)?.trim();
  final inferredOwned = stateId == 'aprovado' ||
      badge.status?.toLowerCase() == 'obtido' ||
      badge.owned;
  final owned = isOwnedOverride ?? inferredOwned;
  final title = (badge.area != null && badge.area!.trim().isNotEmpty)
      ? badge.area!.trim()
      : badge.title;
  final levelKey = badge.levelKey?.trim();
  final isSpecial =
      levelKey == null || levelKey.isEmpty || levelKey == 'special';

  return BadgeData(
    id: badge.id,
    title: title,
    level: badge.level,
    points: badge.points,
    date: _formatBadgeDate(badge.date),
    badgeImage: badge.badgeImage,
    frameColor: palette.frameColor,
    iconBackground: palette.iconBackground,
    shape: palette.shape,
    isOwned: owned,
    isSpecial: isSpecial,
    levelKey: levelKey,
    stateId: stateId,
    state: _badgeStateFromStatus(stateId),
    requestId: badge.requestId,
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
  'pendente-tm': 'Em Validação',
  'pendente-sll': 'Em Validação',
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

String _levelLabelForBadge(BadgeData badge) {
  if (badge.isSpecial) {
    return 'Especial';
  }
  final key = _normalizeKey(badge.levelKey);
  return _badgeLevelLabels[key] ?? badge.level;
}

String _stateIdForBadge(BadgeData badge) {
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
    case BadgeState.inProgress:
      return 'candidatura_em_progresso';
    case null:
      return '';
  }
}

String _stateLabelForBadge(BadgeData badge) {
  final stateId = _stateIdForBadge(badge);
  return _badgeStateLabels[stateId] ?? 'Sem estado';
}

List<BadgeData> _sortBadges(List<BadgeData> badges, String sortBy) {
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
  late Future<List<BadgeData>> _catalogFuture;
  late Future<List<BadgeData>> _myBadgesFuture;
  final TextEditingController _myBadgesSearchController =
  TextEditingController();
  String _myBadgesSearchTerm = '';
  String _myBadgesFilter = 'todos';
  String _myBadgesSort = 'points_desc';

  @override
  void initState() {
    super.initState();
    _catalogFuture = _loadCatalogBadges();
    _myBadgesFuture = _loadMyBadges();
  }

  Future<List<BadgeData>> _loadCatalogBadges() async {
    final items = await BadgesApi.instance.fetchCatalog();
    final catalogBadges = items.map(_badgeDataFromBackend).toList(growable: false);

    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId != null) {
        final myBadges = await BadgesApi.instance.fetchMyBadges(accountId: accountId);
        final myBadgesMap = {for (final b in myBadges) b.id: b};
        return catalogBadges.map((catalog) {
          final userBadge = myBadgesMap[catalog.id];
          if (userBadge == null) return catalog;
          final merged = _badgeDataFromBackend(userBadge);
          return BadgeData(
            id: merged.id != 0 ? merged.id : catalog.id,
            title: merged.title.isNotEmpty ? merged.title : catalog.title,
            level: merged.level.isNotEmpty ? merged.level : catalog.level,
            points: merged.points > 0 ? merged.points : catalog.points,
            date: merged.date != '-' ? merged.date : catalog.date,
            badgeImage: merged.badgeImage ?? catalog.badgeImage,
            frameColor: catalog.frameColor,
            iconBackground: catalog.iconBackground,
            shape: catalog.shape,
            isOwned: merged.isOwned,
            isSpecial: merged.isSpecial,
            levelKey: merged.levelKey ?? catalog.levelKey,
            stateId: merged.stateId ?? catalog.stateId,
            state: merged.state ?? catalog.state,
            requestId: merged.requestId ?? catalog.requestId,
          );
        }).toList(growable: false);
      }
    } catch (_) {}

    return catalogBadges;
  }

  Future<List<BadgeData>> _loadMyBadges() async {
    final accountId = await AuthSession.getAccountId();
    if (accountId == null) {
      return const <BadgeData>[];
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

  Future<void> _refreshBadges() async {
    setState(() {
      _catalogFuture = _loadCatalogBadges();
      _myBadgesFuture = _loadMyBadges();
    });
    await Future.wait([
      _catalogFuture,
      _myBadgesFuture,
    ]);
  }

  List<BadgeData> _applyMyBadgesFilters(List<BadgeData> badges) {
    final normalizedSearch = _myBadgesSearchTerm.trim().toLowerCase();
    final filtered = badges.where((badge) {
      final matchesFilter =
          _myBadgesFilter == 'todos' ||
              (_myBadgesFilter == _specialBadgeType
                  ? badge.isSpecial
                  : _stateIdForBadge(badge) == _myBadgesFilter);
      final searchMatch =
          normalizedSearch.isEmpty ||
              badge.title.toLowerCase().contains(normalizedSearch) ||
              _levelLabelForBadge(badge).toLowerCase().contains(normalizedSearch) ||
              _stateLabelForBadge(badge).toLowerCase().contains(normalizedSearch);
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
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(option.label),
                          trailing: selectedId == option.id
                              ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onSelected(option.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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
            MaterialPageRoute(builder: (context) => const SettingsMenuScreen()),
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
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        onMessagesTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBadges,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E6F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[500], size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _myBadgesSearchController,
                              decoration: const InputDecoration(
                                hintText: 'Pesquisar badges',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
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
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _toolButton(
                      icon: Icons.filter_alt_outlined,
                      label: 'Filtrar',
                      onTap: _showMyBadgesFilterSheet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _toolButton(
                      icon: Icons.tune_rounded,
                      label: 'Ordenar',
                      onTap: _showMyBadgesSortSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 16.0;
                  final maxWidth = constraints.hasBoundedWidth
                      ? constraints.maxWidth
                      : MediaQuery.of(context).size.width - 40;
                  final itemWidth = (maxWidth - gap) / 2;
                  return FutureBuilder<List<BadgeData>>(
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
                      final ownedBadges = snapshot.data ?? const <BadgeData>[];
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
                              (badge) => BadgeCard(
                            width: itemWidth,
                            badge: badge,
                            onRefresh: _refreshBadges,
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

  Widget _toolButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeCatalogScreen extends StatefulWidget {
  const BadgeCatalogScreen({super.key, required this.catalogFuture});

  final Future<List<BadgeData>> catalogFuture;

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

  List<BadgeData> _applyCatalogFilters(List<BadgeData> badges) {
    final normalizedSearch = _searchTerm.trim().toLowerCase();
    final filtered = badges.where((badge) {
      final typeId = badge.isSpecial
          ? _specialBadgeType
          : _normalizeKey(badge.levelKey);
      final matchesFilter = _activeFilter == 'todos' || typeId == _activeFilter;
      final searchMatch =
          normalizedSearch.isEmpty ||
              badge.title.toLowerCase().contains(normalizedSearch) ||
              _levelLabelForBadge(badge).toLowerCase().contains(normalizedSearch);
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
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(option.label),
                          trailing: selectedId == option.id
                              ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onSelected(option.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
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
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E6F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[500], size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Pesquisar badges',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
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
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _toolButton(
                    icon: Icons.filter_alt_outlined,
                    label: 'Filtrar',
                    onTap: _showFilterSheet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _toolButton(
                    icon: Icons.tune_rounded,
                    label: 'Ordenar',
                    onTap: _showSortSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 16.0;
                final maxWidth = constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : MediaQuery.of(context).size.width - 40;
                final itemWidth = (maxWidth - gap) / 2;
                return FutureBuilder<List<BadgeData>>(
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
                    final badges = snapshot.data ?? const <BadgeData>[];
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
                            (badge) => BadgeCard(
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

  Widget _toolButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeCard extends StatelessWidget {
  const BadgeCard({required this.width, required this.badge, this.onRefresh});

  final double width;
  final BadgeData badge;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BadgeLiveDetailScreen(badge: badge),
          ),
        ).then((_) {
          onRefresh?.call();
        });
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
              width: 92,
              height: 92,
              child: BadgeArtwork(
                size: 92,
                frameColor: badge.frameColor,
                backgroundColor: badge.iconBackground.withOpacity(0.24),
                shape: badge.shape,
                borderWidth: 5,
                iconSize: 38,
                badgeImage: badge.badgeImage,
                levelKey: badge.levelKey,
                title: badge.title,
                subtitle: badge.level,
                isSpecial: badge.isSpecial,
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
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined, size: 13),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${badge.points} pts',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined, size: 13),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              badge.date,
                              style: TextStyle(
                                fontSize: 9.5,
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
                Icon(
                  _stateIcon(badge.state),
                  color: _stateColor(badge.state),
                  size: 28,
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
      case BadgeState.inProgress:
        return Icons.timer_outlined;
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
      case BadgeState.inProgress:
        return const Color(0xFF1A90F0);
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
      case BadgeState.inProgress:
        return const Color(0xFFEFF6FF);
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

  final BadgeData badge;
  final int selectedBottomNavIndex;

  @override
  State<BadgeLiveDetailScreen> createState() => _BadgeLiveDetailScreenState();
}

class _BadgeLiveDetailScreenState extends State<BadgeLiveDetailScreen> {
  late BadgeData _badge;
  BadgeState? _previousBadgeState;
  int? _currentRequestId;
  late Future<List<Map<String, dynamic>>> _requirementsFuture;
  bool _isRequesting = false;
  String? _requestResultMessage;
  bool _requestSuccess = false;
  final Map<int, List<File>> _filesByRequirement = {};
  bool _submittingAll = false;
  bool _submitted = false;
  final Set<int> _expandedRequirements = {};
  String? _reviewerNote;
  String? _reviewerName;

  @override
  void initState() {
    super.initState();
    _badge = widget.badge;
    _previousBadgeState = _badge.state;
    _currentRequestId = _badge.requestId;
    if (_badge.id > 0 || _currentRequestId != null) {
      _requirementsFuture = Future.value(const <Map<String, dynamic>>[]);
      _loadAll();
    } else {
      _requirementsFuture = Future.value(const <Map<String, dynamic>>[]);
    }
  }

  Future<void> _loadAll() async {
    await _loadUserSpecificState();
    if (!mounted) return;
    setState(() {
      _requirementsFuture = _loadRequirementsWithEvidences();
    });
  }

  Future<List<Map<String, dynamic>>> _loadRequirementsWithEvidences() async {
    List<Map<String, dynamic>> badgeReqs = [];
    int badgeId = _badge.id;
    Map<String, dynamic>? detail;

    if (_currentRequestId != null) {
      try {
        detail = await ConsultorApi.instance.fetchPedidoDetail(
          pedidoId: _currentRequestId!,
        );
        if (detail != null) {
          _reviewerNote = detail['reviewerNote']?.toString() ??
              detail['comentario']?.toString() ??
              detail['nota']?.toString();
          _reviewerName = detail['reviewerName']?.toString() ??
              detail['avaliador']?.toString();

          if (badgeId <= 0) {
            badgeId = int.tryParse(detail['badgeDbId']?.toString() ??
                    detail['badgeId']?.toString() ??
                    detail['nbadge']?.toString() ??
                    '0') ??
                0;
          }
        }
      } catch (_) {}
    }

    if (badgeId > 0) {
      try {
        badgeReqs = await ConsultorApi.instance.fetchBadgeRequirements(
          badgeId: badgeId,
        );

        for (final badgeReq in badgeReqs) {
          if (badgeReq['attachments'] is List &&
              (badgeReq['attachments'] as List).isNotEmpty) {
            badgeReq['evidencias'] = (badgeReq['attachments'] as List).map((att) {
              if (att is Map) return att;
              return {'ficheiro': att.toString()};
            }).toList();
          }
        }
      } catch (_) {}
    }

    if (detail != null) {
      final reqData = detail['requirements'] ??
          detail['requisitos'] ??
          detail['items'] ??
          detail['itens'] ??
          detail['badgeRequirements'];
      if (reqData is List && reqData.isNotEmpty) {
        final pedidoReqs = reqData.whereType<Map<String, dynamic>>().toList();

        if (badgeReqs.isEmpty) {
          badgeReqs = pedidoReqs;
        } else {
          for (final badgeReq in badgeReqs) {
            final nreq =
                badgeReq['nreq']?.toString() ?? badgeReq['id']?.toString();
            if (nreq == null) continue;
            for (final pedidoReq in pedidoReqs) {
              final pNreq = pedidoReq['nreq']?.toString() ??
                  pedidoReq['id']?.toString() ??
                  pedidoReq['requirementId']?.toString();
              if (pNreq == nreq) {
                final pedidoEvidencias = pedidoReq['evidencias'] ??
                    pedidoReq['evidences'] ??
                    pedidoReq['anexos'] ??
                    pedidoReq['attachments'] ??
                    pedidoReq['files'] ??
                    pedidoReq['documentos'];

                if (pedidoEvidencias is List && pedidoEvidencias.isNotEmpty) {
                  badgeReq['evidencias'] = pedidoEvidencias;
                } else if (pedidoReq['files'] != null) {
                  final fileCount =
                      int.tryParse(pedidoReq['files'].toString()) ?? 0;
                  if (fileCount > 0 &&
                      !(badgeReq['evidencias'] is List &&
                          (badgeReq['evidencias'] as List).isNotEmpty)) {
                    badgeReq['evidencias'] = List.generate(
                        fileCount, (i) => {'ficheiro': 'Documento ${i + 1}'});
                  }
                }
                break;
              }
            }
          }
        }
      }
    }

    return badgeReqs;
  }

  Future<void> _loadUserSpecificState() async {
    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId == null) return;

      final myBadges = await BadgesApi.instance.fetchMyBadges(
        accountId: accountId,
      );

      for (final mb in myBadges) {
        if (mb.id == _badge.id) {
          if (!mounted) return;
          setState(() {
            _badge = BadgeData(
              id: _badge.id,
              title: _badge.title,
              level: _badge.level,
              points: _badge.points,
              date: _badge.date,
              badgeImage: _badge.badgeImage,
              frameColor: _badge.frameColor,
              iconBackground: _badge.iconBackground,
              shape: _badge.shape,
              isOwned: mb.owned,
              isSpecial: _badge.isSpecial,
              levelKey: _badge.levelKey,
              stateId: mb.stateId,
              state: _badgeStateFromStatus(mb.stateId),
              requestId: mb.requestId,
            );
            _currentRequestId = mb.requestId;
          });
          break;
        }
      }
    } catch (_) {}
  }

  bool get _canRequest {
    return !_badge.isOwned && (_badge.state == null || _badge.state == BadgeState.warning);
  }

  bool get _canUpload {
    return _badge.state == BadgeState.inProgress && !_submitted;
  }

  Future<void> _requestBadge() async {
    if (_isRequesting) return;

    final accountId = await AuthSession.getAccountId();
    if (accountId == null) {
      setState(() {
        _requestResultMessage = 'Sessao expirada. Faca login novamente.';
        _requestSuccess = false;
      });
      return;
    }

    setState(() {
      _isRequesting = true;
      _requestResultMessage = null;
    });

    try {
      final result = await ConsultorApi.instance.requestBadgeAcquisition(
        accountId: accountId,
        badgeId: _badge.id,
      );

      if (!mounted) return;

      final status = result['status']?.toString() ?? '';
      final requestId = result['requestId'] as int?;

      String message;
      bool success;
      BadgeState newState;
      String? newStateId;

      switch (status) {
        case 'obtido':
          message = 'Ja possui esta badge!';
          success = true;
          newState = BadgeState.approved;
          newStateId = 'aprovado';
          break;
        case 'pendente-tm':
          message = 'Pedido enviado com sucesso! Em validacao pelo Talent Manager.';
          success = true;
          if (_previousBadgeState == BadgeState.warning) {
            newState = BadgeState.inProgress;
          } else {
            newState = BadgeState.review;
          }
          newStateId = 'pendente-tm';
          break;
        case 'candidatura_em_progresso':
          message = 'Candidatura criada. Submeta evidencias para continuar.';
          success = true;
          newState = BadgeState.inProgress;
          newStateId = 'candidatura_em_progresso';
          break;
        default:
          message = 'Pedido processado.';
          success = true;
          newState = BadgeState.inProgress;
          newStateId = status;
      }

      setState(() {
        _isRequesting = false;
        _requestResultMessage = message;
        _requestSuccess = success;
        _badge = BadgeData(
          id: _badge.id,
          title: _badge.title,
          level: _badge.level,
          points: _badge.points,
          date: _badge.date,
          badgeImage: _badge.badgeImage,
          frameColor: _badge.frameColor,
          iconBackground: _badge.iconBackground,
          shape: _badge.shape,
          isOwned: _badge.isOwned,
          isSpecial: _badge.isSpecial,
          levelKey: _badge.levelKey,
          stateId: newStateId,
          state: newState,
          requestId: requestId ?? _currentRequestId,
        );
        _currentRequestId = requestId ?? _currentRequestId;
        _previousBadgeState = newState;
      });

      if (mounted) {
        setState(() {
          _requirementsFuture = _loadRequirementsWithEvidences();
        });
      }
    } on ConsultorApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isRequesting = false;
        _requestResultMessage = e.message;
        _requestSuccess = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRequesting = false;
        _requestResultMessage = 'Erro ao submeter pedido. Tente novamente.';
        _requestSuccess = false;
      });
    }
  }

  Future<void> _pickFiles(int requirementIndex) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final current = _filesByRequirement[requirementIndex] ?? [];
        current.addAll(result.paths.whereType<String>().map((p) => File(p)));
        _filesByRequirement[requirementIndex] = current;
      });
    }
  }

  void _removeFile(int requirementIndex, int fileIndex) {
    setState(() {
      _filesByRequirement[requirementIndex]?.removeAt(fileIndex);
    });
  }

  Future<void> _refreshBadge() async {
    await _loadUserSpecificState();
    if (!mounted) return;
    setState(() {
      _requirementsFuture = _loadRequirementsWithEvidences();
    });
  }

  Future<void> _submitAllAndRequest() async {
    if (_submittingAll) return;
    if (_currentRequestId == null) {
      setState(() {
        _requestResultMessage = 'Pedido nao encontrado.';
        _requestSuccess = false;
      });
      return;
    }

    final hasAnyFiles = _filesByRequirement.values.any(
      (files) => files.isNotEmpty,
    );

    if (!hasAnyFiles) {
      setState(() {
        _requestResultMessage = 'Adicione pelo menos um ficheiro antes de submeter.';
        _requestSuccess = false;
      });
      return;
    }

    setState(() => _submittingAll = true);

    try {
      for (final entry in _filesByRequirement.entries) {
        if (entry.value.isEmpty) continue;
        await ConsultorApi.instance.uploadEvidence(
          pedidoId: _currentRequestId!,
          nreq: entry.key,
          files: entry.value,
        );
      }

      final accountId = await AuthSession.getAccountId();
      if (accountId == null) {
        throw Exception('Sessao expirada.');
      }

      await ConsultorApi.instance.requestBadgeAcquisition(
        accountId: accountId,
        badgeId: _badge.id,
      );

      if (!mounted) return;

      setState(() {
        _submittingAll = false;
        _submitted = true;
        _filesByRequirement.clear();
        _requestResultMessage = 'Candidatura submetida com sucesso.';
        _requestSuccess = true;
        _badge = BadgeData(
          id: _badge.id,
          title: _badge.title,
          level: _badge.level,
          points: _badge.points,
          date: _badge.date,
          badgeImage: _badge.badgeImage,
          frameColor: _badge.frameColor,
          iconBackground: _badge.iconBackground,
          shape: _badge.shape,
          isOwned: _badge.isOwned,
          isSpecial: _badge.isSpecial,
          levelKey: _badge.levelKey,
          stateId: 'em_validacao_tm',
          state: BadgeState.review,
          requestId: _currentRequestId,
        );
      });

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() {
        _requirementsFuture = _loadRequirementsWithEvidences();
      });
      _loadUserSpecificState();

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submittingAll = false;
        _requestResultMessage = 'Falha ao submeter: $e';
        _requestSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBadge,
        child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requirementsFuture,
        builder: (context, snapshot) {
          final requirements = snapshot.data ?? const <Map<String, dynamic>>[];
          final hasError = snapshot.hasError;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: BadgeArtwork(
                          size: 160,
                          frameColor: badge.frameColor,
                          backgroundColor: badge.iconBackground.withOpacity(0.35),
                          shape: badge.shape,
                          borderWidth: 10,
                          iconSize: 86,
                          badgeImage: badge.badgeImage,
                          levelKey: badge.levelKey,
                          title: badge.title,
                          subtitle: badge.level,
                          isSpecial: badge.isSpecial,
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
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _metaItem(Icons.schedule, 'Expira ${badge.date}'),
                          _metaItem(Icons.emoji_events_outlined, '${badge.points} pontos'),
                          _metaItem(Icons.description_outlined, '${requirements.length} requisitos'),
                        ],
                      ),
                      if (badge.state != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: statusColor, width: 1.6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timelapse, color: statusColor, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  statusText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                      if (_requestResultMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _requestSuccess ? const Color(0xFFE6F9ED) : const Color(0xFFFEE8E8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _requestSuccess ? const Color(0xFF16C524) : const Color(0xFFFF3B30),
                              width: 1.4,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _requestSuccess ? Icons.check_circle_outline : Icons.error_outline,
                                color: _requestSuccess ? const Color(0xFF16C524) : const Color(0xFFFF3B30),
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _requestResultMessage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _requestSuccess ? const Color(0xFF05603A) : const Color(0xFFA32424),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_canRequest) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isRequesting ? null : _requestBadge,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A90F0),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF93C5FD),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isRequesting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : const Text(
                                    'Iniciar Candidatura',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requisitos',
                        style: TextStyle(fontSize: 24 / 2, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (snapshot.connectionState != ConnectionState.done)
                        const Center(child: CircularProgressIndicator())
                      else if (hasError)
                        const Text(
                          'Nao foi possivel carregar a base de dados.',
                          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                        )
                      else if (requirements.isEmpty)
                        const Text(
                          'Sem requisitos associados.',
                          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                        )
                      else
                        ...requirements.asMap().entries.map((entry) {
                          final req = entry.value;
                          final nreq = int.tryParse(req['nreq']?.toString() ?? '') ?? (entry.key + 1);
                          final title = req['titulo']?.toString() ?? req['requisito']?.toString() ?? req['title']?.toString() ?? req['name']?.toString() ?? req['text']?.toString() ?? 'Sem titulo';
                          final description = req['description']?.toString() ?? req['r_descricao']?.toString() ?? req['descricao']?.toString() ?? '';
                          final isExpanded = _expandedRequirements.contains(nreq);
                          final evidencias = req['evidencias'] ??
                              req['evidences'] ??
                              req['anexos'] ??
                              req['attachments'] ??
                              req['files'] ??
                              req['documentos'];
                          final List evidenciasList =
                              evidencias is List ? evidencias : [];
                          final hasFiles =
                              _filesByRequirement[nreq]?.isNotEmpty == true;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedRequirements.remove(nreq);
                                        } else {
                                          _expandedRequirements.add(nreq);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  maxLines: isExpanded ? null : 2,
                                                  overflow: isExpanded
                                                      ? null
                                                      : TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF111827)),
                                                ),
                                                if (evidenciasList.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.attach_file,
                                                          size: 14,
                                                          color: Color(0xFF1A90F0)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${evidenciasList.length} ficheiro${evidenciasList.length > 1 ? 's' : ''} submetido${evidenciasList.length > 1 ? 's' : ''}',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Color(0xFF1A90F0)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (description.isNotEmpty) ...[
                                            Text(
                                              description,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF374151),
                                                  height: 1.5),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          if (evidenciasList.isNotEmpty) ...[
                                            const Text(
                                              'Documentos submetidos:',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF6B7280)),
                                            ),
                                            const SizedBox(height: 4),
                                            ...evidenciasList.map((ev) {
                                              String fileName;
                                              if (ev is Map) {
                                                fileName = ev['ficheiro']
                                                        ?.toString() ??
                                                    ev['filename']?.toString() ??
                                                    ev['name']?.toString() ??
                                                    ev['label']?.toString() ??
                                                    ev['fileName']?.toString() ??
                                                    ev['file']?.toString() ??
                                                    '';
                                              } else {
                                                fileName = ev.toString();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4, left: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.description,
                                                        size: 14,
                                                        color: Color(0xFF94A3B8)),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        fileName,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Color(0xFF6B7280)),
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                          if (_canUpload) ...[
                                            const SizedBox(height: 8),
                                            if (hasFiles) ...[
                                              ...(_filesByRequirement[nreq]!.asMap().entries.map((fe) {
                                                final file = fe.value;
                                                final fileName = file.path.split(Platform.pathSeparator).last;
                                                return Row(
                                                  children: [
                                                    const Icon(Icons.attach_file, size: 16, color: Color(0xFF1A90F0)),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(fileName, style: const TextStyle(fontSize: 13, color: Color(0xFF111827))),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => _removeFile(nreq, fe.key),
                                                      child: const Icon(Icons.close, size: 16, color: Color(0xFFFF3B30)),
                                                    ),
                                                  ],
                                                );
                                              })),
                                              const SizedBox(height: 8),
                                            ],
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () => _pickFiles(nreq),
                                                icon: const Icon(Icons.attach_file, size: 20),
                                                label: const Text('Anexar ficheiro'),
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: Color(0xFF1A90F0)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 200),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                if (_canUpload) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submittingAll ? null : _submitAllAndRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A90F0),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF93C5FD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _submittingAll
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Submeter',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
                if (_reviewerNote != null || _reviewerName != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comentario do Avaliador',
                          style: TextStyle(fontSize: 24 / 2, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (_reviewerName != null && _reviewerName!.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _reviewerName![0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _reviewerName!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          _reviewerNote ?? 'A aguardar validacao.',
                          style: TextStyle(
                            fontSize: 14,
                            color: _reviewerNote != null ? const Color(0xFF374151) : const Color(0xFF94A3B8),
                            fontStyle: _reviewerNote == null ? FontStyle.italic : null,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: widget.selectedBottomNavIndex,
          onDestinationSelected: (index) {
            if (index == widget.selectedBottomNavIndex) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AppShellScreen(initialIndex: index)),
            );
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEAF2FF),
          height: 74,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Badges'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Jornada'),
            NavigationDestination(icon: Icon(Icons.history_outlined), label: 'Pedidos'),
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
      case BadgeState.inProgress:
        return 'Candidatura em Progresso';
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
      case BadgeState.inProgress:
        return const Color(0xFF1A90F0);
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
