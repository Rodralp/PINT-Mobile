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
        const SnackBar(
          content: Text('Preencha todos os campos para continuar.'),
        ),
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

      final message = error.message.isEmpty
          ? 'Não foi possível criar a conta.'
          : error.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
                child: const Icon(
                  Icons.check_rounded,
                  color: SoftinsaColors.blue,
                  size: 36,
                ),
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
                      children: const [
                        Icon(
                          Icons.verified_user_outlined,
                          color: SoftinsaColors.blue,
                        ),
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
                            style: TextStyle(
                              color: SoftinsaColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Os seus badges poderão ser visualizados por outros consultores e gestores da empresa, permitindo o reconhecimento das suas competências e progressão profissional.',
                            style: TextStyle(
                              color: SoftinsaColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ao aceitar, concorda com o tratamento dos seus dados pessoais de acordo com o Regulamento Geral de Proteção de Dados (RGPD).',
                            style: TextStyle(
                              color: SoftinsaColors.textMuted,
                              height: 1.5,
                            ),
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
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isChecked
                                ? () => Navigator.pop(dialogContext, true)
                                : null,
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

  static const List<Map<String, String>> _termsSections = [
    {
      'title': 'Utilização da plataforma',
      'body':
          'A plataforma destina-se exclusivamente a utilizadores autorizados pela Softinsa para gestão de badges e processos internos.',
    },
    {
      'title': 'Responsabilidade da conta',
      'body':
          'O utilizador é responsável pela veracidade dos dados fornecidos e pela utilização adequada da sua conta.',
    },
    {
      'title': 'Acesso e segurança',
      'body':
          'As credenciais são pessoais e intransmissíveis. O acesso deve ser mantido seguro e utilizado apenas para fins profissionais.',
    },
    {
      'title': 'Condições de utilização',
      'body':
          'A Softinsa pode suspender ou limitar o acesso em caso de uso indevido, incumprimento das regras ou necessidade operacional.',
    },
  ];

  static const List<Map<String, String>> _privacySections = [
    {
      'title': 'Dados recolhidos',
      'body':
          'A aplicação trata dados de identificação, autenticação e atividade necessários para gerir a conta e os badges.',
    },
    {
      'title': 'Finalidade do tratamento',
      'body':
          'Os dados são usados para autenticação, gestão de permissões, validação de pedidos e funcionalidades associadas à plataforma.',
    },
    {
      'title': 'Partilha e acesso',
      'body':
          'Os dados apenas são disponibilizados aos perfis internos autorizados e nunca são vendidos a terceiros.',
    },
    {
      'title': 'Direitos do utilizador',
      'body':
          'O utilizador pode pedir acesso, correção ou eliminação dos seus dados nos termos da legislação aplicável.',
    },
  ];

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
                              'SOFTINSA BADGES',
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
    _showLegalDialog(
      context: context,
      title: 'Termos de Serviço',
      intro:
          'A utilização da plataforma está reservada a colaboradores autorizados. Estes Termos regulam o acesso, a utilização da conta e o tratamento das ações realizadas na aplicação.',
      sections: _termsSections,
      acceptLabel: 'Li e aceito os termos',
    );
  }

  Future<void> _showPrivacyDialog(BuildContext context) async {
    _showLegalDialog(
      context: context,
      title: 'Política de Privacidade',
      intro:
          'A Softinsa está comprometida com a proteção da sua privacidade e dos seus dados pessoais. Esta política explica como os dados são recolhidos, usados e protegidos.',
      sections: _privacySections,
      acceptLabel: 'Li e aceito a política',
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
                    const Text(
                      'Criar Conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: SoftinsaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SUBTÍTULO
                    const Text(
                      'Defina as suas credenciais para começar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: SoftinsaColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CAMPO NOME
                    _buildLabel('Nome Completo'),
                    const SizedBox(height: 10),
                    _buildInputField(
                      hintText: 'Insira o seu nome completo',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),

                    // CAMPO EMAIL
                    _buildLabel('Email'),
                    const SizedBox(height: 10),
                    _buildInputField(
                      hintText: 'email@dominio.com',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),

                    // CAMPO PALAVRA-PASSE
                    _buildLabel('Palavra-passe'),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      hintText: 'Defina a sua palavra-passe',
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
                    _buildLabel('Confirmar Palavra-passe'),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      hintText: 'Confirme a sua palavra-passe',
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
                            : const Text(
                                'Confirmar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LINK PARA LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem conta? ',
                          style: TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
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
                          const TextSpan(
                            text:
                                'Ao clicar em continuar, você concorda com os nossos\n',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () => _showTermsDialog(context),
                              child: const Text(
                                'Termos de Serviço',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
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
