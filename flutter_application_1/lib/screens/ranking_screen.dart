import 'package:flutter/material.dart';

import '../services/consultor_api.dart';

class _RankingConsultant {
  const _RankingConsultant({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.badges,
    required this.serviceLine,
    required this.avatar,
  });

  factory _RankingConsultant.fromBackend(BackendRankingConsultant consultant) {
    return _RankingConsultant(
      id: consultant.id,
      name: consultant.name,
      email: consultant.email,
      points: consultant.points,
      badges: consultant.badges,
      serviceLine: consultant.serviceLine,
      avatar: consultant.avatar,
    );
  }

  final int id;
  final String name;
  final String email;
  final int points;
  final int badges;
  final String serviceLine;
  final String? avatar;
}

class _FilterOption {
  const _FilterOption(this.id, this.label);

  final String id;
  final String label;
}

const List<_RankingConsultant> _fallbackRanking = [
  _RankingConsultant(
    id: 1,
    name: 'João Gomes',
    email: 'joaogomes1234@softinsa.pt',
    points: 2450,
    badges: 12,
    serviceLine: 'Cloud',
    avatar: null,
  ),
  _RankingConsultant(
    id: 2,
    name: 'Maria Santos',
    email: 'maria.santos@softinsa.pt',
    points: 2200,
    badges: 10,
    serviceLine: 'Data & AI',
    avatar: null,
  ),
  _RankingConsultant(
    id: 3,
    name: 'Pedro Mendes',
    email: 'pedro.mendes@softinsa.pt',
    points: 1950,
    badges: 9,
    serviceLine: 'Cloud',
    avatar: null,
  ),
  _RankingConsultant(
    id: 4,
    name: 'Ana Costa',
    email: 'ana.costa@softinsa.pt',
    points: 1700,
    badges: 8,
    serviceLine: 'LowCode',
    avatar: null,
  ),
];

