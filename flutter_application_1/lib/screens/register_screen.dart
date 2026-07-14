import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_api.dart';
import '../theme/softinsa_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _hasAcceptedRgpd = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fillAllFields),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch)),
      );
      return;
    }

    if (!_hasAcceptedRgpd) {
      final hasAccepted = await _showRgpdConsentDialog();
      if (!hasAccepted || !mounted) {
        return;
      }

      setState(() {
        _hasAcceptedRgpd = true;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthApi.instance.register(
        nome: name,
        email: email,
        senha: password,
      );

      if (!mounted) {
        return;
      }

      await _showRequestSentDialog();
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message.isEmpty
          ? AppLocalizations.of(context)!.createAccountFailed
          : error.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.createAccountFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showRequestSentDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: SoftinsaColors.blue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: SoftinsaColors.blue,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.requestSentSuccess,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SoftinsaColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.requestSentDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SoftinsaColors.textMuted, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SoftinsaColors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.backToHome,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showRgpdConsentDialog() async {
    List<Map<String, String>> topics = [];
    bool loading = true;
    String? error;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            if (loading && topics.isEmpty && error == null) {
              AuthApi.instance.fetchRgpdTopics().then((data) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    topics = data;
                    loading = false;
                  });
                }
              }).catchError((_) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    loading = false;
                    error = 'Erro ao carregar termos.';
                  });
                }
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 640, maxWidth: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: SoftinsaColors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.rgpdTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: SoftinsaColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    Flexible(
                      child: loading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : error != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: topics.map((topic) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              topic['title'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: SoftinsaColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              topic['body'] ?? '',
                                              style: const TextStyle(
                                                color: SoftinsaColors.textMuted,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.pop(dialogContext, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SoftinsaColors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(AppLocalizations.of(context)!.accept),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    return accepted ?? false;
  }

  List<Map<String, String>> _termsSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      {
        'title': loc.termsAcceptanceTitle,
        'body': loc.termsAcceptanceBody,
      },
      {
        'title': loc.termsUsersTitle,
        'body': loc.termsUsersBody,
      },
      {
        'title': loc.termsAccountTitle,
        'body': loc.termsAccountBody,
      },
      {
        'title': loc.termsEvidenceTitle,
        'body': loc.termsEvidenceBody,
      },
      {
        'title': loc.termsValidationTitle,
        'body': loc.termsValidationBody,
      },
      {
        'title': loc.termsBadgesTitle,
        'body': loc.termsBadgesBody,
      },
      {
        'title': loc.termsSharingTitle,
        'body': loc.termsSharingBody,
      },
      {
        'title': loc.termsGamificationTitle,
        'body': loc.termsGamificationBody,
      },
      {
        'title': loc.termsNotificationsTitle,
        'body': loc.termsNotificationsBody,
      },
      {
        'title': loc.termsProhibitedTitle,
        'body': loc.termsProhibitedBody,
      },
      {
        'title': loc.termsSuspensionTitle,
        'body': loc.termsSuspensionBody,
      },
      {
        'title': loc.termsChangesTitle,
        'body': loc.termsChangesBody,
      },
      {
        'title': loc.termsLawTitle,
        'body': loc.termsLawBody,
      },
    ];
  }

  List<Map<String, String>> _privacySections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      {
        'title': loc.privacyDataTitle,
        'body': loc.privacyDataBody,
      },
      {
        'title': loc.privacyCollectTitle,
        'body': loc.privacyCollectBody,
      },
      {
        'title': loc.privacyUseTitle,
        'body': loc.privacyUseBody,
      },
      {
        'title': loc.privacyLegalTitle,
        'body': loc.privacyLegalBody,
      },
      {
        'title': loc.privacyShareTitle,
        'body': loc.privacyShareBody,
      },
      {
        'title': loc.privacyBadgePageTitle,
        'body': loc.privacyBadgePageBody,
      },
      {
        'title': loc.privacyRetentionTitle,
        'body': loc.privacyRetentionBody,
      },
      {
        'title': loc.privacyRightsTitle,
        'body': loc.privacyRightsBody,
      },
      {
        'title': loc.privacyProtectTitle,
        'body': loc.privacyProtectBody,
      },
      {
        'title': loc.privacyMinorsTitle,
        'body': loc.privacyMinorsBody,
      },
    ];
  }

  void _showLegalDialog({
    required BuildContext context,
    required String title,
    required String intro,
    required List<Map<String, String>> sections,
    required String acceptLabel,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 650, maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.softinsaBadges,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Text(
                    intro,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: List.generate(
                        sections.length,
                        (i) => _buildLegalCard(i + 1, sections[i]),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          acceptLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTermsDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    _showLegalDialog(
      context: context,
      title: loc.termsOfServiceTitle,
      intro: loc.termsOfServiceIntro,
      sections: _termsSections(context),
      acceptLabel: loc.acceptTerms,
    );
  }

  Future<void> _showPrivacyDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    _showLegalDialog(
      context: context,
      title: loc.privacyPolicyTitle,
      intro: loc.privacyPolicyIntro,
      sections: _privacySections(context),
      acceptLabel: loc.acceptPrivacy,
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: SoftinsaColors.textMuted,
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SoftinsaColors.border),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: SoftinsaColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required bool obscureText,
    required TextEditingController controller,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SoftinsaColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: SoftinsaColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade500,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  Widget _buildLegalCard(int index, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['body']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SoftinsaColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER COM LOGO
                    Center(
                      child: Image.asset(
                        'assets/images/softinsa.png',
                        width: 220,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // TÍTULO
                    Text(
                      AppLocalizations.of(context)!.registerTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: SoftinsaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SUBTÍTULO
                    Text(
                      AppLocalizations.of(context)!.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: SoftinsaColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CAMPO NOME
                    _buildLabel(AppLocalizations.of(context)!.fullNameLabel),
                    const SizedBox(height: 10),
                    _buildInputField(
                      hintText: AppLocalizations.of(context)!.fullNameHint,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),

                    // CAMPO EMAIL
                    _buildLabel(AppLocalizations.of(context)!.emailLabel),
                    const SizedBox(height: 10),
                    _buildInputField(
                      hintText: 'email@dominio.com',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),

                    // CAMPO PALAVRA-PASSE
                    _buildLabel(AppLocalizations.of(context)!.passwordLabel),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      hintText: AppLocalizations.of(context)!.passwordDefineHint,
                      obscureText: obscurePassword,
                      controller: _passwordController,
                      onToggle: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // CAMPO CONFIRMAR PALAVRA-PASSE
                    _buildLabel(AppLocalizations.of(context)!.confirmPasswordLabel),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      hintText: AppLocalizations.of(context)!.confirmPasswordHint,
                      obscureText: obscureConfirmPassword,
                      controller: _confirmPasswordController,
                      onToggle: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 28),

                    // BOTÃO CONFIRMAR
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submitRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
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
                            : Text(
                                AppLocalizations.of(context)!.confirmButton,
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LINK PARA LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hasAccount,
                          style: const TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.loginLink,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // TERMS E PRIVACY
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: '${AppLocalizations.of(context)!.termsAndPrivacyIntro}\n',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => _showTermsDialog(context),
                              child: Text(
                                AppLocalizations.of(context)!.termsOfService,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(text: ' ${AppLocalizations.of(context)!.and} '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => _showPrivacyDialog(context),
                              child: Text(
                                AppLocalizations.of(context)!.privacyPolicy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
