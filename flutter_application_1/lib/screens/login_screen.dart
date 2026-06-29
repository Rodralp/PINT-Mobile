import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        ((await localStorage.getBool(PreferencesScreen.firstLoginPreferencesDoneKey)) ?? false);

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

      Navigator.pushReplacementNamed(
        context,
        hasPreferences ? '/app' : '/preferences',
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o e-mail e a palavra-passe.')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A aplicação mobile está disponível apenas para consultores.',
            ),
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
          ((await localStorage.getBool(PreferencesScreen.firstLoginPreferencesDoneKey)) ?? false);

      if (!mounted) {
        return;
      }

      if (hasPreferences) {
        Navigator.pushReplacementNamed(context, '/app');
      } else {
        Navigator.pushReplacementNamed(context, '/preferences');
      }
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.code == 'ACCOUNT_PENDING_APPROVAL'
          ? 'A sua conta ainda aguarda aprovação.'
          : (error.message.isEmpty
                ? 'Não foi possível iniciar sessão.'
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
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fechar')),
            ],
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível iniciar sessão.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  static const List<Map<String, String>> _terms = [
    {
      'title': 'Aceitação dos termos',
      'body':
          'Ao aceder ou utilizar a plataforma, o utilizador declara ter lido, compreendido e aceitado estes Termos na íntegra. Caso não concorde com algum dos pontos, não deverá utilizar a plataforma.',
    },
    {
      'title': 'Utilizadores abrangidos',
      'body':
          'A plataforma destina-se exclusivamente a colaboradores da Softinsa, bem como a gestores (Talent Managers e Service Line Leaders) no exercício das suas funções.',
    },
    {
      'title': 'Criação de conta e segurança',
      'body':
          'O utilizador compromete-se a fornecer informações verdadeiras, completas e atualizadas durante o registo. A password é pessoal e intransmissível. O utilizador é responsável por todas as atividades realizadas na sua conta. Na primeira autenticação, o utilizador deverá alterar a password fornecida. O utilizador pode solicitar a recuperação da password através do email associado à conta.',
    },
    {
      'title': 'Submissão de evidências',
      'body':
          'Para concorrer a um badge, o utilizador deverá submeter as evidências solicitadas (certificados, diplomas, relatórios, etc.). O utilizador declara que todas as evidências submetidas são verdadeiras, autênticas e lhe pertencem. A Softinsa reserva-se o direito de solicitar documentação complementar ou de rejeitar evidências que considere insuficientes ou falsas.',
    },
    {
      'title': 'Processo de validação e aprovação',
      'body':
          'As candidaturas serão analisadas primeiro pelo Talent Manager e depois pelo Service Line Leader da área respetiva. O utilizador será notificado por email sobre aprovações, rejeições ou pedidos de correção. Todas as decisões são finais nos termos do regulamento interno da Softinsa.',
    },
    {
      'title': 'Obtenção e utilização de badges',
      'body':
          'Um badge é atribuído apenas quando todos os requisitos de um determinado nível estiverem cumpridos. Alguns badges podem ter data de expiração, sendo essa informação visível na página do badge. O utilizador compromete-se a não adulterar, falsificar ou utilizar indevidamente qualquer badge.',
    },
    {
      'title': 'Publicação e partilha de badges',
      'body':
          'O utilizador pode autorizar que os seus badges sejam exibidos na galeria pública da plataforma. O utilizador pode partilhar voluntariamente os seus badges no LinkedIn ou noutras redes profissionais. Caso pretenda incluir um badge na assinatura de email corporativo, deverá ativar essa funcionalidade nas definições da conta.',
    },
    {
      'title': 'Sistema de pontuação e gamificação',
      'body':
          'A Softinsa pode atribuir pontos a cada badge, de acordo com critérios definidos internamente. Os pontos servem para identificar talento e evolução profissional, podendo ser considerados em processos de reconhecimento ou compensação. Mesmo que um badge expire, a pontuação obtida mantém-se no histórico do utilizador.',
    },
    {
      'title': 'Notificações e lembretes',
      'body':
          'Ao aceitar estes Termos, o utilizador consente receber notificações por email e/ou push relativas a: confirmação de candidatura a um badge, aprovação ou rejeição de pedidos, expiração de badges e lembretes de objetivos e prazos definidos na timeline pessoal.',
    },
    {
      'title': 'Conduta proibida',
      'body':
          'O utilizador não deverá: partilhar as suas credenciais de acesso com terceiros; utilizar a plataforma para fins não profissionais ou não autorizados; submeter evidências falsas ou de terceiros sem consentimento; tentar aceder a dados de outros utilizadores sem permissão.',
    },
    {
      'title': 'Suspensão ou cancelamento de conta',
      'body':
          'A Softinsa reserva-se o direito de suspender ou cancelar contas em caso de violação destes Termos, utilização indevida da plataforma ou por solicitação dos recursos humanos da empresa.',
    },
    {
      'title': 'Alterações aos termos',
      'body':
          'Estes Termos podem ser atualizados periodicamente. As alterações serão comunicadas aos utilizadores com antecedência mínima de 15 dias, salvo quando exigido por lei.',
    },
    {
      'title': 'Legislação aplicável',
      'body':
          'Estes Termos regem-se pela legislação portuguesa. Qualquer litígio será submetido aos tribunais da comarca de Lisboa.',
    },
  ];

  static const List<Map<String, String>> _privacyPolicy = [
    {
      'title': 'Responsável pelo tratamento dos dados',
      'body':
          'A Softinsa é a entidade responsável pelo tratamento dos seus dados pessoais no âmbito da Plataforma de Badges.',
    },
    {
      'title': 'Que dados recolhemos?',
      'body':
          'Ao utilizar a plataforma, podemos recolher as seguintes categorias de dados:\n\nDados de identificação profissional: nome, email corporativo, área de atuação e função na empresa.\n\nDados de autenticação: password (armazenada de forma cifrada) e histórico de acessos.\n\nDados de evidências: certificados, diplomas, relatórios e outros documentos que o utilizador enviar para concorrer a badges.\n\nHistórico de badges: badges obtidos, badges em processo de validação e progresso nos percursos de aprendizagem.\n\nDados de gamificação: pontuação atribuída, conquistas especiais e marcos alcançados.\n\nDados de comunicação: notificações enviadas, lembretes e preferências de contacto.',
    },
    {
      'title': 'Como utilizamos os seus dados?',
      'body':
          'Os seus dados são utilizados exclusivamente para as seguintes finalidades:\n\nGestão da sua conta e autenticação na plataforma.\n\nSubmissão, validação e aprovação de candidaturas a badges.\n\nEmissão e publicação de badges digitais.\n\nCriação de rankings internos por área ou Service Line, para efeitos de reconhecimento profissional.\n\nEnvio de notificações sobre o estado dos seus pedidos, expiração de badges e lembretes de objetivos.\n\nGeração de relatórios agregados e anónimos para melhoria da plataforma e gestão de talento.\n\nPartilha pública apenas quando o utilizador autorizar expressamente.',
    },
    {
      'title': 'Qual o fundamento legal para o tratamento?',
      'body':
          'O tratamento dos seus dados baseia-se em:\n\nExecução do contrato de trabalho ou de formação profissional (gestão de competências e progressão).\n\nConsentimento explícito do utilizador para partilha pública de badges ou integração com redes profissionais.\n\nInteresse legítimo da Softinsa em gerir o talento interno, certificar competências e promover a aprendizagem contínua.\n\nObrigações legais aplicáveis, nomeadamente em matéria de arquivo e auditoria.',
    },
    {
      'title': 'Com quem partilhamos os seus dados?',
      'body':
          'Os seus dados podem ser acedidos ou partilhados com:\n\nTalent Managers e Service Line Leaders no âmbito do processo de validação de badges.\n\nAdministradores da plataforma para gestão técnica e configuração.\n\nFornecedores técnicos subcontratados (ex: alojamento da plataforma, serviço de email), que estão vinculados contratualmente ao RGPD.\n\nRedes profissionais (ex: LinkedIn) apenas mediante autorização expressa do utilizador.\n\nAutoridades públicas quando obrigatório por lei.\n\nOs seus dados não são vendidos nem cedidos a terceiros para fins de marketing.',
    },
    {
      'title': 'Página pública de badges',
      'body':
          'Cada badge aprovado tem uma página pública acessível por um link único. Essa página contém apenas:\n\nNome do consultor\n\nBadge obtido\n\nData de atribuição\n\nCompetências certificadas\n\nO utilizador pode solicitar a remoção da página pública a qualquer momento, contactando o encarregado de proteção de dados.',
    },
    {
      'title': 'Por quanto tempo guardamos os seus dados?',
      'body':
          'Tipo de dado e prazo de conservação:\n\nEvidências submetidas: Durante a validade do badge + 2 anos\n\nBadges sem expiração: Indefinidamente (histórico profissional)\n\nHistórico de acessos e decisões: 5 anos após a última interação\n\nDados de registo: Enquanto o utilizador estiver ativo na plataforma\n\nApós estes prazos, os dados serão anonimizados ou eliminados de forma segura.',
    },
    {
      'title': 'Quais são os seus direitos?',
      'body':
          'Enquanto titular dos dados, tem direito a:\n\nAceder aos seus dados pessoais que tratamos.\n\nRetificar dados incompletos ou desatualizados.\n\nSolicitar o apagamento dos seus dados, salvo obrigações legais de conservação.\n\nLimitar o tratamento em certas circunstâncias.\n\nPortabilidade dos dados que nos forneceu.\n\nOpor-se à criação de rankings públicos ou à partilha de badges.\n\nRetirar o consentimento a qualquer momento, sem comprometer a licitude do tratamento realizado até então.\n\nPode exercer estes direitos através do contacto indicado no ponto 11.',
    },
    {
      'title': 'Como protegemos os seus dados?',
      'body':
          'Adotamos medidas técnicas e organizativas adequadas, incluindo:\n\nComunicação encriptada (HTTPS) entre o seu dispositivo e a plataforma.\n\nArmazenamento cifrado de passwords.\n\nControlo de acessos baseado em perfis.\n\nRegisto de auditoria para todas as ações de validação e aprovação.',
    },
    {
      'title': 'Dados de menores',
      'body':
          'A plataforma destina-se exclusivamente a colaboradores da Softinsa, presumindo-se que todos têm idade igual ou superior a 18 anos.',
    },
  ];

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
                              'SOFTINSA BADGES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Termos de Serviço',
                              style: TextStyle(
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
                    'A utilização da Plataforma de Badges da Softinsa está reservada a colaboradores autorizados. Estes Termos de Serviço regulam o acesso à plataforma, a gestão de contas, a submissão de evidências, a validação de badges e a utilização das funcionalidades associadas.',
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
                        _terms.length,
                        (i) => _buildTermCard(i + 1, _terms[i]),
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
                        child: const Text(
                          'Li e aceito os termos',
                          style: TextStyle(color: Colors.white, fontSize: 13),
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
                              'SOFTINSA BADGES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Política de Privacidade',
                              style: TextStyle(
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
                    'A Softinsa está comprometida com a proteção da sua privacidade e dos seus dados pessoais. Esta Política explica quais os dados que recolhemos, como os utilizamos, com quem os partilhamos e quais os seus direitos ao abrigo do Regulamento Geral sobre a Proteção de Dados (RGPD).',
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
                        _privacyPolicy.length,
                        (i) => _buildTermCard(i + 1, _privacyPolicy[i]),
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
                        child: const Text(
                          'Li e aceito a política',
                          style: TextStyle(color: Colors.white, fontSize: 13),
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
                const Text(
                  "Entrar conta",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // SUBTÍTULO
                const Text(
                  "Insira o seu e-mail para entrar na sua conta",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
                      hintText: "email@dominio.com",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
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
                      hintText: "Palavra-passe",
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
                    const Text("Guardar dados de login"),
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
                    child: const Text(
                      "Esqueceu a senha?",
                      style: TextStyle(color: Colors.blue),
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
                        : const Text(
                            "Continuar",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Primeiro acesso? ',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Registe-se',
                        style: TextStyle(
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
                            style: TextStyle(fontSize: 12, color: Colors.blue),
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
                            style: TextStyle(fontSize: 12, color: Colors.blue),
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
