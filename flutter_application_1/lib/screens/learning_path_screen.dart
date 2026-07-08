import 'dart:async';
import 'package:flutter/material.dart';
import '../services/consultor_api.dart';
import '../services/auth_session.dart';
import '../services/learning_path_repository.dart';
import '../widgets/app_top_bar.dart';
import 'settings_menu_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'service_line_screen.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  late Future<List<BackendLearningPath>> _loadPathsFuture;
  List<BackendLearningPath> _learningPaths = [];
  String? _selectedPathId;
  final Set<String> _expandedPathIds = {};

  @override
  void initState() {
    super.initState();
    _loadPathsFuture = _loadInitialData();
  }

  Future<void> _refreshLearningPaths() async {
    setState(() {
      _loadPathsFuture = _loadInitialData();
    });
    await _loadPathsFuture;
  }

  Future<List<BackendLearningPath>> _loadInitialData() async {
    final accountId = await AuthSession.getAccountId();
    if (accountId == null) return [];
    
    final paths = await LearningPathRepository.instance.loadLearningPaths(
      accountId: accountId,
    );
    if (paths.isNotEmpty) {
      setState(() {
        _learningPaths = paths;
        _selectedPathId = paths.first.id;
        for (var p in paths) {
          _expandedPathIds.add(p.id);
        }
      });
    }
    return paths;
  }

  void _togglePath(String id) {
    setState(() {
      if (_expandedPathIds.contains(id)) {
        _expandedPathIds.remove(id);
      } else {
        _expandedPathIds.add(id);
      }
    });
  }

  _ProgressInfo _calculateProgress(List<BackendLevel> levels) {
    if (levels.isEmpty) return const _ProgressInfo(total: 0, obtained: 0, percent: 0, label: '0 badges');
    final obtained = levels.where((level) => level.status == 'obtido').length;
    final total = levels.length;
    final percent = total > 0 ? obtained / total : 0.0;
    return _ProgressInfo(
      total: total,
      obtained: obtained,
      percent: percent,
      label: '$obtained de $total badges obtidas',
    );
  }

  String? _resolveServiceLineImage(String? path) {
    if (path == null) return null;
    if (path.toLowerCase().contains('lp_bg')) return 'assets/images/lp_bg.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onSettingsTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsMenuScreen())),
        onNotificationsTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsFullScreen())),
        onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen())),
        onMessagesTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MessagesScreen())),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLearningPaths,
        child: FutureBuilder<List<BackendLearningPath>>(
          future: _loadPathsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            return _buildLearningPathList(context);
          },
        ),
      ),
    );
  }

  Widget _buildLearningPathList(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          for (final path in _learningPaths) ...[
            _buildPathHeader(path),
            if (_expandedPathIds.contains(path.id))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      for (final line in path.serviceLines)
                        _buildServiceLineCard(path, line),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildPathHeader(BackendLearningPath path) {
    final isExpanded = _expandedPathIds.contains(path.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _togglePath(path.id),
        borderRadius: isExpanded 
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: isExpanded 
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF9800),
                Color(0xFFF06292),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  path.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceLineCard(BackendLearningPath path, BackendServiceLine line) {
    final levels = line.areas.expand((a) => a.levels).toList();
    final progress = _calculateProgress(levels);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: _ServiceLineCard(
        title: line.name,
        subtitle: line.description,
        progress: progress.percent,
        footerText: progress.label,
        progressColor: progress.percent >= 1 ? Colors.green : Colors.blue,
        imageLabel: line.name.substring(0, 1),
        imageAsset: _resolveServiceLineImage(line.image),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceLineScreen(line: line),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressInfo {
  const _ProgressInfo({required this.total, required this.obtained, required this.percent, required this.label});
  final int total, obtained;
  final double percent;
  final String label;
}

class _ServiceLineCard extends StatelessWidget {
  const _ServiceLineCard({required this.title, required this.subtitle, required this.progress, required this.footerText, required this.progressColor, required this.imageLabel, this.imageAsset, this.onTap});
  final String title, subtitle, footerText, imageLabel;
  final double progress;
  final Color progressColor;
  final String? imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                color: progressColor,
                backgroundColor: const Color(0xFFE2E5EA),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              footerText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
