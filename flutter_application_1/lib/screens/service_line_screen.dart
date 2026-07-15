import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/consultor_api.dart';
import '../widgets/badge_artwork.dart';
import 'badges_screen.dart';


class ServiceLineScreen extends StatefulWidget {
  final BackendServiceLine line;

  const ServiceLineScreen({super.key, required this.line});

  @override
  State<ServiceLineScreen> createState() => _ServiceLineScreenState();
}

class _ServiceLineScreenState extends State<ServiceLineScreen> {
  final Set<String> _expandedAreaIds = {};

  void _toggleArea(String id) {
    setState(() {
      if (_expandedAreaIds.contains(id)) {
        _expandedAreaIds.remove(id);
      } else {
        _expandedAreaIds.add(id);
      }
    });
  }

  String? _resolveServiceLineImage(String? path) {
    if (path == null) return null;
    if (path.toLowerCase().contains('lp_bg')) return 'assets/images/lp_bg.png';
    return null;
  }

  Widget _buildHeader(BackendServiceLine line, double percent, String label) {
    final imageAsset = _resolveServiceLineImage(line.image);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A90F0), Color(0xFF4059D5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A90F0).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: imageAsset != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(imageAsset, width: 64, height: 64, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.business_center, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  line.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            line.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A90F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              color: percent >= 1.0 ? const Color(0xFF39C65A) : const Color(0xFF1A90F0),
            ),
          ),
        ],
      ),
    );
  }

  void _openLevelDetails(BuildContext context, BackendLevel level, String serviceLine, String area) {
    BadgeState? badgeState;
    switch (level.status) {
      case 'obtido':
        badgeState = BadgeState.approved;
        break;
      case 'candidatura_em_progresso':
        badgeState = BadgeState.inProgress;
        break;
      case 'em_validacao':
      case 'pendente-tm':
      case 'pendente-sll':
        badgeState = BadgeState.review;
        break;
      case 'rejeitado':
      case 'evidencias_insuficientes':
        badgeState = BadgeState.warning;
        break;
    }

    final badgeData = BadgeData(
      id: level.badgeDbId ?? 0,
      title: area,
      level: level.title,
      points: level.points,
      date: '',
      badgeImage: level.badgeImage,
      frameColor: const Color(0xFFBFC4CD),
      iconBackground: const Color(0xFFF0F0F0),
      shape: BoxShape.rectangle,
      isOwned: level.status == 'obtido',
      isSpecial: level.isSpecial,
      levelKey: level.levelKey,
      stateId: level.status,
      state: badgeState,
      requestId: level.requestId,
      description: level.description,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BadgeLiveDetailScreen(badge: badgeData),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  _StatusLabel _statusLabel(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'obtido': return _StatusLabel(l10n.approved, Color(0xFF39C65A), Icons.check_circle);
      case 'candidatura_em_progresso': return _StatusLabel(l10n.applicationInProgress, Color(0xFF1A90F0), Icons.timer_outlined);
      case 'pendente-tm':
      case 'pendente-sll':
      case 'em_validacao': return _StatusLabel('Pendente', Color(0xFFF59E0B), Icons.search);
      case 'rejeitado':
      case 'evidencias_insuficientes': return _StatusLabel(l10n.rejected, Color(0xFFEF4444), Icons.cancel_outlined);
      case 'sem_badge': return _StatusLabel('Sem badge', Color(0xFF64748B), Icons.warning_amber_outlined);
      default: return _StatusLabel('Visualizar', Color(0xFF64748B), null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final levels = line.areas.expand((a) => a.levels).toList();
    final obtained = levels.where((level) => level.status == 'obtido').length;
    final total = levels.length;
    final percent = total > 0 ? obtained / total : 0.0;
    final progressLabel = AppLocalizations.of(context)!.badgesObtainedCount(obtained, total);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(line.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildHeader(line, percent, progressLabel),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A90F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Areas de Conhecimento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final area in line.areas)
                    _AreaCard(
                      area: area,
                      isExpanded: _expandedAreaIds.contains(area.id),
                      onToggle: () => _toggleArea(area.id),
                      statusLabelBuilder: _statusLabel,
                      onLevelTap: (level) => _openLevelDetails(context, level, line.name, area.name),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}

class _StatusLabel {
  const _StatusLabel(this.text, this.color, this.icon);
  final String text;
  final Color color;
  final IconData? icon;
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.area, required this.isExpanded, required this.onToggle, required this.statusLabelBuilder, required this.onLevelTap});
  final BackendArea area;
  final bool isExpanded;
  final VoidCallback onToggle;
  final _StatusLabel Function(String) statusLabelBuilder;
  final Function(BackendLevel) onLevelTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(area.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
            onTap: onToggle,
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF1A90F0)),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            for (final level in area.levels)
              InkWell(
                onTap: () => onLevelTap(level),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      BadgeArtwork(
                        size: 44,
                        frameColor: const Color(0xFF1A90F0),
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: BoxShape.rectangle,
                        iconSize: 24,
                        badgeImage: level.badgeImage,
                        levelKey: level.levelKey,
                        title: level.title,
                        subtitle: level.title,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusLabelBuilder(level.status).text,
                              style: TextStyle(
                                color: statusLabelBuilder(level.status).color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
