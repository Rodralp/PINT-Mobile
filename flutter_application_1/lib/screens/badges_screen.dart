import 'package:flutter/material.dart';
import 'app_shell_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import '../widgets/app_top_bar.dart';

enum BadgeState { approved, warning, review }

class _BadgeData {
  const _BadgeData({
    required this.title,
    required this.level,
    required this.points,
    required this.date,
    required this.frameColor,
    required this.iconBackground,
    required this.shape,
    required this.isOwned,
    this.state,
  });

  final String title;
  final String level;
  final int points;
  final String date;
  final Color frameColor;
  final Color iconBackground;
  final BoxShape shape;
  final bool isOwned;
  final BadgeState? state;
}

const List<_BadgeData> _allBadges = [
  _BadgeData(
    title: 'LowCode (Outsystems)',
    level: 'Júnior',
    points: 100,
    date: '12 Jan 2026',
    frameColor: Color(0xFFD67F45),
    iconBackground: Color(0xFFFFE1C9),
    shape: BoxShape.circle,
    isOwned: true,
    state: BadgeState.approved,
  ),
  _BadgeData(
    title: 'LowCode (Outsystems)',
    level: 'Intermédio',
    points: 150,
    date: '12 Jan 2026',
    frameColor: Color(0xFFBFC4CD),
    iconBackground: Color(0xFFF0F0F0),
    shape: BoxShape.rectangle,
    isOwned: false,
  ),
  _BadgeData(
    title: 'LowCode (Outsystems)',
    level: 'Sénior',
    points: 200,
    date: '12 Jan 2026',
    frameColor: Color(0xFFF0C64A),
    iconBackground: Color(0xFFFFF1CB),
    shape: BoxShape.rectangle,
    isOwned: true,
    state: BadgeState.warning,
  ),
  _BadgeData(
    title: 'LowCode (Outsystems)',
    level: 'Especialista',
    points: 250,
    date: '12 Jan 2026',
    frameColor: Color(0xFF9B6CF2),
    iconBackground: Color(0xFFDCC4FF),
    shape: BoxShape.rectangle,
    isOwned: true,
    state: BadgeState.approved,
  ),
  _BadgeData(
    title: 'LowCode (Outsystems)',
    level: 'Líder de Conhecimento',
    points: 300,
    date: '12 Jan 2026',
    frameColor: Color(0xFF39C65A),
    iconBackground: Color(0xFFDDF7E5),
    shape: BoxShape.rectangle,
    isOwned: false,
  ),
  _BadgeData(
    title: 'C++ Mastery',
    level: 'Especialista',
    points: 250,
    date: '12 Jan 2026',
    frameColor: Color(0xFF9B6CF2),
    iconBackground: Color(0xFFDCC4FF),
    shape: BoxShape.rectangle,
    isOwned: true,
    state: BadgeState.approved,
  ),
  _BadgeData(
    title: 'Cloud Architecture',
    level: 'Júnior',
    points: 100,
    date: '12 Jan 2026',
    frameColor: Color(0xFFD67F45),
    iconBackground: Color(0xFFFFE1C9),
    shape: BoxShape.circle,
    isOwned: false,
  ),
  _BadgeData(
    title: 'Cloud Architecture',
    level: 'Intermédio',
    points: 150,
    date: '12 Jan 2026',
    frameColor: Color(0xFFBFC4CD),
    iconBackground: Color(0xFFF0F0F0),
    shape: BoxShape.rectangle,
    isOwned: true,
    state: BadgeState.review,
  ),
];

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ownedBadges = _allBadges.where((badge) => badge.isOwned).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopBar(
                  padding: EdgeInsets.zero,
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
                ),
                const SizedBox(height: 24),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BadgeCatalogScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDDE5EF),
                        width: 1.2,
                      ),
                      color: const Color(0xFFFAFCFF),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Catálogo de Badges Completo',
                            style: TextStyle(
                              fontSize: 28 / 2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[500],
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E6F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey[500],
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pesquisar badges',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _toolbarButton(Icons.filter_alt_outlined),
                    const SizedBox(width: 12),
                    _toolbarButton(Icons.tune_rounded),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 16.0;
                    final itemWidth = (constraints.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: ownedBadges
                          .map(
                            (badge) =>
                                _OwnedBadgeCard(width: itemWidth, badge: badge),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon) {
    return Container(
      width: 66,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 30),
    );
  }
}

class _OwnedBadgeCard extends StatelessWidget {
  const _OwnedBadgeCard({required this.width, required this.badge});

