import 'package:flutter/material.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';

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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsMenuScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined, size: 32),
                    ),
                    Image.asset(
                      'assets/images/softinsa.png',
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsFullScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_none, size: 32),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF00A8), Color(0xFFFF0075), Color(0xFFFF2A00)],
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ServiceLineCard(
                  title: 'Hybrid Cloud',
                  subtitle:
                      'Aprender Hybrid Cloud envolve bases de arquitetura, segurança e gestão, e uso...',
                  progress: 0.4,
                  footerText: '2 de 5 badges obtidas',
                  progressColor: Color(0xFF1A90F0),
                  imageLabel: 'HC',
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
  });

  final String title;
  final String subtitle;
  final double progress;
  final String footerText;
  final Color progressColor;
  final String imageLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const Icon(Icons.chevron_right, color: Color(0xFF1A90F0), size: 38),
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
                          fontWeight:
                              progress >= 1 ? FontWeight.w700 : FontWeight.w500,
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
    );
  }
}
