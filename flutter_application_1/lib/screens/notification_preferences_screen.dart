import 'package:flutter/material.dart';

import '../services/auth_session.dart';
import '../services/local_storage.dart';
import '../theme/softinsa_theme.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  static const bool _defaultEmailUpdates = true;
  static const bool _defaultInAppAlerts = true;
  static const bool _defaultWeeklySummary = false;

  bool _emailUpdates = _defaultEmailUpdates;
  bool _inAppAlerts = _defaultInAppAlerts;
  bool _weeklySummary = _defaultWeeklySummary;
  bool _isLoading = true;
  bool _isSaving = false;
  int? _accountId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String _storageKey(String name, [int? accountId]) {
    final resolvedAccountId = accountId ?? _accountId;
    final suffix = resolvedAccountId != null && resolvedAccountId > 0
        ? resolvedAccountId.toString()
        : 'default';
    return 'notification_preferences:$suffix:$name';
  }

  Future<void> _loadPreferences() async {
    final accountId = await AuthSession.getAccountId();
    final emailUpdates =
        await localStorage.getBool(_storageKey('email_updates', accountId)) ??
            _defaultEmailUpdates;
    final inAppAlerts =
        await localStorage.getBool(_storageKey('in_app_alerts', accountId)) ??
            _defaultInAppAlerts;
    final weeklySummary =
        await localStorage.getBool(_storageKey('weekly_summary', accountId)) ??
            _defaultWeeklySummary;

    if (!mounted) {
      return;
    }

    setState(() {
      _accountId = accountId;
      _emailUpdates = emailUpdates;
      _inAppAlerts = inAppAlerts;
      _weeklySummary = weeklySummary;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await localStorage.setBool(_storageKey('email_updates'), _emailUpdates);
      await localStorage.setBool(_storageKey('in_app_alerts'), _inAppAlerts);
      await localStorage.setBool(_storageKey('weekly_summary'), _weeklySummary);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferências guardadas com sucesso.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao guardar preferências.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetDefaults() {
    setState(() {
      _emailUpdates = _defaultEmailUpdates;
      _inAppAlerts = _defaultInAppAlerts;
      _weeklySummary = _defaultWeeklySummary;
    });
  }

  Future<void> _refreshPreferences() async {
    setState(() {
      _isLoading = true;
    });
    await _loadPreferences();
  }

  void _toggleEmailUpdates(bool value) {
    setState(() {
      _emailUpdates = value;
    });
  }

  void _toggleInAppAlerts(bool value) {
    setState(() {
      _inAppAlerts = value;
    });
  }

  void _toggleWeeklySummary(bool value) {
    setState(() {
      _weeklySummary = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPreferences,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
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
                        'Notificações',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF243047),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure as suas preferências de notificação.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 26),
                  _SettingCard(
                    label: 'Receber atualizações por email',
                    value: _emailUpdates,
                    onChanged: _isLoading || _isSaving ? null : _toggleEmailUpdates,
                  ),
                  const SizedBox(height: 14),
                  _SettingCard(
                    label: 'Receber alertas dentro da plataforma',
                    value: _inAppAlerts,
                    onChanged: _isLoading || _isSaving ? null : _toggleInAppAlerts,
                  ),
                  const SizedBox(height: 14),
                  _SettingCard(
                    label: 'Receber resumo semanal',
                    value: _weeklySummary,
                    onChanged: _isLoading || _isSaving ? null : _toggleWeeklySummary,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Guardar alterações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading || _isSaving ? null : _resetDefaults,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F2937),
                        side: const BorderSide(
                          color: Color(0xFFD7DDE7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Repor padrão',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4EAF2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF243047),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: enabled ? (v) => onChanged!(v) : null,
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4EAF2), width: 1),
      ),
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue, size: 22),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[600],
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: value,
              onChanged: enabled ? (newValue) => onChanged!(newValue ?? false) : null,
              activeColor: Colors.blue,
              side: const BorderSide(color: Color(0xFFB8C2D1), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