  final double width;
  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    final detail = _lowCodeDetailForBadge(badge);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: detail == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BadgeDetailScreen(badge: badge, detail: detail),
                ),
              );
            },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: _badgeBackgroundColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: badge.frameColor.withOpacity(0.32),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: badge.iconBackground.withOpacity(0.24),
                shape: badge.shape,
                border: Border.all(color: badge.frameColor, width: 5),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 31,
                color: badge.frameColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.level,
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${badge.points} pontos',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              badge.date,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _stateColor(badge.state),
                      width: 1.8,
                    ),
                    color: const Color(0xFFFFFFFF),
                  ),
                  child: Icon(
                    _stateIcon(badge.state),
                    color: _stateColor(badge.state),
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _stateIcon(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return Icons.check_rounded;
      case BadgeState.warning:
        return Icons.warning_amber_rounded;
      case BadgeState.review:
        return Icons.manage_search_outlined;
      case null:
        return Icons.radio_button_unchecked;
    }
  }

  Color _stateColor(BadgeState? state) {
    switch (state) {
      case BadgeState.approved:
        return const Color(0xFF16C524);
      case BadgeState.warning:
        return const Color(0xFFFF3B30);
      case BadgeState.review:
        return const Color(0xFFF7B500);
      case null:
        return const Color(0xFFC7CFD8);
    }
  }

  Color _badgeBackgroundColor() {
    switch (badge.state) {
      case BadgeState.approved:
        return const Color(0xFFF2F8F4);
      case BadgeState.warning:
        return const Color(0xFFFEF5F4);
      case BadgeState.review:
        return const Color(0xFFFFF9ED);
      case null:
        return const Color(0xFFF8FAFC);
    }
  }
}

class BadgeCatalogScreen extends StatelessWidget {
  const BadgeCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Catálogo de Badges',
                      style: TextStyle(
                        fontSize: 48 / 2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243047),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE0E6F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[500],
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Pesquisar badges',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _toolButton(Icons.filter_alt_outlined),
                        const SizedBox(width: 12),
                        _toolButton(Icons.tune_rounded),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 16.0;
                        final itemWidth = (constraints.maxWidth - gap) / 2;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: _allBadges
                              .map(
                                (badge) => _CatalogBadgeCard(
                                  width: itemWidth,
                                  badge: badge,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon) {
    return Container(
      width: 66,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6F0)),
        color: Colors.white,
      ),
      child: Icon(icon, size: 30),
    );
  }
}

class _CatalogBadgeCard extends StatelessWidget {
  const _CatalogBadgeCard({required this.width, required this.badge});

  final double width;
  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    final detail = _lowCodeDetailForBadge(badge);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: detail == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BadgeDetailScreen(badge: badge, detail: detail),
                ),
              );
            },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: _badgeBackgroundColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: badge.iconBackground.withOpacity(0.24),
                shape: badge.shape,
                border: Border.all(color: badge.frameColor, width: 5),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 31,
                color: badge.frameColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.level,
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.emoji_events_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${badge.points} pontos',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    badge.date,
                    style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeBackgroundColor() {
    if (badge.state != null) {
      switch (badge.state!) {
        case BadgeState.approved:
          return const Color(0xFFF2F8F4);
        case BadgeState.warning:
          return const Color(0xFFFEF5F4);
        case BadgeState.review:
          return const Color(0xFFFFF9ED);
      }
    }
    return const Color(0xFFF8FAFC);
  }
}

class _LowCodeDetailData {
  const _LowCodeDetailData({
    required this.statusText,
    required this.statusColor,
    required this.journeyPath,
    required this.description,
    required this.requirements,
  });

  final String statusText;
  final Color statusColor;
  final String journeyPath;
  final String description;
  final List<String> requirements;
}

