import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_session.dart';
import '../services/locale_service.dart';
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
  void _showLanguageSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: LocaleService.instance.localeNotifier,
          builder: (context, currentLocale, _) {
            final currentCode = currentLocale?.languageCode ?? 'pt';
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.selectLanguage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLanguageOption(ctx, 'pt', loc.portuguese, currentCode),
                  _buildLanguageOption(ctx, 'en', loc.english, currentCode),
                  _buildLanguageOption(ctx, 'es', loc.spanish, currentCode),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext ctx,
    String code,
    String label,
    String currentCode,
  ) {
    final isSelected = currentCode == code;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF2563EB))
          : null,
      onTap: () {
        LocaleService.instance.setLanguage(code);
        Navigator.pop(ctx);
      },
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
                  Text(
                    AppLocalizations.of(context)!.settingsTitle,
                    style: const TextStyle(
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
                  _SettingsOptionTile(
                    icon: Icons.person_outline,
                    title: AppLocalizations.of(context)!.accountOption,
                    subtitle: AppLocalizations.of(context)!.accountOptionSubtitle,
                  ),
                  _SettingsOptionTile(
                    icon: Icons.lock_outline,
                    title: AppLocalizations.of(context)!.securityOption,
                    subtitle: AppLocalizations.of(context)!.securityOptionSubtitle,
                  ),
                  _SettingsOptionTile(
                    icon: Icons.tune_rounded,
                    title: AppLocalizations.of(context)!.preferencesOption,
                    subtitle: AppLocalizations.of(context)!.preferencesOptionSubtitle,
                  ),
                  _SettingsOptionTile(
                    icon: Icons.notifications_outlined,
                    title: AppLocalizations.of(context)!.notificationsOption,
                    subtitle: AppLocalizations.of(context)!.notificationsOptionSubtitle,
                  ),
                  _SettingsOptionTile(
                    icon: Icons.language,
                    title: AppLocalizations.of(context)!.languageOption,
                    subtitle: AppLocalizations.of(context)!.languageOptionSubtitle,
                    onTapCustom: () => _showLanguageSheet(context),
                  ),

                  _SettingsOptionTile(
                    icon: Icons.logout,
                    title: AppLocalizations.of(context)!.logoutOption,
                    subtitle: AppLocalizations.of(context)!.logoutOptionSubtitle,
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
    this.onTapCustom,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTapCustom;

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
              Text(
                AppLocalizations.of(parentContext)!.logoutTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(parentContext)!.logoutConfirm,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                      child: Text(
                        AppLocalizations.of(parentContext)!.cancel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                      child: Text(
                        AppLocalizations.of(parentContext)!.logoutButton,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
            if (onTapCustom != null) {
              onTapCustom!();
              return;
            }
            if (title == AppLocalizations.of(context)!.accountOption) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountInfoScreen(),
                ),
              );
              return;
            }
            if (title == AppLocalizations.of(context)!.securityOption) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
              return;
            }
            if (title == AppLocalizations.of(context)!.preferencesOption) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreferencesScreen(),
                ),
              );
              return;
            }
            if (title == AppLocalizations.of(context)!.notificationsOption) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPreferencesScreen(),
                ),
              );
              return;
            }
            if (title == AppLocalizations.of(context)!.logoutOption) {
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
