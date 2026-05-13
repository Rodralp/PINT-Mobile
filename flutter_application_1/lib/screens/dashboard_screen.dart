import 'package:flutter/material.dart';
import 'settings_menu_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'progress_full_screen.dart';
import 'suggestions_full_screen.dart';
import 'reminders_screen.dart';
import '../widgets/app_top_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
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
      body: SingleChildScrollView(
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
                  children: [
                    _buildMetricCard(
                      title: "Badges Obtidos",
                      value: "12",
                      subtitle: "2 este mês",
                      icon: Icons.stars_rounded,
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildMetricCard(
                      title: "Sequência de Dias",
                      value: "4",
                      subtitle: "Recorde: 8 dias",
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.deepOrange,
                    ),
                    const SizedBox(width: 16),
                    _buildMetricCard(
                      title: "Pedidos Pendentes",
                      value: "5",
                      subtitle: "2 concluídos",
                      icon: Icons.watch_later,
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildMetricCard(
                      title: "Ranking",
                      value: "#15",
                      subtitle: "+3 posições este mês",
                      icon: Icons.leaderboard,
                      iconColor: Colors.amber,
                    ),
                  ],
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
                    _buildReminderItem(
                      message: "Conferir requisitos enviados.",
                      date: "07 Dez 2025",
                      barColor: Colors.greenAccent[400]!,
                    ),
                    const SizedBox(height: 12),
                    _buildReminderItem(
                      message: "Badge \"C++ Mastery\" expira em 30 dias.",
                      date: "29 Nov 2025",
                      barColor: Colors.amber,
                    ),
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
                      builder: (context) => const ProgressFullScreen(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    _buildProgressCard(
                      title: "LowCode (Outsystems)",
                      subtitle: "Especialista",
                      status: "reprovado",
                    ),
                    const SizedBox(height: 12),
                    _buildProgressCard(
                      title: "LowCode (Outsystems)",
                      subtitle: "Sénior",
                      status: "em_validacao",
                    ),
                  ],
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
                      builder: (context) => const SuggestionsFullScreen(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    _buildBadgeCard(
                      title: "LowCode (Outsystems)",
                      subtitle: "Líder de Conhecimento",
                      icon: Icons.hexagon_outlined,
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildBadgeCard(
                      title: "Cloud Architecture",
                      subtitle: "Especialista",
                      icon: Icons.hexagon_outlined,
                      iconColor: Colors.purple,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required VoidCallback onViewAll, required Widget child}) {
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
      width: 170, // Ajustado ligeiramente para caber melhor o conteúdo do Ranking
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
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
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
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
  }) {
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'reprovado':
        statusIcon = Icons.report_problem_outlined;
        statusColor = Colors.red;
        break;
      case 'em_validacao':
        statusIcon = Icons.search;
        statusColor = Colors.orange;
        break;
      case 'em_progresso':
      default:
        statusIcon = Icons.access_time;
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hexagon, color: Colors.deepPurple, size: 24),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
