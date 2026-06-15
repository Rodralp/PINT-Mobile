import 'package:flutter/material.dart';
import '../services/consultor_api.dart';
import '../widgets/badge_artwork.dart';

class ProgressFullScreen extends StatelessWidget {
  const ProgressFullScreen({super.key, required this.items});

  final List<BackendProgressItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 36),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Em Progresso',
                    style: TextStyle(
                      fontSize: 48 / 2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF243047),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Sem itens em progresso para mostrar.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _ProgressItemFull(
                          title: item.title,
                          subtitle: item.subtitle,
                          status: _ProgressItemFull._statusFromBackend(item),
                          accent: _ProgressItemFull._accentFromBackend(item.accent),
                          icon: _ProgressItemFull._iconFromBackend(item.iconKey),
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

class _ProgressItemFull extends StatelessWidget {
  const _ProgressItemFull({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color accent;
  final IconData icon;

  static String _statusFromBackend(BackendProgressItem item) {
    final iconKey = item.iconKey.toLowerCase();
    final accent = item.accent.toLowerCase();

    if (iconKey == 'searchcheck' || accent == 'success') {
      return 'aprovado';
    }

    if (accent == 'amber') {
      return 'evidencias_insuficientes';
    }

    if (iconKey == 'clock' || accent == 'warning') {
      return 'em_validacao';
    }

    return 'em_progresso';
  }

  static Color _accentFromBackend(String accent) {
    switch (accent.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'amber':
        return Colors.orange;
      case 'warning':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  static IconData _iconFromBackend(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'searchcheck':
        return Icons.check_circle_outline;
      case 'clock':
        return Icons.search;
      case 'alerttriangle':
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (status) {
      case 'evidencias_insuficientes':
        statusColor = Colors.orange;
        break;
      case 'aprovado':
        statusColor = Colors.green;
        break;
      case 'reprovado':
        statusColor = Colors.red;
        break;
      case 'em_validacao':
        statusColor = Colors.orange;
        break;
      case 'em_progresso':
      default:
        statusColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: BadgeArtwork(
              size: 56,
              frameColor: accent,
              backgroundColor: accent.withValues(alpha: 0.10),
              shape: BoxShape.rectangle,
              borderWidth: 0,
              iconSize: 32,
              title: title,
              subtitle: subtitle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF243047),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
        ],
      ),
    );
  }
}
