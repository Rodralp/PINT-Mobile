import 'package:flutter/material.dart';
import '../services/auth_session.dart';
import '../services/backend_config.dart';
import 'account_info_screen.dart';
import 'notification_preferences_screen.dart';
import 'preferences_screen.dart';
import 'change_password_screen.dart';

class SettingsMenuScreen extends StatefulWidget {
  const SettingsMenuScreen({super.key});

  @override
  State<SettingsMenuScreen> createState() => _SettingsMenuScreenState();
}

class _SettingsMenuScreenState extends State<SettingsMenuScreen> {
  final TextEditingController _backendUrlController = TextEditingController();

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  Future<void> _showBackendConfigDialog() async {
    final currentBaseUrl = await BackendConfig.getBaseUrl();
    if (!mounted) {
      return;
    }

    _backendUrlController.text = currentBaseUrl;
    final savedUrl = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Configurar servidor'),
        content: TextField(
          controller: _backendUrlController,
          decoration: const InputDecoration(
            labelText: 'API base URL',
            hintText: 'http://10.65.8.74:4000/api',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              var input = _backendUrlController.text.trim();
              if (input.isEmpty) {
                Navigator.pop(dialogContext);
                return;
              }

              if (!input.startsWith('http://') && !input.startsWith('https://')) {
                input = 'http://$input';
              }

              while (input.endsWith('/')) {
                input = input.substring(0, input.length - 1);
              }

              if (!input.contains('/api')) {
                input = '$input/api';
              }

              final uri = Uri.tryParse(input);
              if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https') || (uri.host.isEmpty)) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('URL inválida. Introduza uma URL válida, e.g. http://10.65.8.74:4000/api')),
                );
                return;
              }

              Navigator.pop(dialogContext, input);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted || savedUrl == null) {
      return;
    }

    await BackendConfig.setBaseUrl(savedUrl);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servidor guardado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Definições',
                    style: TextStyle(
                      fontSize: 42 / 2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _SettingsOptionTile(
                    icon: Icons.person_outline,
                    title: 'Conta',
                    subtitle: 'Dados da conta e atalhos',
                  ),
                  const _SettingsOptionTile(
                    icon: Icons.lock_outline,
                    title: 'Segurança',
                    subtitle: 'Alterar senha de acesso',
                  ),
                  const _SettingsOptionTile(
                    icon: Icons.tune_rounded,
                    title: 'Preferências',
                    subtitle: 'Áreas de interesse e recomendações',
                  ),
                  const _SettingsOptionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: 'Alertas e comunicações',
                  ),
                  _SettingsOptionTile(
                    icon: Icons.dns_outlined,
                    title: 'Servidor',
                    subtitle: 'Configurar API base URL',
                    onTap: _showBackendConfigDialog,
                  ),
                  const _SettingsOptionTile(
                    icon: Icons.logout,
                    title: 'Terminar Sessão',
                    subtitle: 'Terminar sessão e navegação',
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

class _SettingsOptionTile extends StatelessWidget {
  const _SettingsOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  void _showLogoutDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app,
                  color: Color(0xFFDC2626),
                  size: 48,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Terminar Sessão',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pretende terminar a sua sessão?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancelar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await AuthSession.setSkipAutoLoginOnce(true);
                        await AuthSession.clearSession();
                        if (!parentContext.mounted) {
                          return;
                        }
                        Navigator.pushNamedAndRemoveUntil(
                          parentContext,
                          '/login',
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Terminar Sessão',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (onTap != null) {
              onTap!();
              return;
            }
            if (title == 'Conta') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountInfoScreen(),
                ),
              );
              return;
            }
            if (title == 'Segurança') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
              return;
            }
            if (title == 'Preferências') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreferencesScreen(),
                ),
              );
              return;
            }
            if (title == 'Notificações') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPreferencesScreen(),
                ),
              );
              return;
            }
            if (title == 'Terminar Sessão') {
              _showLogoutDialog(context);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4EAF2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE4EAF2)),
                ),
                child: Icon(icon, size: 22, color: const Color(0xFF374151)),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 28,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
