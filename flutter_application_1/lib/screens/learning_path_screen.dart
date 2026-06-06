import 'dart:async';
import 'package:flutter/material.dart';
import '../services/consultor_api.dart';
import '../services/auth_session.dart';
import '../widgets/app_top_bar.dart';
import 'order_detail_screen.dart';
import 'settings_menu_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  late Future<List<BackendLearningPath>> _loadPathsFuture;
  List<BackendLearningPath> _learningPaths = [];
  String? _selectedPathId;
  String? _selectedServiceLineId;
  final Set<String> _expandedPathIds = {};
  final Set<String> _expandedAreaIds = {};

  @override
  void initState() {
    super.initState();
    _loadPathsFuture = _loadInitialData();
  }

  Future<List<BackendLearningPath>> _loadInitialData() async {
    final accountId = await AuthSession.getAccountId();
    if (accountId == null) return [];
    
    final paths = await ConsultorApi.instance.fetchLearningPaths(accountId: accountId);
    if (paths.isNotEmpty) {
      setState(() {
        _learningPaths = paths;
        _selectedPathId = paths.first.id;
        for (var p in paths) {
          _expandedPathIds.add(p.id);
        }
      });
    }
    return paths;
  }

  void _togglePath(String id) {
    setState(() {
      if (_expandedPathIds.contains(id)) {
        _expandedPathIds.remove(id);
      } else {
        _expandedPathIds.add(id);
      }
    });
  }

  void _toggleArea(String id) {
    setState(() {
      if (_expandedAreaIds.contains(id)) {
        _expandedAreaIds.remove(id);
      } else {
        _expandedAreaIds.add(id);
      }
    });
  }

  _ProgressInfo _calculateProgress(List<BackendLevel> levels) {
    if (levels.isEmpty) return const _ProgressInfo(total: 0, obtained: 0, percent: 0, label: '0 badges');
    final obtained = levels.where((level) => level.status == 'obtido').length;
    final total = levels.length;
    final percent = total > 0 ? obtained / total : 0.0;
    return _ProgressInfo(
      total: total,
      obtained: obtained,
      percent: percent,
      label: '$obtained de $total badges obtidas',
    );
  }

  String? _resolveServiceLineImage(String? path) {
    if (path == null) return null;
    if (path.toLowerCase().contains('lp_bg')) return 'assets/images/lp_bg.png';
    return null;
  }

  String? _resolveBadgeAsset(BackendLevel level) {
    final raw = (level.badgeImage ?? '').toLowerCase();
    if (raw.contains('junior')) return 'assets/badges/junior.png';
    if (raw.contains('intermedio')) return 'assets/badges/intermedio.png';
    if (raw.contains('senior')) return 'assets/badges/senior.png';
    if (raw.contains('especialista')) return 'assets/badges/especialista.png';
    if (raw.contains('lider')) return 'assets/badges/lider_conhecimento.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<BackendLearningPath>>(
          future: _loadPathsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final selectedLine = _getSelectedServiceLine();
            if (selectedLine != null) {
              return _buildServiceLineDetail(context, selectedLine);
            }

            return _buildLearningPathList(context);
          },
        ),
      ),
    );
  }

  BackendServiceLine? _getSelectedServiceLine() {
    if (_selectedPathId == null || _selectedServiceLineId == null) return null;
    final path = _learningPaths.firstWhere((p) => p.id == _selectedPathId);
    return path.serviceLines.firstWhere((l) => l.id == _selectedServiceLineId);
  }

  Widget _buildLearningPathList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTopBar(
            onSettingsTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsMenuScreen())),
            onNotificationsTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsFullScreen())),
            onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen())),
            onMessagesTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MessagesScreen())),
          ),
          const SizedBox(height: 16),
          for (final path in _learningPaths) ...[
            _buildPathHeader(path),
            if (_expandedPathIds.contains(path.id))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC), // Fundo levemente cinzento
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      for (final line in path.serviceLines)
                        _buildServiceLineCard(path, line),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildPathHeader(BackendLearningPath path) {
    final isExpanded = _expandedPathIds.contains(path.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _togglePath(path.id),
        borderRadius: isExpanded 
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: isExpanded 
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF9800), // Laranja
                Color(0xFFF06292), // Rosa
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  path.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceLineCard(BackendLearningPath path, BackendServiceLine line) {
    final levels = line.areas.expand((a) => a.levels).toList();
    final progress = _calculateProgress(levels);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: _ServiceLineCard(
        title: line.name,
        subtitle: line.description,
        progress: progress.percent,
        footerText: progress.label,
        progressColor: progress.percent >= 1 ? Colors.green : Colors.blue,
        imageLabel: line.name.substring(0, 1),
        imageAsset: _resolveServiceLineImage(line.image),
        onTap: () => setState(() => _selectedServiceLineId = line.id),
      ),
    );
  }

  Widget _buildServiceLineDetail(BuildContext context, BackendServiceLine line) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedServiceLineId = null)),
          title: Text(line.name),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final area in line.areas)
                _AreaCard(
                  area: area,
                  isExpanded: _expandedAreaIds.contains(area.id),
                  onToggle: () => _toggleArea(area.id),
                  resolveBadgeAsset: _resolveBadgeAsset,
                  statusLabelBuilder: _statusLabel,
                  onLevelTap: (level) => _openLevelDetails(context, level, line.name, area.name),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLevelDetails(BuildContext context, BackendLevel level, String serviceLine, String area) {
    final status = _statusLabel(level.status);
    final canRequest = level.status == 'visualizar' && level.badgeDbId != null;
    final canContinue = level.status == 'candidatura_em_progresso' && level.requestId != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          bool isRequesting = false;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(status.icon ?? Icons.info_outline, color: status.color, size: 20),
                    const SizedBox(width: 8),
                    Text(status.text, style: TextStyle(color: status.color, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                if (canRequest)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isRequesting ? null : () async {
                        setSheetState(() => isRequesting = true);
                        final accountId = await AuthSession.getAccountId();
                        if (accountId != null) {
                          await ConsultorApi.instance.requestBadgeAcquisition(accountId: accountId, badgeId: level.badgeDbId!);
                          Navigator.pop(context);
                          _loadPathsFuture = _loadInitialData();
                        }
                      },
                      child: isRequesting ? const CircularProgressIndicator() : const Text('Pedir Badge'),
                    ),
                  ),
                if (canContinue)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A90F0)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              order: OrderDetailData(
                                id: level.requestId!,
                                badge: level.title,
                                level: level.subtitle,
                                status: OrderStatus.pending,
                                date: '',
                                badgeDbId: level.badgeDbId,
                                serviceLine: serviceLine,
                                area: area,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Continuar Candidatura', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text('Requisitos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...level.requirements.map((r) => ListTile(title: Text(r.title), subtitle: Text(r.description))),
              ],
            ),
          );
        },
      ),
    );
  }

  _StatusLabel _statusLabel(String status) {
    switch (status) {
      case 'obtido': return const _StatusLabel('Badge obtido', Colors.green, Icons.check_circle);
      case 'candidatura_em_progresso': return const _StatusLabel('Candidatura em progresso', Colors.blue, Icons.timer_outlined);
      case 'em_validacao': return const _StatusLabel('Em validação', Colors.orange, Icons.search);
      default: return const _StatusLabel('Visualizar', Colors.grey, null);
    }
  }
}

