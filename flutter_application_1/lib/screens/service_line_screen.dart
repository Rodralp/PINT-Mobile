import 'package:flutter/material.dart';
import '../services/consultor_api.dart';
import '../services/auth_session.dart';
import '../widgets/app_top_bar.dart';
import 'order_detail_screen.dart';
import 'settings_menu_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';

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

  String? _resolveBadgeAsset(BackendLevel level) {
    final raw = (level.badgeImage ?? '').toLowerCase();
    if (raw.contains('junior')) return 'assets/badges/junior.png';
    if (raw.contains('intermedio')) return 'assets/badges/intermedio.png';
    if (raw.contains('senior')) return 'assets/badges/senior.png';
    if (raw.contains('especialista')) return 'assets/badges/especialista.png';
    if (raw.contains('lider')) return 'assets/badges/lider_conhecimento.png';
    return null;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(imageAsset, width: 80, height: 80, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.business_center, color: Colors.white, size: 48),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      line.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso da Service Line',
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
    final status = _statusLabel(level.status);
    final canRequest = level.status == 'visualizar' && level.badgeDbId != null;
    final canContinue = level.status == 'candidatura_em_progresso' && level.requestId != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          bool isRequesting = false;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(level.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(status.icon ?? Icons.info_outline, color: status.color, size: 20),
                    const SizedBox(width: 8),
                    Text(status.text, style: TextStyle(color: status.color, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                if (canRequest)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isRequesting ? null : () async {
                        setSheetState(() => isRequesting = true);
                        final accountId = await AuthSession.getAccountId();
                        if (accountId != null) {
                          try {
                            await ConsultorApi.instance.requestBadgeAcquisition(accountId: accountId, badgeId: level.badgeDbId!);
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            setSheetState(() => isRequesting = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A90F0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isRequesting ? const CircularProgressIndicator(color: Colors.white) : const Text('Pedir Badge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (canContinue)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A90F0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
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
                      child: const Text('Continuar Candidatura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 32),
                const Text('Requisitos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (level.requirements.isEmpty)
                  const Text('Sem requisitos associados.', style: TextStyle(color: Colors.grey))
                else
                  ...level.requirements.map((r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(r.description),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  _StatusLabel _statusLabel(String status) {
    switch (status) {
      case 'obtido': return const _StatusLabel('Badge obtido', Color(0xFF39C65A), Icons.check_circle);
      case 'candidatura_em_progresso': return const _StatusLabel('Candidatura em progresso', Color(0xFF1A90F0), Icons.timer_outlined);
      case 'em_validacao': return const _StatusLabel('Em validação', Color(0xFFF59E0B), Icons.search);
      default: return const _StatusLabel('Visualizar', Color(0xFF64748B), null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final levels = line.areas.expand((a) => a.levels).toList();
    final obtained = levels.where((level) => level.status == 'obtido').length;
    final total = levels.length;
    final percent = total > 0 ? obtained / total : 0.0;
    final progressLabel = '$obtained de $total obtidas';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(line.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                        'Áreas de Conhecimento',
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
                    resolveBadgeAsset: _resolveBadgeAsset,
                    statusLabelBuilder: _statusLabel,
                    onLevelTap: (level) => _openLevelDetails(context, level, line.name, area.name),
                  ),
                const SizedBox(height: 32),
              ],
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
  const _AreaCard({required this.area, required this.isExpanded, required this.onToggle, required this.resolveBadgeAsset, required this.statusLabelBuilder, required this.onLevelTap});
  final BackendArea area;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? Function(BackendLevel) resolveBadgeAsset;
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
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: resolveBadgeAsset(level) != null
                            ? Image.asset(resolveBadgeAsset(level)!, width: 28, height: 28)
                            : const Icon(Icons.workspace_premium_outlined, color: Color(0xFF64748B), size: 24),
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
