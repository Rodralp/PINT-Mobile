import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _hasAcceptedRgpd = false;

  void _showRequestSentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check,
                color: Colors.blue,
                size: 56,
              ),
              const SizedBox(height: 28),
              const Text(
                'Pedido enviado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Um administrador irá verificar os seus dados e ativar a sua conta em breve.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34 / 2,
                  color: Colors.grey,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Voltar para Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32 / 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showRgpdConsentDialog(BuildContext context) async {
    bool isChecked = false;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 640,
                maxWidth: 700,
              ),
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
                              const Text(
                                'Aceitação dos Termos RGPD',
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
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Para utilizar a plataforma de badges da Softinsa, necessitamos do seu consentimento para a publicação e partilha dos seus badges.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Os seus badges poderão ser visualizados por outros consultores e gestores da empresa, permitindo o reconhecimento das suas competências e progressão profissional.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ao aceitar, concorda com o tratamento dos seus dados pessoais de acordo com o Regulamento Geral de Proteção de Dados (RGPD).',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  'Li e aceito os termos RGPD',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed:
                              isChecked ? () => Navigator.pop(context, true) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.blue.shade200,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(
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
      ),
    );

    return accepted ?? false;
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    'Bem-vindo à Plataforma de Badges da Softinsa. Estes Termos de Serviço regulam a sua utilização da plataforma, incluindo o acesso às funcionalidades, submissão de evidências, obtenção de badges e partilha de conquistas.',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
                const SizedBox(height: 24),

                Image.asset(
                  'assets/images/softinsa.png',
                  width: 180,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Insira os seus dados e aguarde a verificação',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                _buildInputField(
                  hintText: 'Nome',
                  prefixPadding: 16,
                ),

                const SizedBox(height: 14),

                _buildInputField(
                  hintText: 'email@dominio.com',
                  prefixPadding: 16,
                ),

                const SizedBox(height: 14),

                _buildPasswordField(
                  hintText: 'Palavra-passe',
                  obscureText: obscurePassword,
                  onToggle: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _buildPasswordField(
                  hintText: 'Confirmar Palavra-passe',
                  obscureText: obscureConfirmPassword,
                  onToggle: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_hasAcceptedRgpd) {
                        final hasAccepted = await _showRgpdConsentDialog(context);

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

                      _showRequestSentDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text: 'Já tem conta? ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Entre',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 18),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text: 'Ao clicar em continuar, você concorda com os nossos\n',
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
    );
  }

  Widget _buildInputField({
    required String hintText,
    required double prefixPadding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixPadding,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
}