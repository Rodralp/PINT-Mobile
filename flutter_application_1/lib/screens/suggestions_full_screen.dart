import 'package:flutter/material.dart';

import '../services/consultor_api.dart';
import '../widgets/badge_artwork.dart';

class SuggestionsFullScreen extends StatelessWidget {
  const SuggestionsFullScreen({
    super.key,
    this.suggestions = const [],
    this.isLoading = false,
  });

  final List<BackendSuggestionItem> suggestions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sugestões',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF243047),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sugestões personalizadas para si',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore áreas alinhadas com o seu perfil e descubra badges que fazem sentido para a sua evolução.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (suggestions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Defina as suas preferências nas definições para receber sugestões alinhadas com a sua área.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5B6472),
                        height: 1.45,
                      ),
                    ),
                  )
                else
                  ...List.generate(suggestions.length, (index) {
                    final item = suggestions[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == suggestions.length - 1 ? 0 : 12,
                      ),
                      child: _SuggestionItemFull(
                        title: item.title,
                        subtitle: _badgeLevelLabelFromKey(item.subtitleKey),
                        subtitleKey: item.subtitleKey,
                        description:
                            'Sugestões e badges alinhados com as suas preferências.',
                        accentColor: _accentColorFromKey(item.accent),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionItemFull extends StatelessWidget {
  const _SuggestionItemFull({
    required this.title,
    required this.subtitle,
    required this.subtitleKey,
    required this.description,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String subtitleKey;
  final String description;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: BadgeArtwork(
                  size: 54,
                  frameColor: accentColor,
                  backgroundColor: Colors.transparent,
                  shape: BoxShape.circle,
                  borderWidth: 0,
                  iconSize: 28,
                  title: title,
                  subtitle: subtitleKey,
                  imagePadding: const EdgeInsets.all(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243047),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFB7C0CE),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5B6472),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

String _badgeLevelLabelFromKey(String key) {
  switch (key.trim().toLowerCase()) {
    case 'badge_level_junior':
      return 'Júnior';
    case 'badge_level_intermediate':
      return 'Intermédio';
    case 'badge_level_senior':
      return 'Sénior';
    case 'badge_level_specialist':
      return 'Especialista';
    case 'badge_level_knowledge_lead':
      return 'Líder de Conhecimento';
    default:
      return key;
  }
}

Color _accentColorFromKey(String accent) {
  switch (accent.toLowerCase()) {
    case 'success':
      return const Color(0xFF16A34A);
    case 'violet':
      return const Color(0xFF7C3AED);
    case 'amber':
      return const Color(0xFFF59E0B);
    case 'warning':
      return const Color(0xFFEF4444);
    case 'info':
      return const Color(0xFF0EA5E9);
    case 'yellow':
      return const Color(0xFFEAB308);
    default:
      return const Color(0xFF16A34A);
  }
}
