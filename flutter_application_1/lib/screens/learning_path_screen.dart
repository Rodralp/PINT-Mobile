import 'package:flutter/material.dart';
import 'app_shell_screen.dart';
import 'badges_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import '../widgets/app_top_bar.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF00A8),
                      Color(0xFFFF0075),
                      Color(0xFFFF2A00),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Text(
                  'Jornada Técnica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 46 / 2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  'Service Lines',
                  style: TextStyle(
                    fontSize: 38 / 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ServiceLineCard(
                  title: 'Hybrid Cloud',
                  subtitle:
                      'Aprender Hybrid Cloud envolve bases de arquitetura, segurança e gestão, e uso...',
                  progress: 0.4,
                  footerText: '2 de 5 badges obtidas',
                  progressColor: Color(0xFF1A90F0),
                  imageLabel: 'HC',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HybridCloudPathScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ServiceLineCard(
                  title: 'Application Operations',
                  subtitle:
                      'Aprender Hybrid Cloud envolve bases de arquitetura, segurança e gestão, e uso...',
                  progress: 0.0,
                  footerText: '0 de 5 badges obtidas',
                  progressColor: Color(0xFF1A90F0),
                  imageLabel: 'AO',
                  onTap: null,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ServiceLineCard(
                  title: 'Sourcing & Talent Management',
                  subtitle:
                      'Aprender Hybrid Cloud envolve bases de arquitetura, segurança e gestão, e uso...',
                  progress: 1.0,
                  footerText: 'Service Line Completada',
                  progressColor: Color(0xFF39C65A),
                  imageLabel: 'STM',
                  onTap: null,
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
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
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String footerText;
  final Color progressColor;
  final String imageLabel;
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
                    child: Text(
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
                                  builder: (context) =>
                                      const HybridCloudBadgeDetailScreen(
                                        levelTitle: 'Nível Júnior',
                                        levelCode: 'Nível A',
                                      ),
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
                                  builder: (context) =>
                                      const HybridCloudBadgeDetailScreen(
                                        levelTitle: 'Nível Intermédio',
                                        levelCode: 'Nível B',
                                      ),
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
                                  builder: (context) =>
                                      const LowCodeSeniorProgressScreen(),
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

class HybridCloudBadgeDetailScreen extends StatelessWidget {
  const HybridCloudBadgeDetailScreen({
    super.key,
    required this.levelTitle,
    required this.levelCode,
  });

  final String levelTitle;
  final String levelCode;

  @override
  Widget build(BuildContext context) {
    const requirements = [
      'B1 - Fundamentos de arquitetura híbrida concluídos',
      'B2 - Segurança e conectividade em cloud híbrida concluídas',
      'B3 - Gestão operacional e observabilidade concluídas',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          'Badge',
          style: TextStyle(
            color: Color(0xFF243047),
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
            ),
            child: Column(
              children: [
                Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE9F4FF),
                    border: Border.all(
                      color: const Color(0xFF1A90F0),
                      width: 8,
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_done_outlined,
                    color: Color(0xFF1A90F0),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hybrid Cloud',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF243047),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$levelTitle ($levelCode)',
                  style: const TextStyle(
                    fontSize: 19,
                    color: Color(0xFF243047),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF16C524),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF16C524)),
                      SizedBox(width: 8),
                      Text(
                        'Concluído',
                        style: TextStyle(
                          color: Color(0xFF16C524),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD9E2EC), width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requisitos',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...requirements.map(
                  (item) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5EAF0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF16C524),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
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
