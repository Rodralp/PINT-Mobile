import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_api.dart';
import '../services/auth_session.dart';
import '../services/local_storage.dart';
import 'preferences_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool _loading = false;

  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberedPasswordKey = 'remembered_password';

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _attemptAutoLogin();
  }

  Future<void> _loadRememberedEmail() async {
    final rememberedEmail = await localStorage.getString(_rememberedEmailKey);
    final rememberedPassword = await localStorage.getString(_rememberedPasswordKey);
    final rememberLogin = await AuthSession.shouldRememberLogin();

    if (!mounted) {
      return;
    }

    if ((rememberedEmail == null || rememberedEmail.isEmpty) &&
        (rememberedPassword == null || rememberedPassword.isEmpty) &&
        !rememberLogin) {
      return;
    }

    setState(() {
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        _emailController.text = rememberedEmail;
      }
      if (rememberedPassword != null && rememberedPassword.isNotEmpty) {
        _passwordController.text = rememberedPassword;
      }
      rememberMe = rememberLogin;
    });
  }

  Future<void> _attemptAutoLogin() async {
    final skipAutoLogin = await AuthSession.shouldSkipAutoLoginOnce();
    if (skipAutoLogin) {
      await AuthSession.setSkipAutoLoginOnce(false);
      return;
    }

    final rememberLogin = await AuthSession.shouldRememberLogin();
    if (!rememberLogin) {
      return;
    }

    final accountId = await AuthSession.getAccountId();
    if (accountId == null || accountId <= 0) {
      return;
    }

    final hasPreferences = (await AuthSession.hasPreferences()) ||
        ((await localStorage.getBool(
              PreferencesScreen.firstLoginPreferencesDoneKeyFor(accountId),
            )) ??
            false);

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (hasPreferences) {
        Navigator.pushReplacementNamed(context, '/app');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PreferencesScreen(showBackButton: false),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    if (email.isEmpty || senha.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fillEmailAndPassword)),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final account = await AuthApi.instance.login(email: email, senha: senha);

      final cleanedRoles = account.roles.map((r) => r.trim().toLowerCase()).where((r) => r.isNotEmpty).toList(growable: false);
      final bool isConsultor = cleanedRoles.isNotEmpty
          ? cleanedRoles.contains('consultor')
          : account.role.trim().toLowerCase() == 'consultor';

      if (!isConsultor) {
        if (!mounted) {
          return;
        }
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.mobileOnlyConsultants),
          ),
        );
        return;
      }

      await AuthSession.saveAccount(account);

      if (rememberMe) {
        await localStorage.setString(_rememberedEmailKey, email);
        await localStorage.setString(_rememberedPasswordKey, senha);
      } else {
        await localStorage.remove(_rememberedEmailKey);
        await localStorage.remove(_rememberedPasswordKey);
      }
      await AuthSession.setRememberLogin(rememberMe);

      final hasPreferences =
          account.hasPreferences ||
          (await AuthSession.hasPreferences()) ||
          ((await localStorage.getBool(
                PreferencesScreen.firstLoginPreferencesDoneKeyFor(account.id),
              )) ??
              false);

      if (!mounted) {
        return;
      }

      if (hasPreferences) {
        Navigator.pushReplacementNamed(context, '/app');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PreferencesScreen(showBackButton: false),
          ),
        );
      }
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      final loc = AppLocalizations.of(context)!;
      final message = error.code == 'ACCOUNT_PENDING_APPROVAL'
          ? loc.accountPendingApproval
          : (error.message.isEmpty
                ? loc.loginFailed
                : error.message);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      if (kDebugMode) {
        final details = StringBuffer();
        details.writeln('Message: ${error.message}');
        details.writeln('Status: ${error.statusCode ?? 'N/A'}');
        details.writeln('Code: ${error.code ?? 'N/A'}');
        details.writeln('Body: ${error.responseBody ?? 'N/A'}');

        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Debug: API error'),
            content: SingleChildScrollView(child: Text(details.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(loc.close),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.loginFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<Map<String, String>> _buildTerms(BuildContext context) {
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

  List<Map<String, String>> _buildPrivacyPolicy(BuildContext context) {
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

  Widget _buildTermCard(int index, Map<String, String> term) {
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
                  term['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  term['body']!,
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

  void _showTermsDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final terms = _buildTerms(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
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
                              loc.softinsaBadges,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.termsOfServiceTitle,
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
                    loc.termsOfServiceIntro,
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
                        terms.length,
                        (i) => _buildTermCard(i + 1, terms[i]),
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
                        onPressed: () => Navigator.pop(context),
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
                          loc.acceptTerms,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
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

  void _showPrivacyDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final policy = _buildPrivacyPolicy(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
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
                              loc.softinsaBadges,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.privacyPolicyTitle,
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
                    loc.privacyPolicyIntro,
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
                        policy.length,
                        (i) => _buildTermCard(i + 1, policy[i]),
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
                        onPressed: () => Navigator.pop(context),
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
                          loc.acceptPrivacy,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // LOGO
                Image.asset("assets/images/softinsa.png", width: 220),

                const SizedBox(height: 40),

                // TÍTULO
                Text(
                  loc.loginTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // SUBTÍTULO
                Text(
                  loc.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // CAMPO EMAIL
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: loc.emailHint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // CAMPO PASSWORD
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: loc.passwordHint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CHECKBOX
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(loc.rememberLogin),
                  ],
                ),

                const SizedBox(height: 8),

                // ESQUECEU A SENHA
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      loc.forgotPassword,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÃO CONTINUAR
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitLogin,
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
                            loc.continueButton,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.firstAccess,
                      style: const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        loc.registerLink,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // TEXTO FINAL - "Termos de Serviço" e "Política de Privacidade" são clicáveis
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: '${loc.termsAndPrivacyIntro}\n',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () => _showTermsDialog(context),
                          child: Text(
                            loc.termsOfService,
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ),
                      TextSpan(text: ' ${loc.and} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () => _showPrivacyDialog(context),
                          child: Text(
                            loc.privacyPolicy,
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
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
    );
  }
}