const List<_FilterOption> _rankingSortOptions = [
  _FilterOption('points_desc', 'Pontos (Maior para Menor)'),
  _FilterOption('points_asc', 'Pontos (Menor para Maior)'),
  _FilterOption('badges_desc', 'Badges (Maior para Menor)'),
  _FilterOption('badges_asc', 'Badges (Menor para Maior)'),
  _FilterOption('name_asc', 'Nome (A-Z)'),
  _FilterOption('name_desc', 'Nome (Z-A)'),
];

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<_RankingConsultant> _consultants = _fallbackRanking;
  String _searchTerm = '';
  String _activeServiceLine = 'all';
  String _sortBy = 'points_desc';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ConsultorApi.instance.fetchRankingConsultores();
      setState(() {
        _consultants = data.map(_RankingConsultant.fromBackend).toList();
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Nao foi possivel carregar a base de dados.';
        _consultants = _fallbackRanking;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshRanking() async {
    await _loadRanking();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _serviceLineOptions() {
    final lines = _consultants.map((item) => item.serviceLine).where((line) => line.isNotEmpty).toSet();
    return ['all', ...lines];
  }

  List<_RankingConsultant> _applyFilters() {
    final normalizedSearch = _searchTerm.trim().toLowerCase();

    final filtered = _consultants.where((item) {
      final matchesServiceLine = _activeServiceLine == 'all' || item.serviceLine == _activeServiceLine;
      final matchesSearch = normalizedSearch.isEmpty
          || item.name.toLowerCase().contains(normalizedSearch)
          || item.email.toLowerCase().contains(normalizedSearch)
          || item.serviceLine.toLowerCase().contains(normalizedSearch);
      return matchesServiceLine && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'points_asc':
          return a.points.compareTo(b.points) != 0
              ? a.points.compareTo(b.points)
              : a.badges.compareTo(b.badges) != 0
                  ? a.badges.compareTo(b.badges)
                  : a.name.compareTo(b.name);
        case 'badges_desc':
          return b.badges.compareTo(a.badges) != 0
              ? b.badges.compareTo(a.badges)
              : b.points.compareTo(a.points) != 0
                  ? b.points.compareTo(a.points)
                  : a.name.compareTo(b.name);
        case 'badges_asc':
          return a.badges.compareTo(b.badges) != 0
              ? a.badges.compareTo(b.badges)
              : a.points.compareTo(b.points) != 0
                  ? a.points.compareTo(b.points)
                  : a.name.compareTo(b.name);
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'points_desc':
        default:
          return b.points.compareTo(a.points) != 0
              ? b.points.compareTo(a.points)
              : b.badges.compareTo(a.badges) != 0
                  ? b.badges.compareTo(a.badges)
                  : a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  Map<int, int> _rankingByConsultantId(List<_RankingConsultant> filtered) {
    final rankMode = _sortBy == 'badges_desc' || _sortBy == 'badges_asc' ? 'badges' : 'points';
    final reference = [...filtered]..sort((a, b) {
      if (rankMode == 'badges') {
        return b.badges.compareTo(a.badges) != 0
            ? b.badges.compareTo(a.badges)
            : b.points.compareTo(a.points) != 0
                ? b.points.compareTo(a.points)
                : a.name.compareTo(b.name);
      }
      return b.points.compareTo(a.points) != 0
          ? b.points.compareTo(a.points)
          : b.badges.compareTo(a.badges) != 0
              ? b.badges.compareTo(a.badges)
              : a.name.compareTo(b.name);
    });

    final ranking = <int, int>{};
    _RankingConsultant? previous;
    var currentRank = 0;
    for (var index = 0; index < reference.length; index++) {
      final item = reference[index];
      final hasSameScore = previous != null && previous!.points == item.points && previous!.badges == item.badges;
      if (!hasSameScore) {
        currentRank = index + 1;
      }
      ranking[item.id] = currentRank;
      previous = item;
    }
    return ranking;
  }

  void _showFilterSheet() {
    final options = _serviceLineOptions().map(
      (line) => _FilterOption(line, line == 'all' ? 'Todas as Service Lines' : line),
    ).toList();

    _showOptionsSheet(
      title: 'Filtrar consultores',
      options: options,
      selectedId: _activeServiceLine,
      onSelected: (value) {
        setState(() {
          _activeServiceLine = value;
        });
      },
    );
  }

  void _showSortSheet() {
    _showOptionsSheet(
      title: 'Ordenar ranking',
      options: _rankingSortOptions,
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
    final filtered = _applyFilters();
    final rankingById = _rankingByConsultantId(filtered);

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
          'Ranking',
          style: TextStyle(
            fontSize: 24,
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
        onRefresh: _refreshRanking,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE0E6F0),
                              ),
                              color: const Color(0xFFF8FAFC),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Pesquisar consultores',
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
                        const SizedBox(width: 12),
                        _toolButton(
                          icon: Icons.filter_alt_outlined,
                          onTap: _showFilterSheet,
                        ),
                        const SizedBox(width: 12),
                        _toolButton(
                          icon: Icons.tune_rounded,
                          onTap: _showSortSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFEF4444)),
                  ),
                ),
              )
            else if (filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Nao ha consultores para os filtros escolhidos.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final consultant = filtered[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == filtered.length - 1 ? 0 : 12,
                        ),
                        child: _RankingCard(
                          rank: rankingById[consultant.id] ?? 0,
                          name: consultant.name,
                          email: consultant.email,
                          points: consultant.points,
                          badges: consultant.badges,
                          avatarLetter: consultant.name.isNotEmpty
                              ? consultant.name.characters.first
                              : '?',
                          avatarUrl: consultant.avatar,
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          color: Colors.white,
        ),
        child: Icon(icon, size: 24, color: const Color(0xFF64748B)),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.rank,
    required this.name,
    required this.email,
    required this.points,
    required this.badges,
    required this.avatarLetter,
    this.avatarUrl,
  });

  final int rank;
  final String name;
  final String email;
  final int points;
  final int badges;
  final String avatarLetter;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(width: 48, child: Center(child: _rankBadge(rank))),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage:
                avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? Text(
                    avatarLetter,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
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
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _metricInfo('Pontos', '$points'),
                    const SizedBox(width: 24),
                    _metricInfo('Badges', '$badges'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A90F0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _rankBadge(int rank) {
    if (rank == 1) {
      return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFF5B301));
    }
    if (rank == 2) {
      return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFB8BDC7));
    }
    if (rank == 3) {
      return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFC4742F));
    }
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1F5F9),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