class _ProgressInfo {
  const _ProgressInfo({required this.total, required this.obtained, required this.percent, required this.label});
  final int total, obtained;
  final double percent;
  final String label;
}

class _StatusLabel {
  const _StatusLabel(this.text, this.color, this.icon);
  final String text;
  final Color color;
  final IconData? icon;
}

class _ServiceLineCard extends StatelessWidget {
  const _ServiceLineCard({required this.title, required this.subtitle, required this.progress, required this.footerText, required this.progressColor, required this.imageLabel, this.imageAsset, this.onTap});
  final String title, subtitle, footerText, imageLabel;
  final double progress;
  final Color progressColor;
  final String? imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                color: progressColor,
                backgroundColor: const Color(0xFFE2E8F0),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              footerText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.area, required this.isExpanded, required this.onToggle, required this.resolveBadgeAsset, required this.statusLabelBuilder, required this.onLevelTap});
  final BackendArea area;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? Function(BackendLevel) resolveBadgeAsset;
  final _StatusLabel Function(String) statusLabelBuilder;
  final Function(BackendLevel) onLevelTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(area.name), onTap: onToggle, trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more)),
        if (isExpanded)
          for (final level in area.levels)
            ListTile(
              title: Text(level.title),
              subtitle: Text(statusLabelBuilder(level.status).text),
              onTap: () => onLevelTap(level),
            ),
      ],
    );
  }
}
