import 'package:flutter/material.dart';

class SuggestionsFullScreen extends StatelessWidget {
  const SuggestionsFullScreen({super.key});

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
                const _SuggestionItemFull(
                  title: 'LowCode (Outsystems)',
                  subtitle: 'Líder de Conhecimento',
                  description:
                      'Conteúdos, badges e evolução focados em desenvolvimento rápido e integração de processos.',
                  accentColor: Color(0xFF2F80ED),
                ),
                const SizedBox(height: 12),
                const _SuggestionItemFull(
                  title: 'Cloud Architecture',
                  subtitle: 'Especialista',
                  description:
                      'Recomendações ligadas a arquitetura, escalabilidade e infraestrutura cloud.',
                  accentColor: Color(0xFF7C3AED),
                ),
                const SizedBox(height: 12),
                const _SuggestionItemFull(
                  title: 'Hybrid Cloud',
                  subtitle: 'Intermédio',
                  description:
                      'Sugestões para consolidar conhecimento entre ambientes públicos e privados.',
                  accentColor: Color(0xFF0EA5E9),
                ),
                const SizedBox(height: 12),
                const _SuggestionItemFull(
                  title: 'Application Operations',
                  subtitle: 'Especialista',
                  description:
                      'Aprendizagem prática sobre operação, estabilidade e suporte de aplicações.',
                  accentColor: Color(0xFF16A34A),
                ),
                const SizedBox(height: 12),
                const _SuggestionItemFull(
                  title: 'C++ Mastery',
                  subtitle: 'Sénior',
                  description:
                      'Badges técnicos mais profundos para perfis com foco em performance e programação avançada.',
                  accentColor: Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                const _SuggestionItemFull(
                  title: 'Data Analytics',
                  subtitle: 'Intermédio',
                  description:
                      'Sugestões ligadas a dados, métricas e leitura de informação para tomada de decisão.',
                  accentColor: Color(0xFFDB2777),
                ),
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
    required this.description,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
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
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
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
