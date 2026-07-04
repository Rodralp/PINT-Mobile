import 'package:flutter/material.dart';
import '../services/auth_session.dart';
import '../services/consultor_api.dart';
import '../services/reminder_api.dart';
import '../services/reminder_repository.dart';
import 'settings_menu_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'progress_full_screen.dart';
import 'suggestions_full_screen.dart';
import 'reminders_screen.dart';
import 'messages_screen.dart';
import '../widgets/badge_artwork.dart';
import '../widgets/app_top_bar.dart';

class _DashboardMetricData {
  const _DashboardMetricData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Reminder> _dashboardReminders = [];
  bool _isRemindersLoading = true;
  List<_DashboardMetricData> _dashboardMetrics = const [];
  bool _isMetricsLoading = true;
  List<BackendProgressItem> _dashboardProgressItems = const [];
  List<BackendSuggestionItem> _dashboardSuggestions = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboardReminders();
    _loadDashboardMetrics();
  }

  Future<void> _loadDashboardMetrics() async {
    try {
      final accountId = await AuthSession.getAccountId();

      if (!mounted) return;

      if (accountId == null || accountId <= 0) {
        setState(() {
          _dashboardMetrics = _defaultDashboardMetrics;
          _isMetricsLoading = false;
        });
        return;
      }

      final dashboard = await ConsultorApi.instance.fetchConsultorDashboard(
        accountId: accountId,
      );

      if (!mounted) return;

      setState(() {
        _dashboardMetrics = dashboard.stats
            .map(_metricFromBackend)
            .toList(growable: false);
        _dashboardProgressItems = dashboard.inProgressItems;
        _dashboardSuggestions = dashboard.suggestionItems;
        _isMetricsLoading = false;
      });
    } catch (e, stack) {
      debugPrint('[Dashboard] _loadDashboardMetrics error: $e');
      debugPrint('[Dashboard] stack: $stack');
      if (!mounted) return;

      setState(() {
        _dashboardMetrics = _defaultDashboardMetrics;
        _dashboardProgressItems = const [];
        _dashboardSuggestions = const [];
        _isMetricsLoading = false;
      });
    }
  }

  Future<void> _loadDashboardReminders() async {
    try {
      final accountId = await AuthSession.getAccountId();

      if (!mounted) return;

      if (accountId == null || accountId <= 0) {
        setState(() {
          _dashboardReminders = [];
          _isRemindersLoading = false;
        });
        return;
      }

      final reminders = await ReminderRepository.instance.loadReminders(
        accountId: accountId,
      );

      if (!mounted) return;

      setState(() {
        _dashboardReminders = reminders.take(2).toList();
        _isRemindersLoading = false;
      });
    } catch (e, stack) {
      debugPrint('[Dashboard] _loadDashboardReminders error: $e');
      debugPrint('[Dashboard] stack: $stack');
      if (!mounted) return;

      setState(() {
        _dashboardReminders = [];
        _isRemindersLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadDashboardMetrics(),
      _loadDashboardReminders(),
    ]);
  }

  Color _colorStringToColor(String colorStr) {
    switch (colorStr) {
      case 'green':
      case '#4cd07d':
        return const Color(0xFF4cd07d);
      case 'yellow':
      case '#f4c20d':
        return const Color(0xFFF4c20d);
      case 'blue':
      case '#1f8fe5':
        return const Color(0xFF1f8fe5);
      case 'purple':
      case '#9851e8':
        return const Color(0xFF9851e8);
      default:
        return const Color(0xFF4cd07d);
    }
  }

  static const List<_DashboardMetricData> _defaultDashboardMetrics = [
    _DashboardMetricData(
      title: 'Badges Obtidos',
      value: '0',
      subtitle: '0 este mês',
      icon: Icons.stars_rounded,
      iconColor: Colors.orange,
    ),
    _DashboardMetricData(
      title: 'Sequência de Dias',
      value: '0',
      subtitle: 'Recorde: 0 dias',
      icon: Icons.local_fire_department_rounded,
      iconColor: Colors.deepOrange,
    ),
    _DashboardMetricData(
      title: 'Pedidos Pendentes',
      value: '0',
      subtitle: '0 em validação',
      icon: Icons.watch_later,
      iconColor: Colors.blue,
    ),
    _DashboardMetricData(
      title: 'Ranking',
      value: '#0',
      subtitle: '+0 posições este mês',
      icon: Icons.leaderboard,
      iconColor: Colors.amber,
    ),
  ];

  _DashboardMetricData _metricFromBackend(BackendDashboardStat stat) {
    switch (stat.titleKey) {
      case 'dashboard_stat_badges_title':
        return _DashboardMetricData(
          title: 'Badges Obtidos',
          value: stat.value,
          subtitle: '',
          icon: Icons.stars_rounded,
          iconColor: Colors.orange,
        );
      case 'dashboard_stat_streak_title':
        return _DashboardMetricData(
          title: 'Sequência de Dias',
          value: stat.value,
          subtitle: '',
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.deepOrange,
        );
      case 'dashboard_stat_requests_title':
        return _DashboardMetricData(
          title: 'Pedidos Pendentes',
          value: stat.value,
          subtitle: '',
          icon: Icons.watch_later,
          iconColor: Colors.blue,
        );
      case 'dashboard_stat_ranking_title':
        return _DashboardMetricData(
          title: 'Ranking',
          value: stat.value,
          subtitle: '',
          icon: Icons.leaderboard,
          iconColor: Colors.amber,
        );
      default:
        return _DashboardMetricData(
          title: stat.titleKey,
          value: stat.value,
          subtitle: '',
          icon: Icons.circle,
          iconColor: Colors.grey,
        );
    }
  }

  Color _progressAccentFromBackend(String accent) {
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

  IconData _progressIconFromBackend(String iconKey) {
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

  String _progressStatusFromBackend(String iconKey, String accent) {
    final normalizedIcon = iconKey.toLowerCase();
    final normalizedAccent = accent.toLowerCase();

    if (normalizedIcon == 'searchcheck' || normalizedAccent == 'success') {
      return 'aprovado';
    }

    if (normalizedAccent == 'amber') {
      return 'evidencias_insuficientes';
    }

    if (normalizedIcon == 'clock' || normalizedAccent == 'warning') {
      return 'em_validacao';
    }

    return 'em_progresso';
  }

  String _formatReminderDate(String value) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final parts = value.split('-');
    if (parts.length != 3) {
      return value;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null ||
        month == null ||
        day == null ||
        month < 1 ||
        month > 12) {
      return value;
    }

    return '${day.toString().padLeft(2, '0')} ${months[month - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsMenuScreen()),
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
        onMessagesTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesScreen()),
          );
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // METRIC CARDS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: _dashboardMetrics.isEmpty && _isMetricsLoading
                        ? [
                            _buildMetricCard(
                              title: 'A carregar...',
                              value: '—',
                              subtitle: 'A obter dados do dashboard',
                              icon: Icons.sync,
                              iconColor: Colors.grey,
                            ),
                          ]
                        : List.generate(_dashboardMetrics.length, (index) {
                            final metric = _dashboardMetrics[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == _dashboardMetrics.length - 1
                                    ? 0
                                    : 16,
                              ),
                              child: _buildMetricCard(
                                title: metric.title,
                                value: metric.value,
                                subtitle: metric.subtitle,
                                icon: metric.icon,
                                iconColor: metric.iconColor,
                              ),
                            );
                          }),
                  ),
                ),

                const SizedBox(height: 24),

                // LEMBRETES (Reminders)
                _buildSection(
                  title: "Lembretes",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemindersScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      if (_isRemindersLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      else if (_dashboardReminders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Sem lembretes para mostrar.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        )
                      else
                        ...List.generate(_dashboardReminders.length, (index) {
                          final reminder = _dashboardReminders[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _dashboardReminders.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: _buildReminderItem(
                              message: reminder.title,
                              date: _formatReminderDate(reminder.date),
                              barColor: _colorStringToColor(reminder.color),
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // EM PROGRESSO
                _buildSection(
                  title: "Em Progresso",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgressFullScreen(
                          items: _dashboardProgressItems,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: _isMetricsLoading && _dashboardProgressItems.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            ),
                          ]
                        : _dashboardProgressItems.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Sem itens em progresso para mostrar.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ]
                        : List.generate(
                            _dashboardProgressItems.length > 2
                                ? 2
                                : _dashboardProgressItems.length,
                            (index) {
                              final item = _dashboardProgressItems[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index ==
                                              (_dashboardProgressItems.length > 2
                                                  ? 1
                                                  : _dashboardProgressItems.length - 1)
                                          ? 0
                                          : 12,
                                ),
                                child: _buildProgressCard(
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  status: _progressStatusFromBackend(
                                    item.iconKey,
                                    item.accent,
                                  ),
                                  icon: _progressIconFromBackend(item.iconKey),
                                  iconColor: _progressAccentFromBackend(item.accent),
                                  badgeImage: item.badgeImage,
                                  levelKey: item.levelKey,
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // SUGESTÕES
                _buildSection(
                  title: "Sugestões",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuggestionsFullScreen(
                          suggestions: _dashboardSuggestions,
                          isLoading: _isMetricsLoading,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: _isMetricsLoading && _dashboardSuggestions.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ]
                        : _dashboardSuggestions.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Defina as suas preferências para ver sugestões de badges.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ]
                        : List.generate(
                            _dashboardSuggestions.length > 2
                                ? 2
                                : _dashboardSuggestions.length,
                            (index) {
                              final suggestion = _dashboardSuggestions[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index ==
                                          (_dashboardSuggestions.length > 2
                                              ? 1
                                              : _dashboardSuggestions.length - 1)
                                      ? 0
                                      : 12,
                                ),
                                child: _buildBadgeCard(
                                  title: suggestion.title,
                                  subtitleKey: suggestion.subtitleKey,
                                  accent: suggestion.accent,
                                  badgeImage: suggestion.badgeImage,
                                  levelKey: suggestion.levelKey,
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onViewAll,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF243047),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Ver todos",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width:
          170, // Ajustado ligeiramente para caber melhor o conteúdo do Ranking
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: iconColor),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildReminderItem({
    required String message,
    required String date,
    required Color barColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
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

  Widget _buildProgressCard({
    required String title,
    required String subtitle,
    required String status,
    required IconData icon,
    required Color iconColor,
    String? badgeImage,
    String? levelKey,
  }) {
    Color statusColor;

    switch (status) {
      case 'evidencias_insuficientes':
        statusColor = Colors.orange;
        break;
      case 'reprovado':
        statusColor = Colors.red;
        break;
      case 'em_validacao':
        statusColor = Colors.orange;
        break;
      case 'aprovado':
        statusColor = Colors.green;
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: BadgeArtwork(
              size: 50,
              frameColor: iconColor,
              backgroundColor: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              borderWidth: 0,
              iconSize: 28,
              title: title,
              levelKey: levelKey ?? subtitle,
              badgeImage: badgeImage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF243047),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String subtitleKey,
    required String accent,
    String? badgeImage,
    String? levelKey,
  }) {
    final accentColor = _accentColorForSuggestion(accent);
    final subtitle = _badgeLevelLabelFromKey(subtitleKey);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: BadgeArtwork(
              size: 50,
              frameColor: accentColor,
              backgroundColor: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              borderWidth: 0,
              iconSize: 28,
              title: title,
              levelKey: levelKey ?? subtitleKey,
              badgeImage: badgeImage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF243047),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Color _accentColorForSuggestion(String accent) {
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
}