_LowCodeDetailData? _lowCodeDetailForBadge(_BadgeData badge) {
  if (badge.title != 'LowCode (Outsystems)') {
    return null;
  }

  switch (badge.level) {
    case 'Júnior':
      return const _LowCodeDetailData(
        statusText: 'Conquista obtida',
        statusColor: Color(0xFF16C524),
        journeyPath:
            'Jornada Técnica -> Fundamentos Digitais -> LowCode (Outsystems) -> Nível Júnior',
        description:
            'Nível introdutório focado em noções base de desenvolvimento LowCode, estrutura de aplicações e boas práticas de publicação.',
        requirements: [
          'B1 - Criar aplicação simples com 2 ecrãs e navegação funcional',
          'B2 - Modelar entidades básicas e relacionamentos essenciais',
          'B3 - Publicar versão inicial com validação de dados no formulário',
        ],
      );
    case 'Intermédio':
      return const _LowCodeDetailData(
        statusText: 'Candidatura em progresso',
        statusColor: Color(0xFF1A90F0),
        journeyPath:
            'Jornada Técnica -> Application Operations -> LowCode (Outsystems) -> Nível Intermédio',
        description:
            'Nível intermédio para desenvolvimento de módulos reutilizáveis, integrações simples e monitorização operacional da solução.',
        requirements: [
          'B1 - Implementar conectividade híbrida com serviço externo',
          'B2 - Monitorizar infraestrutura híbrida e tratar falhas comuns',
          'B3 - Implementar disaster recovery para ambiente de testes',
        ],
      );
    case 'Sénior':
      return const _LowCodeDetailData(
        statusText: 'Aguarda validação',
        statusColor: Color(0xFFFF3B30),
        journeyPath:
            'Jornada Técnica -> Application Operations -> LowCode (Outsystems) -> Nível Sénior',
        description:
            'Nível sénior orientado a arquitetura, performance e práticas de escalabilidade para projetos enterprise com equipas multidisciplinares.',
        requirements: [
          'B1 - Definir arquitetura por camadas com separação de responsabilidades',
          'B2 - Otimizar performance de queries e tempos de resposta críticos',
          'B3 - Configurar pipeline de deploy com verificações automáticas',
        ],
      );
    case 'Especialista':
      return const _LowCodeDetailData(
        statusText: 'Em revisão técnica',
        statusColor: Color(0xFFF7B500),
        journeyPath:
            'Jornada Técnica -> Arquitetura de Soluções -> LowCode (Outsystems) -> Nível Especialista',
        description:
            'Nível especialista com foco em governança, padrões corporativos e aceleração de equipas através de componentes reutilizáveis.',
        requirements: [
          'B1 - Definir padrão de referência para componentes reutilizáveis',
          'B2 - Liderar revisão técnica de 3 projetos com plano de melhoria',
          'B3 - Implementar auditoria de segurança e conformidade aplicacional',
        ],
      );
    case 'Líder de Conhecimento':
      return const _LowCodeDetailData(
        statusText: 'Avaliação final de liderança',
        statusColor: Color(0xFF1A90F0),
        journeyPath:
            'Jornada Técnica -> Liderança Técnica -> LowCode (Outsystems) -> Líder de Conhecimento',
        description:
            'Tier máximo de impacto técnico e organizacional, com responsabilidade por estratégia de adoção, mentoria e evolução contínua da prática.',
        requirements: [
          'B1 - Criar roadmap anual de capacitação LowCode para a Service Line',
          'B2 - Mentorar 5 consultores até evolução comprovada de tier',
          'B3 - Publicar framework interno com métricas de qualidade e produtividade',
        ],
      );
  }

  return null;
}

class BadgeDetailScreen extends StatelessWidget {
  const BadgeDetailScreen({
    super.key,
    required this.badge,
    required this.detail,
    this.completedRequirementIndexes = const <int>{},
    this.selectedBottomNavIndex = 1,
  });

  final _BadgeData badge;
  final _LowCodeDetailData detail;
  final Set<int> completedRequirementIndexes;
  final int selectedBottomNavIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Badge',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD9E2EC),
                          width: 1.6,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: badge.iconBackground.withOpacity(0.35),
                              shape: badge.shape,
                              border: Border.all(
                                color: badge.frameColor,
                                width: 10,
                              ),
                            ),
                            child: Icon(
                              Icons.workspace_premium_outlined,
                              size: 74,
                              color: badge.frameColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            badge.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF243047),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nível ${badge.level}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF243047),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _metaItem(Icons.schedule, 'Expira ${badge.date}'),
                              _metaItem(
                                Icons.emoji_events_outlined,
                                '${badge.points} pontos',
                              ),
                              _metaItem(
                                Icons.description_outlined,
                                '${detail.requirements.length} requisitos',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: detail.statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: detail.statusColor,
                                width: 1.6,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timelapse,
                                  color: detail.statusColor,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    detail.statusText,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: detail.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      detail.journeyPath,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD9E2EC),
                          width: 1.6,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Requisitos',
                            style: TextStyle(
                              fontSize: 24 / 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...detail.requirements.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      completedRequirementIndexes.contains(
                                            entry.key,
                                          )
                                          ? Icons.check_circle
                                          : Icons.visibility,
                                      size: 24,
                                      color:
                                          completedRequirementIndexes.contains(
                                            entry.key,
                                          )
                                          ? const Color(0xFF16C524)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD9E2EC),
                          width: 1.6,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descrição',
                            style: TextStyle(
                              fontSize: 24 / 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              detail.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                                height: 1.4,
                              ),
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
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedBottomNavIndex,
          onDestinationSelected: (index) {
            if (index == selectedBottomNavIndex) {
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

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class LowCodeSeniorProgressScreen extends StatelessWidget {
  const LowCodeSeniorProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const seniorBadge = _BadgeData(
      title: 'LowCode (Outsystems)',
      level: 'Sénior',
      points: 200,
      date: '12 Jan 2026',
      frameColor: Color(0xFFF0C64A),
      iconBackground: Color(0xFFFFF7D7),
      shape: BoxShape.circle,
      isOwned: false,
      state: BadgeState.warning,
    );

    final seniorDetail = _lowCodeDetailForBadge(seniorBadge);
    if (seniorDetail == null) {
      return const SizedBox.shrink();
    }

    final progressDetail = _LowCodeDetailData(
      statusText: 'Candidatura em progresso (1/3)',
      statusColor: const Color(0xFF1A90F0),
      journeyPath: seniorDetail.journeyPath,
      description: seniorDetail.description,
      requirements: seniorDetail.requirements,
    );

    return BadgeDetailScreen(
      badge: seniorBadge,
      detail: progressDetail,
      completedRequirementIndexes: const {0},
      selectedBottomNavIndex: 2,
    );
  }
}
