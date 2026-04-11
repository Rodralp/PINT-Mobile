import 'package:flutter/material.dart';

class SuggestionsFullScreen extends StatelessWidget {
  const SuggestionsFullScreen({super.key});

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
                    'Sugestões',
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
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                children: const [
                  _SuggestionItemFull(
                    title: 'LowCode (Outsystems)',
                    subtitle: 'Líder de Conhecimento',
                  ),
                  SizedBox(height: 12),
                  _SuggestionItemFull(
                    title: 'Cloud Architecture',
                    subtitle: 'Especialista',
                  ),
                  SizedBox(height: 12),
                  _SuggestionItemFull(
                    title: 'Hybrid Cloud',
                    subtitle: 'Intermédio',
                  ),
                  SizedBox(height: 12),
                  _SuggestionItemFull(
                    title: 'Application Operations',
                    subtitle: 'Especialista',
                  ),
                  SizedBox(height: 12),
                  _SuggestionItemFull(
                    title: 'C++ Mastery',
                    subtitle: 'Sénior',
                  ),
                  SizedBox(height: 12),
                  _SuggestionItemFull(
                    title: 'Data Analytics',
                    subtitle: 'Intermédio',
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

class _SuggestionItemFull extends StatelessWidget {
  const _SuggestionItemFull({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rocket, color: Colors.blue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF243047),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}
