import 'package:flutter/material.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
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

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos para continuar.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As palavras-passe não coincidem.')),
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

      final message = error.message.isEmpty ? 'Não foi possível criar a conta.' : error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível criar a conta.')),
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
                child: const Icon(Icons.check_rounded, color: SoftinsaColors.blue, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pedido enviado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SoftinsaColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Um administrador irá verificar os seus dados e ativar a sua conta em breve.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SoftinsaColors.textMuted, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SoftinsaColors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Voltar para Home',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
    bool isChecked = false;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 640, maxWidth: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                    child: Row(
                      children: const [
                        Icon(Icons.verified_user_outlined, color: SoftinsaColors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Aceitação dos Termos RGPD',
                            style: TextStyle(
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Para utilizar a plataforma de badges da Softinsa, necessitamos do seu consentimento para a publicação e partilha dos seus badges.',
                            style: TextStyle(color: SoftinsaColors.textMuted, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Os seus badges poderão ser visualizados por outros consultores e gestores da empresa, permitindo o reconhecimento das suas competências e progressão profissional.',
                            style: TextStyle(color: SoftinsaColors.textMuted, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ao aceitar, concorda com o tratamento dos seus dados pessoais de acordo com o Regulamento Geral de Proteção de Dados (RGPD).',
                            style: TextStyle(color: SoftinsaColors.textMuted, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  setDialogState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'Li e aceito os termos RGPD.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isChecked ? () => Navigator.pop(dialogContext, true) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SoftinsaColors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Aceitar'),
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
      ),
    );

    return accepted ?? false;
  }

  Future<void> _showTermsDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Termos de Serviço'),
        content: const Text(
          'A utilização da aplicação está reservada a colaboradores autorizados e conta ativa.',
          style: TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: const Text(
          'Os seus dados são usados apenas para autenticação, gestão de badges e preferências da plataforma.',
          style: TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey.shade500,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoftinsaColors.surfaceAlt,
      body: Container(
        decoration: const BoxDecoration(gradient: SoftinsaColors.brandGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/softinsa.png',
                                width: 34,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SOFTINSA BADGES',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Criar conta de consultor',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: SoftinsaColors.border),
                          boxShadow: SoftinsaShadows.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Criar conta',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: SoftinsaColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Insira os seus dados e aguarde a validação da equipa.',
                              style: TextStyle(color: SoftinsaColors.textMuted),
                            ),
                            const SizedBox(height: 22),
                            _buildLabel('Nome'),
                            const SizedBox(height: 8),
                            _buildInputField(hintText: 'Nome completo', controller: _nameController),
                            const SizedBox(height: 16),
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _buildInputField(hintText: 'email@dominio.com', controller: _emailController),
                            const SizedBox(height: 16),
                            _buildLabel('Palavra-passe'),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              hintText: 'Palavra-passe',
                              obscureText: obscurePassword,
                              controller: _passwordController,
                              onToggle: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Confirmar palavra-passe'),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              hintText: 'Confirmar palavra-passe',
                              obscureText: obscureConfirmPassword,
                              controller: _confirmPasswordController,
                              onToggle: () {
                                setState(() {
                                  obscureConfirmPassword = !obscureConfirmPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submitRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SoftinsaColors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Continuar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Já tem conta? ',
                                  style: TextStyle(color: SoftinsaColors.textMuted),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                  },
                                  child: const Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: SoftinsaColors.blue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: SoftinsaColors.textMuted, height: 1.5),
                                children: [
                                  const TextSpan(text: 'Ao clicar em continuar, você concorda com os nossos\n'),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () => _showTermsDialog(context),
                                      child: const Text(
                                        'Termos de Serviço',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: SoftinsaColors.blue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' e '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () => _showPrivacyDialog(context),
                                      child: const Text(
                                        'Política de Privacidade',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: SoftinsaColors.blue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
