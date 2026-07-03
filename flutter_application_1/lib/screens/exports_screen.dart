import 'package:flutter/material.dart';

import '../services/badges_api.dart';
import '../services/auth_session.dart';
import '../services/export_service.dart';

enum _ExportTab { badges, certificate }

enum _BadgeFilter {
  todos,
  junior,
  intermedio,
  senior,
  especialista,
  lider,
  especial,
  expiringSoon,
}

enum _SortOption {
  pointsDesc,
  pointsAsc,
  areaAsc,
  areaDesc,
}

class ExportsScreen extends StatefulWidget {
  const ExportsScreen({super.key});

  @override
  State<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends State<ExportsScreen> {
  _ExportTab _activeTab = _ExportTab.badges;
  _BadgeFilter _activeFilter = _BadgeFilter.todos;
  _SortOption _sortBy = _SortOption.pointsDesc;

  List<BackendBadge> _allBadges = [];
  bool _isLoading = true;
  String? _error;
  String _searchTerm = '';
  String _userName = '';

  final Set<int> _selectedBadgeIds = {};
  int? _selectedCertificateId;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accountId = await AuthSession.getAccountId();
      final name = await AuthSession.getAccountName();
      _userName = name ?? '';

      if (accountId == null) {
        setState(() {
          _error = 'Sessão expirada. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      final allBadges = await BadgesApi.instance.fetchMyBadges(accountId: accountId);
      final obtained = allBadges.where((b) => b.status == 'obtido').toList();

      setState(() {
        _allBadges = obtained;
        _selectedBadgeIds.addAll(obtained.map((b) => b.id));
        if (obtained.isNotEmpty) {
          _selectedCertificateId = obtained.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar os dados. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  List<BackendBadge> get _filteredBadges {
    final search = _searchTerm.trim().toLowerCase();

    return _allBadges.where((b) {
      final title = (b.title).toLowerCase();
      final area = (b.area ?? '').toLowerCase();
      final level = (b.levelKey ?? '').toLowerCase();

      final matchesSearch = search.isEmpty ||
          title.contains(search) ||
          area.contains(search) ||
          level.contains(search);

      bool matchesFilter = true;
      switch (_activeFilter) {
        case _BadgeFilter.todos:
          matchesFilter = true;
        case _BadgeFilter.junior:
          matchesFilter = b.levelKey?.toLowerCase().contains('junior') ?? false;
        case _BadgeFilter.intermedio:
          matchesFilter = b.levelKey?.toLowerCase().contains('intermediate') ?? false;
        case _BadgeFilter.senior:
          matchesFilter = b.levelKey?.toLowerCase().contains('senior') ?? false;
        case _BadgeFilter.especialista:
          matchesFilter = b.levelKey?.toLowerCase().contains('specialist') ?? false;
        case _BadgeFilter.lider:
          matchesFilter = b.levelKey?.toLowerCase().contains('knowledge_lead') ?? false;
        case _BadgeFilter.especial:
          matchesFilter = b.levelKey == null || b.levelKey!.isEmpty;
        case _BadgeFilter.expiringSoon:
          if (b.date != null) {
            try {
              final expDate = DateTime.parse(b.date!);
              final daysUntil = expDate.difference(DateTime.now()).inDays;
              matchesFilter = daysUntil <= 30;
            } catch (_) {
              matchesFilter = false;
            }
          } else {
            matchesFilter = false;
          }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<BackendBadge> get _sortedBadges {
    final list = List<BackendBadge>.from(_filteredBadges);

    switch (_sortBy) {
      case _SortOption.pointsDesc:
        list.sort((a, b) => b.points.compareTo(a.points));
      case _SortOption.pointsAsc:
        list.sort((a, b) => a.points.compareTo(b.points));
      case _SortOption.areaAsc:
        list.sort((a, b) => (a.area ?? '').compareTo(b.area ?? ''));
      case _SortOption.areaDesc:
        list.sort((a, b) => (b.area ?? '').compareTo(a.area ?? ''));
    }

    return list;
  }

  String _translateLevel(String? levelKey) {
    const map = {
      'badge_level_junior': 'Júnior',
      'badge_level_intermediate': 'Intermédio',
      'badge_level_senior': 'Sénior',
      'badge_level_specialist': 'Especialista',
      'badge_level_knowledge_lead': 'Líder de Conhecimento',
      'special': 'Especial',
    };
    return map[levelKey?.toLowerCase()] ?? levelKey ?? 'Nível';
  }

  String _filterLabel(_BadgeFilter f) {
    switch (f) {
      case _BadgeFilter.todos:
        return 'Todos';
      case _BadgeFilter.junior:
        return 'Júnior';
      case _BadgeFilter.intermedio:
        return 'Intermédio';
      case _BadgeFilter.senior:
        return 'Sénior';
      case _BadgeFilter.especialista:
        return 'Especialista';
      case _BadgeFilter.lider:
        return 'Líder de Conhecimento';
      case _BadgeFilter.especial:
        return 'Especial';
      case _BadgeFilter.expiringSoon:
        return 'Perto de expirar';
    }
  }

  String _sortLabel(_SortOption o) {
    switch (o) {
      case _SortOption.pointsDesc:
        return 'Pontos ↓';
      case _SortOption.pointsAsc:
        return 'Pontos ↑';
      case _SortOption.areaAsc:
        return 'Área A-Z';
      case _SortOption.areaDesc:
        return 'Área Z-A';
    }
  }

  void _toggleBadgeSelection(int id) {
    setState(() {
      if (_selectedBadgeIds.contains(id)) {
        _selectedBadgeIds.remove(id);
      } else {
        _selectedBadgeIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    final filtered = _filteredBadges;
    final allSelected = filtered.every((b) => _selectedBadgeIds.contains(b.id));

    setState(() {
      if (allSelected) {
        for (final b in filtered) {
          _selectedBadgeIds.remove(b.id);
        }
      } else {
        for (final b in filtered) {
          _selectedBadgeIds.add(b.id);
        }
      }
    });
  }

  Future<void> _exportBadgesToPDF() async {
    final selected = _allBadges
        .where((b) => _selectedBadgeIds.contains(b.id))
        .toList();

    if (selected.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um badge para exportar.')),
      );
      return;
    }

    try {
      final bytes = await ExportService.instance.generateBadgesPDF(selected, _userName);
      if (!mounted) return;
      await ExportService.instance.shareOrSavePDF(bytes, 'badges-${ExportService.instance.todayIso()}.pdf');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }

  Future<void> _exportBadgesToCSV() async {
    final selected = _allBadges
        .where((b) => _selectedBadgeIds.contains(b.id))
        .toList();

    if (selected.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um badge para exportar.')),
      );
      return;
    }

    try {
      final csv = ExportService.instance.generateBadgesCSV(selected);
      if (!mounted) return;
      await ExportService.instance.saveCSVToDevice(csv, 'badges-${ExportService.instance.todayIso()}.csv');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar CSV: $e')),
      );
    }
  }

  Future<void> _exportCertificateToPDF() async {
    if (_selectedCertificateId == null) return;

    final badge = _allBadges.firstWhere(
      (b) => b.id == _selectedCertificateId,
      orElse: () => _allBadges.first,
    );

    try {
      final bytes = await ExportService.instance.generateCertificatePDF(badge, _userName);
      if (!mounted) return;
      await ExportService.instance.shareOrSavePDF(bytes, 'certificado-${_userName.isNotEmpty ? _userName.replaceAll(' ', '_') : 'user'}.pdf');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar certificado: $e')),
      );
    }
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
          'Exportações',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A90F0)))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A90F0)),
              child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Tabs
          Row(
            children: [
              Expanded(
                child: _exportTypeButton(
                  label: 'Badges',
                  selected: _activeTab == _ExportTab.badges,
                  onTap: () => setState(() => _activeTab = _ExportTab.badges),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _exportTypeButton(
                  label: 'Certificado',
                  selected: _activeTab == _ExportTab.certificate,
                  onTap: () => setState(() => _activeTab = _ExportTab.certificate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search
          _buildSearchBar(),
          const SizedBox(height: 10),
          // Filter & Sort
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSortButton(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_activeTab == _ExportTab.badges) ...[
            _buildBadgesSection(),
          ] else ...[
            _buildCertificateSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
              onChanged: (value) => setState(() => _searchTerm = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _showFilterSheet,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _activeFilter != _BadgeFilter.todos
                ? const Color(0xFF1A90F0)
                : const Color(0xFFE0E6F0),
          ),
          color: _activeFilter != _BadgeFilter.todos
              ? const Color(0xFFF0F7FF)
              : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_alt_outlined, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Filtrar: ${_filterLabel(_activeFilter)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _showSortSheet,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _sortBy != _SortOption.pointsDesc
                ? const Color(0xFF1A90F0)
                : const Color(0xFFE0E6F0),
          ),
          color: _sortBy != _SortOption.pointsDesc
              ? const Color(0xFFF0F7FF)
              : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune_rounded, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Ordenar: ${_sortLabel(_sortBy)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Filtrar por nível',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ..._BadgeFilter.values.map((f) => ListTile(
                    title: Text(_filterLabel(f)),
                    trailing: _activeFilter == f
                        ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                        : null,
                    onTap: () {
                      setState(() => _activeFilter = f);
                      Navigator.pop(ctx);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ordenar por',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ..._SortOption.values.map((o) => ListTile(
                    title: Text(_sortLabel(o)),
                    trailing: _sortBy == o
                        ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                        : null,
                    onTap: () {
                      setState(() => _sortBy = o);
                      Navigator.pop(ctx);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _badgesSectionHeader() {
    final selectedCount = _filteredBadges
        .where((b) => _selectedBadgeIds.contains(b.id))
        .length;
    final allSelected =
        _filteredBadges.isNotEmpty && _filteredBadges.every((b) => _selectedBadgeIds.contains(b.id));

    return Row(
      children: [
        Expanded(
          child: Text(
            'Badges Obtidos (${_filteredBadges.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        GestureDetector(
          onTap: _toggleSelectAll,
          child: Text(
            allSelected ? 'Desselecionar' : 'Selecionar tudo',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A90F0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$selectedCount selecionados',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final badges = _sortedBadges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badgesSectionHeader(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Exportar PDF',
                icon: Icons.picture_as_pdf,
                primary: false,
                onPressed: _exportBadgesToPDF,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionButton(
                label: 'Exportar Excel',
                icon: Icons.table_chart,
                primary: true,
                onPressed: _exportBadgesToCSV,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (badges.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhum badge encontrado.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ),
          )
        else
          ...badges.map((badge) => _badgeCard(badge)),
      ],
    );
  }

  Widget _badgeCard(BackendBadge badge) {
    final isSelected = _selectedBadgeIds.contains(badge.id);
    final levelLabel = _translateLevel(badge.levelKey);

    return GestureDetector(
      onTap: () => _toggleBadgeSelection(badge.id),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A90F0) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            _badgeIcon(badge),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    levelLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        '${badge.points} pts',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        badge.date ?? '--',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleBadgeSelection(badge.id),
              activeColor: const Color(0xFF1A90F0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeIcon(BackendBadge badge) {
    final color = _colorForLevel(badge.levelKey);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: Icon(Icons.workspace_premium, color: color, size: 24),
      ),
    );
  }

  Color _colorForLevel(String? levelKey) {
    switch (levelKey?.toLowerCase()) {
      case 'badge_level_junior':
        return const Color(0xFFD67F45);
      case 'badge_level_intermediate':
        return const Color(0xFFA3AAB5);
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

  Widget _buildCertificateSection() {
    final badges = _sortedBadges;
    final selected = badges.isNotEmpty
        ? badges.firstWhere(
            (b) => b.id == _selectedCertificateId,
            orElse: () => badges.first,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecionar badge para certificado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (badges.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhum badge obtido disponível.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ),
          )
        else ...[
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              separatorBuilder: (a, b) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final b = badges[i];
                final isSel = b.id == _selectedCertificateId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCertificateId = b.id),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFF0F7FF) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? const Color(0xFF1A90F0) : const Color(0xFFE2E8F0),
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _colorForLevel(b.levelKey), width: 2),
                          ),
                          child: Icon(Icons.workspace_premium, color: _colorForLevel(b.levelKey), size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.title,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _translateLevel(b.levelKey),
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Certificate preview
          if (selected != null) _certificatePreview(selected),
          const SizedBox(height: 16),
          _actionButton(
            label: 'Exportar Certificado PDF',
            icon: Icons.picture_as_pdf,
            primary: true,
            onPressed: _exportCertificateToPDF,
          ),
        ],
      ],
    );
  }

  Widget _certificatePreview(BackendBadge badge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A90F0), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'SOFTINSA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A90F0),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Certificado de Conquista',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _colorForLevel(badge.levelKey), width: 3),
            ),
            child: Center(
              child: Icon(Icons.workspace_premium, color: _colorForLevel(badge.levelKey), size: 36),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Concedemos o presente certificado a',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 6),
          Text(
            _userName.isNotEmpty ? _userName : 'Utilizador',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'pela conquista da badge',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 6),
          Text(
            badge.area ?? badge.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A90F0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _translateLevel(badge.levelKey),
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            badge.date ?? '--',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool primary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: primary ? Colors.white : const Color(0xFF1A90F0)),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primary ? Colors.white : const Color(0xFF1A90F0),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? const Color(0xFF1A90F0) : Colors.white,
          foregroundColor: primary ? Colors.white : const Color(0xFF1A90F0),
          side: primary ? null : const BorderSide(color: Color(0xFF1A90F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _exportTypeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF1A90F0) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1.5,
          ),
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? const Color(0xFF1A90F0) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
