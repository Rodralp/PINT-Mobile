import 'package:flutter/material.dart';
import 'app_shell_screen.dart';
import 'badges_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import 'messages_screen.dart';
import '../widgets/app_top_bar.dart';
import '../services/auth_session.dart';
import '../services/consultor_api.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  late final Future<void> _loadFuture;
  List<BackendLearningPath> _learningPaths = const [];
  String? _loadError;
  String? _selectedPathId;
  String? _selectedServiceLineId;
  final Set<String> _expandedPathIds = <String>{};
  final Set<String> _expandedAreaIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadLearningPaths();
  }

  Future<void> _loadLearningPaths() async {
    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId == null || accountId <= 0) {
        throw Exception('Missing account id');
      }

      final data = await ConsultorApi.instance.fetchLearningPaths(
        accountId: accountId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _learningPaths = data;
        _selectedPathId = data.isNotEmpty ? data.first.id : null;
        _selectedServiceLineId = null;
        _expandedPathIds.clear(); // Starts closed to show the dropdown effect
        _expandedAreaIds.clear();
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _learningPaths = const [];
        _loadError = 'Nao foi possivel carregar a base de dados';
      });
    }
  }

  BackendLearningPath? get _selectedPath {
    if (_learningPaths.isEmpty) {
      return null;
    }
    return _learningPaths.firstWhere(
      (path) => path.id == _selectedPathId,
      orElse: () => _learningPaths.first,
    );
  }

  BackendServiceLine? get _selectedServiceLine {
    final path = _selectedPath;
    if (path == null || _selectedServiceLineId == null) {
      return null;
    }
    for (final line in path.serviceLines) {
      if (line.id == _selectedServiceLineId) {
        return line;
      }
    }
    return null;
  }

  void _selectServiceLine(BackendLearningPath path, BackendServiceLine line) {
    setState(() {
      _selectedPathId = path.id;
      _selectedServiceLineId = line.id;
      _expandedAreaIds.clear();
    });
  }

  void _togglePath(String pathId) {
    setState(() {
      if (_expandedPathIds.contains(pathId)) {
        _expandedPathIds.remove(pathId);
      } else {
        _expandedPathIds.add(pathId);
      }
    });
  }

  void _toggleArea(String areaId) {
    setState(() {
      if (_expandedAreaIds.contains(areaId)) {
        _expandedAreaIds.remove(areaId);
      } else {
        _expandedAreaIds.add(areaId);
      }
    });
  }

  _ProgressInfo _calculateProgress(List<BackendLevel> levels) {
    if (levels.isEmpty) {
      return const _ProgressInfo(total: 0, obtained: 0, percent: 0, label: '0 badges');
    }
    final obtained = levels.where((level) => level.status == 'obtido').length;
    final total = levels.length;
    final isComplete = total > 0 && obtained == total;
    final percent = total > 0 ? obtained / total : 0.0;
    final label = isComplete
        ? 'Service Line Completada'
        : '$obtained de $total badges obtidas';
    return _ProgressInfo(
      total: total,
      obtained: obtained,
      percent: percent,
      label: label,
    );
  }

  String? _resolveServiceLineImage(String? imagePath) {
    final normalized = (imagePath ?? '').toLowerCase();
    if (normalized.contains('lp_bg')) {
      return 'assets/images/lp_bg.png';
    }
    return null;
  }

  String? _resolveBadgeAsset(BackendLevel level) {
    final raw = (level.badgeImage ?? '').toLowerCase();
    if (raw.contains('junior') || raw.contains('j%c3%ba')) {
      return 'assets/badges/junior.png';
    }
    if (raw.contains('intermedio') || raw.contains('interm') || raw.contains('interm%c3%a9dio')) {
      return 'assets/badges/intermedio.png';
    }
    if (raw.contains('senior') || raw.contains('s%c3%a9nior')) {
      return 'assets/badges/senior.png';
    }
    if (raw.contains('especialista')) {
      return 'assets/badges/especialista.png';
    }
    if (raw.contains('lider') || raw.contains('l%c3%adder') || raw.contains('conhecimento')) {
      return 'assets/badges/lider_conhecimento.png';
    }

    switch (level.levelKey) {
      case 'badge_level_junior':
        return 'assets/badges/junior.png';
      case 'badge_level_intermediate':
        return 'assets/badges/intermedio.png';
      case 'badge_level_senior':
        return 'assets/badges/senior.png';
      case 'badge_level_specialist':
        return 'assets/badges/especialista.png';
      case 'badge_level_knowledge_lead':
        return 'assets/badges/lider_conhecimento.png';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text('A carregar Service Lines...'),
              );
            }

            if (_loadError != null) {
              return Center(
                child: Text(_loadError ?? ''),
              );
            }

            final selectedServiceLine = _selectedServiceLine;
            if (selectedServiceLine != null) {
              return _buildServiceLineDetail(context, selectedServiceLine);
            }

            return _buildLearningPathList(context);
          },
        ),
      ),
    );
  }

  Widget _buildLearningPathList(BuildContext context) {
    if (_learningPaths.isEmpty) {
      return const Center(
        child: Text('Nao existem Learning Paths disponiveis.'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTopBar(
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Learning Paths',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
          ),
          for (final path in _learningPaths) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF00A8),
                      Color(0xFFFF0075),
                      Color(0xFFFF2A00),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _togglePath(path.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 28,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Jornada Técnica',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            _expandedPathIds.contains(path.id)
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_expandedPathIds.contains(path.id)) ...[
              if (path.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    path.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 8),
              for (final line in path.serviceLines) ...[
                Builder(
                  builder: (context) {
                    final levels = _flattenLevels(line);
                    final progress = _calculateProgress(levels);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _ServiceLineCard(
                        title: line.name,
                        subtitle: line.description,
                        progress: progress.percent,
                        footerText: progress.label,
                        progressColor: progress.percent >= 1
                            ? const Color(0xFF39C65A)
                            : const Color(0xFF1A90F0),
                        imageLabel: _buildInitials(line.name),
                        imageAsset: _resolveServiceLineImage(line.image),
                        onTap: () => _selectServiceLine(path, line),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<BackendLevel> _flattenLevels(BackendServiceLine line) {
    return line.areas.expand((area) => area.levels).toList(growable: false);
  }

  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return _takeInitials(parts.first, 2);
    }
    return (_takeInitials(parts.first, 1) + _takeInitials(parts.last, 1))
        .toUpperCase();
  }

  String _takeInitials(String value, int length) {
    if (value.isEmpty || length <= 0) {
      return '';
    }
    final runes = value.runes.toList();
    final slice = runes.take(length).toList();
    return String.fromCharCodes(slice);
  }

  Widget _buildServiceLineDetail(
    BuildContext context,
    BackendServiceLine line,
  ) {
    final levels = _flattenLevels(line);
    final progress = _calculateProgress(levels);
    final imageAsset = _resolveServiceLineImage(line.image);

    return Column(
      children: [
        AppTopBar(
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
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedServiceLineId = null;
                    _expandedAreaIds.clear();
                  });
                },
                icon: const Icon(Icons.arrow_back_ios_new, size: 30),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  line.name,
                  style: const TextStyle(
                    fontSize: 42 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE3E7EC)),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0B8EEA), Color(0xFF2A56D7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: imageAsset != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  imageAsset,
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                _buildInitials(line.name),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (line.description.isNotEmpty)
                              Text(
                                line.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.45,
                                ),
                              ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: progress.percent,
                                backgroundColor: const Color(0xFFE2E5EA),
                                color: progress.percent >= 1
                                    ? const Color(0xFF39C65A)
                                    : const Color(0xFF1A90F0),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              progress.label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.workspace_premium_outlined, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  '${progress.total} niveis',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'Areas',
                    style: TextStyle(
                      fontSize: 46 / 2,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (final area in line.areas) ...[
                        _AreaCard(
                          area: area,
                          isExpanded: _expandedAreaIds.contains(area.id),
                          onToggle: () => _toggleArea(area.id),
                          resolveBadgeAsset: _resolveBadgeAsset,
                          statusLabelBuilder: _statusLabel,
                        ),
                        const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _StatusLabel _statusLabel(String status) {
    switch (status) {
      case 'obtido':
        return const _StatusLabel('Badge obtido', Color(0xFF39C65A), Icons.check_circle);
      case 'candidatura_em_progresso':
        return const _StatusLabel('Candidatura em progresso', Color(0xFF1A90F0), Icons.timer_outlined);
      case 'em_validacao':
      case 'pendente-tm':
      case 'pendente-sll':
        return const _StatusLabel('Em validacao', Color(0xFFF59E0B), Icons.search);
      case 'evidencias_insuficientes':
        return const _StatusLabel('Evidencias insuficientes', Color(0xFFEF4444), Icons.warning_amber);
      case 'rejeitado':
        return const _StatusLabel('Rejeitado', Color(0xFFEF4444), Icons.cancel);
      default:
        return const _StatusLabel('Visualizar', Color(0xFF6B7280), null);
    }
  }
}

class _ProgressInfo {
  const _ProgressInfo({
    required this.total,
    required this.obtained,
    required this.percent,
    required this.label,
  });

  final int total;
  final int obtained;
  final double percent;
  final String label;
}

class _StatusLabel {
  const _StatusLabel(this.text, this.color, this.icon);

  final String text;
  final Color color;
  final IconData? icon;
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.area,
    required this.isExpanded,
    required this.onToggle,
    required this.resolveBadgeAsset,
    required this.statusLabelBuilder,
  });

  final BackendArea area;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? Function(BackendLevel) resolveBadgeAsset;
  final _StatusLabel Function(String) statusLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E7EC), width: 1.5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      area.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF1A90F0),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFE9EDF2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Niveis',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${area.levels.length} niveis',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final level in area.levels) ...[
                    _LevelRow(
                      level: level,
                      badgeAsset: resolveBadgeAsset(level),
                      statusLabel: statusLabelBuilder(level.status),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.level,
    required this.badgeAsset,
    required this.statusLabel,
  });

  final BackendLevel level;
  final String? badgeAsset;
  final _StatusLabel statusLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: badgeAsset != null
              ? Image.asset(badgeAsset!, width: 36, height: 36, fit: BoxFit.contain)
              : const Icon(Icons.workspace_premium_outlined, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (level.subtitle.isNotEmpty)
                Text(
                  level.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (statusLabel.icon != null)
                    Icon(statusLabel.icon, size: 18, color: statusLabel.color),
                  if (statusLabel.icon != null) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      statusLabel.text,
                      style: TextStyle(fontSize: 14, color: statusLabel.color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceLineCard extends StatelessWidget {
  const _ServiceLineCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.footerText,
    required this.progressColor,
    required this.imageLabel,
    this.imageAsset,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String footerText;
  final Color progressColor;
  final String imageLabel;
  final String? imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E7EC)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF1A90F0),
                    size: 38,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE9EDF2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A90F0), Color(0xFF4059D5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: imageAsset != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imageAsset!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            imageLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: progress,
                            backgroundColor: const Color(0xFFE2E5EA),
                            color: progressColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          footerText,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: progress >= 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HybridCloudPathScreen extends StatelessWidget {
  const HybridCloudPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 30),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Hybrid Cloud',
                    style: TextStyle(
                      fontSize: 42 / 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE3E7EC)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 106,
                            height: 106,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B8EEA), Color(0xFF2A56D7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.cloud_queue,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aprender Hybrid Cloud envolve bases de arquitetura, segurança e gestão, e uso de ferramentas como GKE, Anthos ou NetApp.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: const LinearProgressIndicator(
                                    minHeight: 8,
                                    value: 0.4,
                                    backgroundColor: Color(0xFFE2E5EA),
                                    color: Color(0xFF1A90F0),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '2 de 5 badges obtidas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: const [
                                    Icon(Icons.schedule_outlined, size: 30),
                                    SizedBox(width: 8),
                                    Text(
                                      '6 meses',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(width: 20),
                                    Icon(Icons.group_outlined, size: 30),
                                    SizedBox(width: 8),
                                    Text('123', style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: const Text(
                        'LowCode (Outsystems)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40 / 2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Text(
                        'Níveis',
                        style: TextStyle(
                          fontSize: 46 / 2,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _HybridLevelTile(
                            title: 'Nível Júnior',
                            subtitle: 'Nível A',
                            statusLabel: 'Concluído',
                            statusColor: const Color(0xFF1A90F0),
                            actionLabel: 'Ver badge',
                            actionIcon: Icons.visibility_outlined,
                            actionColor: const Color(0xFF1A90F0),
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BadgesScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _HybridLevelTile(
                            title: 'Nível Intermédio',
                            subtitle: 'Nível B',
                            statusLabel: 'Concluído',
                            statusColor: const Color(0xFF1A90F0),
                            actionLabel: 'Ver badge',
                            actionIcon: Icons.visibility_outlined,
                            actionColor: const Color(0xFF1A90F0),
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BadgesScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _HybridLevelTile(
                            title: 'Nível Sénior',
                            subtitle: 'Nível C',
                            statusLabel: 'Progresso: 0%',
                            statusColor: Color(0xFF7C7C7C),
                            actionLabel: 'Continuar',
                            actionColor: Color(0xFF111111),
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BadgesScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          const _HybridLevelTile(
                            title: 'Nível Especialista',
                            subtitle: 'Nível D',
                            statusLabel: '',
                            statusColor: Color(0xFFB4B4B4),
                            actionLabel: 'Bloqueado',
                            actionColor: Color(0xFFBAC0CB),
                            isDisabled: true,
                          ),
                          const SizedBox(height: 14),
                          const _HybridLevelTile(
                            title: 'Líder de Conhecimento',
                            subtitle: 'Nível E',
                            statusLabel: '',
                            statusColor: Color(0xFFB4B4B4),
                            actionLabel: 'Bloqueado',
                            actionColor: Color(0xFFBAC0CB),
                            isDisabled: true,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: 2,
          onDestinationSelected: (index) {
            if (index == 2) {
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
}

class _HybridLevelTile extends StatelessWidget {
  const _HybridLevelTile({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.actionLabel,
    required this.actionColor,
    this.actionIcon,
    this.onActionTap,
    this.isDisabled = false,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final String actionLabel;
  final Color actionColor;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width < 390
        ? 146
        : 168;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E7EC), width: 1.8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (statusLabel.isNotEmpty)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 10),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 18, color: statusColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          SizedBox(
            width: buttonWidth,
            height: 60,
            child: actionIcon == null
                ? OutlinedButton(
                    onPressed: isDisabled ? null : onActionTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDisabled
                            ? const Color(0xFFCAD0DA)
                            : actionColor,
                        width: 2.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      foregroundColor: actionColor,
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(fontSize: 18, color: actionColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: isDisabled ? null : onActionTap,
                    icon: Icon(actionIcon, size: 24, color: actionColor),
                    label: Text(
                      actionLabel,
                      style: TextStyle(fontSize: 18, color: actionColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDisabled
                            ? const Color(0xFFCAD0DA)
                            : actionColor,
                        width: 2.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      foregroundColor: actionColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
