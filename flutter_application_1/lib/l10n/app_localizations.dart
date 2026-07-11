import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Softinsa Badges'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar conta'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Insira o seu e-mail para entrar na sua conta'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'email@dominio.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'Palavra-passe'**
  String get passwordHint;

  /// No description provided for @rememberLogin.
  ///
  /// In pt, this message translates to:
  /// **'Guardar dados de login'**
  String get rememberLogin;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get forgotPassword;

  /// No description provided for @continueButton.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @firstAccess.
  ///
  /// In pt, this message translates to:
  /// **'Primeiro acesso? '**
  String get firstAccess;

  /// No description provided for @registerLink.
  ///
  /// In pt, this message translates to:
  /// **'Registe-se'**
  String get registerLink;

  /// No description provided for @termsAndPrivacyIntro.
  ///
  /// In pt, this message translates to:
  /// **'Ao clicar em continuar, você concorda com os nossos'**
  String get termsAndPrivacyIntro;

  /// No description provided for @termsOfService.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Serviço'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In pt, this message translates to:
  /// **'e'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyPolicy;

  /// No description provided for @fillEmailAndPassword.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o e-mail e a palavra-passe.'**
  String get fillEmailAndPassword;

  /// No description provided for @mobileOnlyConsultants.
  ///
  /// In pt, this message translates to:
  /// **'A aplicação mobile está disponível apenas para consultores.'**
  String get mobileOnlyConsultants;

  /// No description provided for @accountPendingApproval.
  ///
  /// In pt, this message translates to:
  /// **'A sua conta ainda aguarda aprovação.'**
  String get accountPendingApproval;

  /// No description provided for @loginFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar sessão.'**
  String get loginFailed;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @softinsaBadges.
  ///
  /// In pt, this message translates to:
  /// **'SOFTINSA BADGES'**
  String get softinsaBadges;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Serviço'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceIntro.
  ///
  /// In pt, this message translates to:
  /// **'A utilização da Plataforma de Badges da Softinsa está reservada a colaboradores autorizados. Estes Termos de Serviço regulam o acesso à plataforma, a gestão de contas, a submissão de evidências, a validação de badges e a utilização das funcionalidades associadas.'**
  String get termsOfServiceIntro;

  /// No description provided for @acceptTerms.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os termos'**
  String get acceptTerms;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In pt, this message translates to:
  /// **'A Softinsa está comprometida com a proteção da sua privacidade e dos seus dados pessoais. Esta Política explica quais os dados que recolhemos, como os utilizamos, com quem os partilhamos e quais os seus direitos ao abrigo do Regulamento Geral sobre a Proteção de Dados (RGPD).'**
  String get privacyPolicyIntro;

  /// No description provided for @acceptPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito a política'**
  String get acceptPrivacy;

  /// No description provided for @termsAcceptanceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aceitação dos termos'**
  String get termsAcceptanceTitle;

  /// No description provided for @termsAcceptanceBody.
  ///
  /// In pt, this message translates to:
  /// **'Ao aceder ou utilizar a plataforma, o utilizador declara ter lido, compreendido e aceitado estes Termos na íntegra. Caso não concorde com algum dos pontos, não deverá utilizar a plataforma.'**
  String get termsAcceptanceBody;

  /// No description provided for @termsUsersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Utilizadores abrangidos'**
  String get termsUsersTitle;

  /// No description provided for @termsUsersBody.
  ///
  /// In pt, this message translates to:
  /// **'A plataforma destina-se exclusivamente a colaboradores da Softinsa, bem como a gestores (Talent Managers e Service Line Leaders) no exercício das suas funções.'**
  String get termsUsersBody;

  /// No description provided for @termsAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criação de conta e segurança'**
  String get termsAccountTitle;

  /// No description provided for @termsAccountBody.
  ///
  /// In pt, this message translates to:
  /// **'O utilizador compromete-se a fornecer informações verdadeiras, completas e atualizadas durante o registo. A password é pessoal e intransmissível. O utilizador é responsável por todas as atividades realizadas na sua conta. Na primeira autenticação, o utilizador deverá alterar a password fornecida. O utilizador pode solicitar a recuperação da password através do email associado à conta.'**
  String get termsAccountBody;

  /// No description provided for @termsEvidenceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Submissão de evidências'**
  String get termsEvidenceTitle;

  /// No description provided for @termsEvidenceBody.
  ///
  /// In pt, this message translates to:
  /// **'Para concorrer a um badge, o utilizador deverá submeter as evidências solicitadas (certificados, diplomas, relatórios, etc.). O utilizador declara que todas as evidências submetidas são verdadeiras, autênticas e lhe pertencem. A Softinsa reserva-se o direito de solicitar documentação complementar ou de rejeitar evidências que considere insuficientes ou falsas.'**
  String get termsEvidenceBody;

  /// No description provided for @termsValidationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Processo de validação e aprovação'**
  String get termsValidationTitle;

  /// No description provided for @termsValidationBody.
  ///
  /// In pt, this message translates to:
  /// **'As candidaturas serão analisadas primeiro pelo Talent Manager e depois pelo Service Line Leader da área respetiva. O utilizador será notificado por email sobre aprovações, rejeições ou pedidos de correção. Todas as decisões são finais nos termos do regulamento interno da Softinsa.'**
  String get termsValidationBody;

  /// No description provided for @termsBadgesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Obtenção e utilização de badges'**
  String get termsBadgesTitle;

  /// No description provided for @termsBadgesBody.
  ///
  /// In pt, this message translates to:
  /// **'Um badge é atribuído apenas quando todos os requisitos de um determinado nível estiverem cumpridos. Alguns badges podem ter data de expiração, sendo essa informação visível na página do badge. O utilizador compromete-se a não adulterar, falsificar ou utilizar indevidamente qualquer badge.'**
  String get termsBadgesBody;

  /// No description provided for @termsSharingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Publicação e partilha de badges'**
  String get termsSharingTitle;

  /// No description provided for @termsSharingBody.
  ///
  /// In pt, this message translates to:
  /// **'O utilizador pode autorizar que os seus badges sejam exibidos na galeria pública da plataforma. O utilizador pode partilhar voluntariamente os seus badges no LinkedIn ou noutras redes profissionais. Caso pretenda incluir um badge na assinatura de email corporativo, deverá ativar essa funcionalidade nas definições da conta.'**
  String get termsSharingBody;

  /// No description provided for @termsGamificationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sistema de pontuação e gamificação'**
  String get termsGamificationTitle;

  /// No description provided for @termsGamificationBody.
  ///
  /// In pt, this message translates to:
  /// **'A Softinsa pode atribuir pontos a cada badge, de acordo com critérios definidos internamente. Os pontos servem para identificar talento e evolução profissional, podendo ser considerados em processos de reconhecimento ou compensação. Mesmo que um badge expire, a pontuação obtida mantém-se no histórico do utilizador.'**
  String get termsGamificationBody;

  /// No description provided for @termsNotificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações e lembretes'**
  String get termsNotificationsTitle;

  /// No description provided for @termsNotificationsBody.
  ///
  /// In pt, this message translates to:
  /// **'Ao aceitar estes Termos, o utilizador consente receber notificações por email e/ou push relativas a: confirmação de candidatura a um badge, aprovação ou rejeição de pedidos, expiração de badges e lembretes de objetivos e prazos definidos na timeline pessoal.'**
  String get termsNotificationsBody;

  /// No description provided for @termsProhibitedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conduta proibida'**
  String get termsProhibitedTitle;

  /// No description provided for @termsProhibitedBody.
  ///
  /// In pt, this message translates to:
  /// **'O utilizador não deverá: partilhar as suas credenciais de acesso com terceiros; utilizar a plataforma para fins não profissionais ou não autorizados; submeter evidências falsas ou de terceiros sem consentimento; tentar aceder a dados de outros utilizadores sem permissão.'**
  String get termsProhibitedBody;

  /// No description provided for @termsSuspensionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Suspensão ou cancelamento de conta'**
  String get termsSuspensionTitle;

  /// No description provided for @termsSuspensionBody.
  ///
  /// In pt, this message translates to:
  /// **'A Softinsa reserva-se o direito de suspender ou cancelar contas em caso de violação destes Termos, utilização indevida da plataforma ou por solicitação dos recursos humanos da empresa.'**
  String get termsSuspensionBody;

  /// No description provided for @termsChangesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterações aos termos'**
  String get termsChangesTitle;

  /// No description provided for @termsChangesBody.
  ///
  /// In pt, this message translates to:
  /// **'Estes Termos podem ser atualizados periodicamente. As alterações serão comunicadas aos utilizadores com antecedência mínima de 15 dias, salvo quando exigido por lei.'**
  String get termsChangesBody;

  /// No description provided for @termsLawTitle.
  ///
  /// In pt, this message translates to:
  /// **'Legislação aplicável'**
  String get termsLawTitle;

  /// No description provided for @termsLawBody.
  ///
  /// In pt, this message translates to:
  /// **'Estes Termos regem-se pela legislação portuguesa. Qualquer litígio será submetido aos tribunais da comarca de Lisboa.'**
  String get termsLawBody;

  /// No description provided for @privacyDataTitle.
  ///
  /// In pt, this message translates to:
  /// **'Responsável pelo tratamento dos dados'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In pt, this message translates to:
  /// **'A Softinsa é a entidade responsável pelo tratamento dos seus dados pessoais no âmbito da Plataforma de Badges.'**
  String get privacyDataBody;

  /// No description provided for @privacyCollectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Que dados recolhemos?'**
  String get privacyCollectTitle;

  /// No description provided for @privacyCollectBody.
  ///
  /// In pt, this message translates to:
  /// **'Ao utilizar a plataforma, podemos recolher as seguintes categorias de dados:\n\nDados de identificação profissional: nome, email corporativo, área de atuação e função na empresa.\n\nDados de autenticação: password (armazenada de forma cifrada) e histórico de acessos.\n\nDados de evidências: certificados, diplomas, relatórios e outros documentos que o utilizador enviar para concorrer a badges.\n\nHistórico de badges: badges obtidos, badges em processo de validação e progresso nos percursos de aprendizagem.\n\nDados de gamificação: pontuação atribuída, conquistas especiais e marcos alcançados.\n\nDados de comunicação: notificações enviadas, lembretes e preferências de contacto.'**
  String get privacyCollectBody;

  /// No description provided for @privacyUseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como utilizamos os seus dados?'**
  String get privacyUseTitle;

  /// No description provided for @privacyUseBody.
  ///
  /// In pt, this message translates to:
  /// **'Os seus dados são utilizados exclusivamente para as seguintes finalidades:\n\nGestão da sua conta e autenticação na plataforma.\n\nSubmissão, validação e aprovação de candidaturas a badges.\n\nEmissão e publicação de badges digitais.\n\nCriação de rankings internos por área ou Service Line, para efeitos de reconhecimento profissional.\n\nEnvio de notificações sobre o estado dos seus pedidos, expiração de badges e lembretes de objetivos.\n\nGeração de relatórios agregados e anónimos para melhoria da plataforma e gestão de talento.\n\nPartilha pública apenas quando o utilizador autorizar expressamente.'**
  String get privacyUseBody;

  /// No description provided for @privacyLegalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual o fundamento legal para o tratamento?'**
  String get privacyLegalTitle;

  /// No description provided for @privacyLegalBody.
  ///
  /// In pt, this message translates to:
  /// **'O tratamento dos seus dados baseia-se em:\n\nExecução do contrato de trabalho ou de formação profissional (gestão de competências e progressão).\n\nConsentimento explícito do utilizador para partilha pública de badges ou integração com redes profissionais.\n\nInteresse legítimo da Softinsa em gerir o talento interno, certificar competências e promover a aprendizagem contínua.\n\nObrigações legais aplicáveis, nomeadamente em matéria de arquivo e auditoria.'**
  String get privacyLegalBody;

  /// No description provided for @privacyShareTitle.
  ///
  /// In pt, this message translates to:
  /// **'Com quem partilhamos os seus dados?'**
  String get privacyShareTitle;

  /// No description provided for @privacyShareBody.
  ///
  /// In pt, this message translates to:
  /// **'Os seus dados podem ser acedidos ou partilhados com:\n\nTalent Managers e Service Line Leaders no âmbito do processo de validação de badges.\n\nAdministradores da plataforma para gestão técnica e configuração.\n\nFornecedores técnicos subcontratados (ex: alojamento da plataforma, serviço de email), que estão vinculados contratualmente ao RGPD.\n\nRedes profissionais (ex: LinkedIn) apenas mediante autorização expressa do utilizador.\n\nAutoridades públicas quando obrigatório por lei.\n\nOs seus dados não são vendidos nem cedidos a terceiros para fins de marketing.'**
  String get privacyShareBody;

  /// No description provided for @privacyBadgePageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Página pública de badges'**
  String get privacyBadgePageTitle;

  /// No description provided for @privacyBadgePageBody.
  ///
  /// In pt, this message translates to:
  /// **'Cada badge aprovado tem uma página pública acessível por um link único. Essa página contém apenas:\n\nNome do consultor\n\nBadge obtido\n\nData de atribuição\n\nCompetências certificadas\n\nO utilizador pode solicitar a remoção da página pública a qualquer momento, contactando o encarregado de proteção de dados.'**
  String get privacyBadgePageBody;

  /// No description provided for @privacyRetentionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por quanto tempo guardamos os seus dados?'**
  String get privacyRetentionTitle;

  /// No description provided for @privacyRetentionBody.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de dado e prazo de conservação:\n\nEvidências submetidas: Durante a validade do badge + 2 anos\n\nBadges sem expiração: Indefinidamente (histórico profissional)\n\nHistórico de acessos e decisões: 5 anos após a última interação\n\nDados de registo: Enquanto o utilizador estiver ativo na plataforma\n\nApós estes prazos, os dados serão anonimizados ou eliminados de forma segura.'**
  String get privacyRetentionBody;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quais são os seus direitos?'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightsBody.
  ///
  /// In pt, this message translates to:
  /// **'Enquanto titular dos dados, tem direito a:\n\nAceder aos seus dados pessoais que tratamos.\n\nRetificar dados incompletos ou desatualizados.\n\nSolicitar o apagamento dos seus dados, salvo obrigações legais de conservação.\n\nLimitar o tratamento em certas circunstâncias.\n\nPortabilidade dos dados que nos forneceu.\n\nOpor-se à criação de rankings públicos ou à partilha de badges.\n\nRetirar o consentimento a qualquer momento, sem comprometer a licitude do tratamento realizado até então.\n\nPode exercer estes direitos através do contacto indicado no ponto 11.'**
  String get privacyRightsBody;

  /// No description provided for @privacyProtectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como protegemos os seus dados?'**
  String get privacyProtectTitle;

  /// No description provided for @privacyProtectBody.
  ///
  /// In pt, this message translates to:
  /// **'Adotamos medidas técnicas e organizativas adequadas, incluindo:\n\nComunicação encriptada (HTTPS) entre o seu dispositivo e a plataforma.\n\nArmazenamento cifrado de passwords.\n\nControlo de acessos baseado em perfis.\n\nRegisto de auditoria para todas as ações de validação e aprovação.'**
  String get privacyProtectBody;

  /// No description provided for @privacyMinorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dados de menores'**
  String get privacyMinorsTitle;

  /// No description provided for @privacyMinorsBody.
  ///
  /// In pt, this message translates to:
  /// **'A plataforma destina-se exclusivamente a colaboradores da Softinsa, presumindo-se que todos têm idade igual ou superior a 18 anos.'**
  String get privacyMinorsBody;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar Conta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Defina as suas credenciais para começar'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome Completo'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Insira o seu nome completo'**
  String get fullNameHint;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Palavra-passe'**
  String get passwordLabel;

  /// No description provided for @passwordDefineHint.
  ///
  /// In pt, this message translates to:
  /// **'Defina a sua palavra-passe'**
  String get passwordDefineHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Palavra-passe'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Confirme a sua palavra-passe'**
  String get confirmPasswordHint;

  /// No description provided for @confirmButton.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirmButton;

  /// No description provided for @hasAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta? '**
  String get hasAccount;

  /// No description provided for @loginLink.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginLink;

  /// No description provided for @fillAllFields.
  ///
  /// In pt, this message translates to:
  /// **'Preencha todos os campos para continuar.'**
  String get fillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In pt, this message translates to:
  /// **'As palavras-passe não coincidem.'**
  String get passwordsDoNotMatch;

  /// No description provided for @createAccountFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar a conta.'**
  String get createAccountFailed;

  /// No description provided for @requestSentSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado com sucesso!'**
  String get requestSentSuccess;

  /// No description provided for @requestSentDescription.
  ///
  /// In pt, this message translates to:
  /// **'Um administrador irá verificar os seus dados e ativar a sua conta em breve.'**
  String get requestSentDescription;

  /// No description provided for @backToHome.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para Home'**
  String get backToHome;

  /// No description provided for @rgpdTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aceitação dos Termos RGPD'**
  String get rgpdTitle;

  /// No description provided for @rgpdIntro.
  ///
  /// In pt, this message translates to:
  /// **'Para utilizar a plataforma de badges da Softinsa, necessitamos do seu consentimento para a publicação e partilha dos seus badges.'**
  String get rgpdIntro;

  /// No description provided for @rgpdBadgesInfo.
  ///
  /// In pt, this message translates to:
  /// **'Os seus badges poderão ser visualizados por outros consultores e gestores da empresa, permitindo o reconhecimento das suas competências e progressão profissional.'**
  String get rgpdBadgesInfo;

  /// No description provided for @rgpdConsentInfo.
  ///
  /// In pt, this message translates to:
  /// **'Ao aceitar, concorda com o tratamento dos seus dados pessoais de acordo com o Regulamento Geral de Proteção de Dados (RGPD).'**
  String get rgpdConsentInfo;

  /// No description provided for @rgpdAccept.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os termos RGPD.'**
  String get rgpdAccept;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get accept;

  /// No description provided for @dashboardNav.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get dashboardNav;

  /// No description provided for @badgesNav.
  ///
  /// In pt, this message translates to:
  /// **'Badges'**
  String get badgesNav;

  /// No description provided for @learningPathNav.
  ///
  /// In pt, this message translates to:
  /// **'Jornada'**
  String get learningPathNav;

  /// No description provided for @requestsNav.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos'**
  String get requestsNav;

  /// No description provided for @moreNav.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get moreNav;

  /// No description provided for @badgesObtained.
  ///
  /// In pt, this message translates to:
  /// **'Badges Obtidos'**
  String get badgesObtained;

  /// No description provided for @streakDays.
  ///
  /// In pt, this message translates to:
  /// **'Sequência de Dias'**
  String get streakDays;

  /// No description provided for @pendingRequests.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos Pendentes'**
  String get pendingRequests;

  /// No description provided for @ranking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @thisMonth.
  ///
  /// In pt, this message translates to:
  /// **'este mês'**
  String get thisMonth;

  /// No description provided for @inValidation.
  ///
  /// In pt, this message translates to:
  /// **'em validação'**
  String get inValidation;

  /// No description provided for @positionsThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'posições este mês'**
  String get positionsThisMonth;

  /// No description provided for @recordDays.
  ///
  /// In pt, this message translates to:
  /// **'Recorde: {count} dias'**
  String recordDays(int count);

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'A carregar...'**
  String get loading;

  /// No description provided for @obtainingData.
  ///
  /// In pt, this message translates to:
  /// **'A obter dados do dashboard'**
  String get obtainingData;

  /// No description provided for @remindersSection.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes'**
  String get remindersSection;

  /// No description provided for @viewAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// No description provided for @noReminders.
  ///
  /// In pt, this message translates to:
  /// **'Sem lembretes para mostrar.'**
  String get noReminders;

  /// No description provided for @inProgressSection.
  ///
  /// In pt, this message translates to:
  /// **'Em Progresso'**
  String get inProgressSection;

  /// No description provided for @noInProgressItems.
  ///
  /// In pt, this message translates to:
  /// **'Sem itens em progresso para mostrar.'**
  String get noInProgressItems;

  /// No description provided for @suggestionsSection.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões'**
  String get suggestionsSection;

  /// No description provided for @definePreferencesHint.
  ///
  /// In pt, this message translates to:
  /// **'Defina as suas preferências para ver sugestões de badges.'**
  String get definePreferencesHint;

  /// No description provided for @junior.
  ///
  /// In pt, this message translates to:
  /// **'Júnior'**
  String get junior;

  /// No description provided for @intermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermédio'**
  String get intermediate;

  /// No description provided for @senior.
  ///
  /// In pt, this message translates to:
  /// **'Sénior'**
  String get senior;

  /// No description provided for @specialist.
  ///
  /// In pt, this message translates to:
  /// **'Especialista'**
  String get specialist;

  /// No description provided for @knowledgeLead.
  ///
  /// In pt, this message translates to:
  /// **'Líder de Conhecimento'**
  String get knowledgeLead;

  /// No description provided for @special.
  ///
  /// In pt, this message translates to:
  /// **'Especial'**
  String get special;

  /// No description provided for @all.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @approved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get approved;

  /// No description provided for @inValidationState.
  ///
  /// In pt, this message translates to:
  /// **'Em Validação'**
  String get inValidationState;

  /// No description provided for @applicationInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Candidatura em Progresso'**
  String get applicationInProgress;

  /// No description provided for @rejected.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitado'**
  String get rejected;

  /// No description provided for @noState.
  ///
  /// In pt, this message translates to:
  /// **'Sem estado'**
  String get noState;

  /// No description provided for @pointsHighToLow.
  ///
  /// In pt, this message translates to:
  /// **'Pontos (Maior para Menor)'**
  String get pointsHighToLow;

  /// No description provided for @pointsLowToHigh.
  ///
  /// In pt, this message translates to:
  /// **'Pontos (Menor para Maior)'**
  String get pointsLowToHigh;

  /// No description provided for @areaAZ.
  ///
  /// In pt, this message translates to:
  /// **'Área (A-Z)'**
  String get areaAZ;

  /// No description provided for @areaZA.
  ///
  /// In pt, this message translates to:
  /// **'Área (Z-A)'**
  String get areaZA;

  /// No description provided for @filterBadges.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar badges'**
  String get filterBadges;

  /// No description provided for @sortBadges.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar badges'**
  String get sortBadges;

  /// No description provided for @fullBadgeCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo de Badges Completo'**
  String get fullBadgeCatalog;

  /// No description provided for @searchBadges.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar badges'**
  String get searchBadges;

  /// No description provided for @filter.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// No description provided for @badgeCatalogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo de Badges'**
  String get badgeCatalogTitle;

  /// No description provided for @databaseLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a base de dados.'**
  String get databaseLoadError;

  /// No description provided for @noBadgesYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem badges.'**
  String get noBadgesYet;

  /// No description provided for @noBadgesWithFilters.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum badge encontrado com os filtros escolhidos.'**
  String get noBadgesWithFilters;

  /// No description provided for @emptyCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo vazio.'**
  String get emptyCatalog;

  /// No description provided for @pointsAbbrev.
  ///
  /// In pt, this message translates to:
  /// **'pts'**
  String get pointsAbbrev;

  /// No description provided for @filterByLevel.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por nível'**
  String get filterByLevel;

  /// No description provided for @sortBy.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar por'**
  String get sortBy;

  /// No description provided for @pointsDown.
  ///
  /// In pt, this message translates to:
  /// **'Pontos ↓'**
  String get pointsDown;

  /// No description provided for @pointsUp.
  ///
  /// In pt, this message translates to:
  /// **'Pontos ↑'**
  String get pointsUp;

  /// No description provided for @badgesHighToLow.
  ///
  /// In pt, this message translates to:
  /// **'Badges (Maior para Menor)'**
  String get badgesHighToLow;

  /// No description provided for @badgesLowToHigh.
  ///
  /// In pt, this message translates to:
  /// **'Badges (Menor para Maior)'**
  String get badgesLowToHigh;

  /// No description provided for @nameAZ.
  ///
  /// In pt, this message translates to:
  /// **'Nome (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In pt, this message translates to:
  /// **'Nome (Z-A)'**
  String get nameZA;

  /// No description provided for @filterConsultants.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar consultores'**
  String get filterConsultants;

  /// No description provided for @sortRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar ranking'**
  String get sortRanking;

  /// No description provided for @allServiceLines.
  ///
  /// In pt, this message translates to:
  /// **'Todas as Service Lines'**
  String get allServiceLines;

  /// No description provided for @noConsultantsForFilters.
  ///
  /// In pt, this message translates to:
  /// **'Não há consultores para os filtros escolhidos.'**
  String get noConsultantsForFilters;

  /// No description provided for @searchConsultants.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar consultores'**
  String get searchConsultants;

  /// No description provided for @points.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get points;

  /// No description provided for @badges.
  ///
  /// In pt, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @learningPathError.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {error}'**
  String learningPathError(Object error);

  /// No description provided for @badgesObtainedCount.
  ///
  /// In pt, this message translates to:
  /// **'{obtained} de {total} badges obtidas'**
  String badgesObtainedCount(int obtained, int total);

  /// No description provided for @zeroBadges.
  ///
  /// In pt, this message translates to:
  /// **'0 badges'**
  String get zeroBadges;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get settingsTitle;

  /// No description provided for @accountOption.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get accountOption;

  /// No description provided for @accountOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Dados da conta e atalhos'**
  String get accountOptionSubtitle;

  /// No description provided for @securityOption.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get securityOption;

  /// No description provided for @securityOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar senha de acesso'**
  String get securityOptionSubtitle;

  /// No description provided for @preferencesOption.
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get preferencesOption;

  /// No description provided for @preferencesOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Áreas de interesse e recomendações'**
  String get preferencesOptionSubtitle;

  /// No description provided for @notificationsOption.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsOption;

  /// No description provided for @notificationsOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alertas e comunicações'**
  String get notificationsOptionSubtitle;

  /// No description provided for @logoutOption.
  ///
  /// In pt, this message translates to:
  /// **'Terminar Sessão'**
  String get logoutOption;

  /// No description provided for @logoutOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão e navegação'**
  String get logoutOptionSubtitle;

  /// No description provided for @logoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Terminar Sessão'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Pretende terminar a sua sessão?'**
  String get logoutConfirm;

  /// No description provided for @logoutButton.
  ///
  /// In pt, this message translates to:
  /// **'Terminar Sessão'**
  String get logoutButton;

  /// No description provided for @changePasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar senha'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Atualize a sua palavra-passe para manter a conta segura.'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua palavra-passe atual'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite a nova palavra-passe'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get confirmNewPasswordLabel;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Confirme a nova palavra-passe'**
  String get confirmNewPasswordHint;

  /// No description provided for @saveNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Guardar nova senha'**
  String get saveNewPassword;

  /// No description provided for @fillAllFieldsRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha todos os campos.'**
  String get fillAllFieldsRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'A nova palavra-passe deve ter pelo menos 6 caracteres.'**
  String get passwordMinLength;

  /// No description provided for @passwordConfirmMismatch.
  ///
  /// In pt, this message translates to:
  /// **'A confirmação não corresponde à nova palavra-passe.'**
  String get passwordConfirmMismatch;

  /// No description provided for @accountNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível identificar a conta ativa.'**
  String get accountNotFound;

  /// No description provided for @passwordChangedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Palavra-passe alterada'**
  String get passwordChangedTitle;

  /// No description provided for @passwordChangedDescription.
  ///
  /// In pt, this message translates to:
  /// **'A sua palavra-passe foi atualizada com sucesso.'**
  String get passwordChangedDescription;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível alterar a palavra-passe.'**
  String get passwordChangeFailed;

  /// No description provided for @accountInfoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Informação da conta'**
  String get accountInfoTitle;

  /// No description provided for @accountInfoSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Consulte os dados principais da sua conta.'**
  String get accountInfoSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nameLabel;

  /// No description provided for @emailFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get emailFieldLabel;

  /// No description provided for @profileLabel.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileLabel;

  /// No description provided for @noInformation.
  ///
  /// In pt, this message translates to:
  /// **'Sem informação'**
  String get noInformation;

  /// No description provided for @loadingData.
  ///
  /// In pt, this message translates to:
  /// **'A carregar...'**
  String get loadingData;

  /// No description provided for @errorLoading.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar'**
  String get errorLoading;

  /// No description provided for @goToProfile.
  ///
  /// In pt, this message translates to:
  /// **'Ir para perfil'**
  String get goToProfile;

  /// No description provided for @backToDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao dashboard'**
  String get backToDashboard;

  /// No description provided for @notificationPrefsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationPrefsTitle;

  /// No description provided for @notificationPrefsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Configure as suas preferências de notificação.'**
  String get notificationPrefsSubtitle;

  /// No description provided for @emailUpdates.
  ///
  /// In pt, this message translates to:
  /// **'Receber atualizações por email'**
  String get emailUpdates;

  /// No description provided for @inAppAlerts.
  ///
  /// In pt, this message translates to:
  /// **'Receber alertas dentro da plataforma'**
  String get inAppAlerts;

  /// No description provided for @weeklySummary.
  ///
  /// In pt, this message translates to:
  /// **'Receber resumo semanal'**
  String get weeklySummary;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Guardar alterações'**
  String get saveChanges;

  /// No description provided for @resetDefaults.
  ///
  /// In pt, this message translates to:
  /// **'Repor padrão'**
  String get resetDefaults;

  /// No description provided for @prefsSavedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Preferências guardadas com sucesso.'**
  String get prefsSavedSuccess;

  /// No description provided for @prefsSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao guardar preferências.'**
  String get prefsSaveError;

  /// No description provided for @preferencesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Preferências'**
  String get preferencesTitle;

  /// No description provided for @welcomePersonalization.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo à personalização da sua conta'**
  String get welcomePersonalization;

  /// No description provided for @chooseAreas.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma ou mais áreas de preferência para orientar as sugestões de badges no dashboard.'**
  String get chooseAreas;

  /// No description provided for @selectedCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} selecionadas'**
  String selectedCount(int count);

  /// No description provided for @clearSelection.
  ///
  /// In pt, this message translates to:
  /// **'Limpar seleção'**
  String get clearSelection;

  /// No description provided for @accountIdentificationError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível identificar a conta ativa.'**
  String get accountIdentificationError;

  /// No description provided for @couldNotLoadAreas.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as áreas.'**
  String get couldNotLoadAreas;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In pt, this message translates to:
  /// **'Selecione pelo menos uma área para continuar.'**
  String get selectAtLeastOne;

  /// No description provided for @couldNotSavePreferences.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível guardar as preferências.'**
  String get couldNotSavePreferences;

  /// No description provided for @preferencesSavedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Preferências guardadas com sucesso.'**
  String get preferencesSavedSuccess;

  /// No description provided for @searchPreferenceAreas.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar áreas de preferência'**
  String get searchPreferenceAreas;

  /// No description provided for @noAreasFound.
  ///
  /// In pt, this message translates to:
  /// **'Não foram encontradas áreas.'**
  String get noAreasFound;

  /// No description provided for @noAreasForTerm.
  ///
  /// In pt, this message translates to:
  /// **'Não foram encontradas áreas com esse termo.'**
  String get noAreasForTerm;

  /// No description provided for @badgesAvailable.
  ///
  /// In pt, this message translates to:
  /// **'{count} badges disponíveis'**
  String badgesAvailable(int count);

  /// No description provided for @savePreferencesButton.
  ///
  /// In pt, this message translates to:
  /// **'Guardar preferências'**
  String get savePreferencesButton;

  /// No description provided for @welcomeAchievementTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo a Bordo'**
  String get welcomeAchievementTitle;

  /// No description provided for @welcomeAchievementDescription.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo a plataforma de badges da Softinsa. Esta conquista celebra o seu primeiro login e o inicio da sua jornada.'**
  String get welcomeAchievementDescription;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @noName.
  ///
  /// In pt, this message translates to:
  /// **'Sem nome'**
  String get noName;

  /// No description provided for @memberSince.
  ///
  /// In pt, this message translates to:
  /// **'Membro desde {date}'**
  String memberSince(String date);

  /// No description provided for @profileLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a base de dados'**
  String get profileLoadError;

  /// No description provided for @pointsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get pointsLabel;

  /// No description provided for @rankingLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get rankingLabel;

  /// No description provided for @badgesLabel.
  ///
  /// In pt, this message translates to:
  /// **'Badges'**
  String get badgesLabel;

  /// No description provided for @topCompetencies.
  ///
  /// In pt, this message translates to:
  /// **'Maiores Competências'**
  String get topCompetencies;

  /// No description provided for @noDataAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados disponíveis.'**
  String get noDataAvailable;

  /// No description provided for @badgesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} badges · {points} pontos'**
  String badgesCount(int count, int points);

  /// No description provided for @remindersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes'**
  String get remindersTitle;

  /// No description provided for @newReminder.
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get newReminder;

  /// No description provided for @noRemindersYet.
  ///
  /// In pt, this message translates to:
  /// **'Sem lembretes ainda.'**
  String get noRemindersYet;

  /// No description provided for @couldNotIdentifyAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível identificar a sua conta.'**
  String get couldNotIdentifyAccount;

  /// No description provided for @reminderUpdatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete atualizado com sucesso.'**
  String get reminderUpdatedSuccess;

  /// No description provided for @reminderCreatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete criado com sucesso.'**
  String get reminderCreatedSuccess;

  /// No description provided for @reminderDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete \"{title}\" removido.'**
  String reminderDeleted(String title);

  /// No description provided for @reminderLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar lembretes: {error}'**
  String reminderLoadError(Object error);

  /// No description provided for @reminderProcessError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao processar lembrete: {error}'**
  String reminderProcessError(Object error);

  /// No description provided for @reminderDeleteError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao remover lembrete: {error}'**
  String reminderDeleteError(Object error);

  /// No description provided for @confirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar eliminação'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteReminder.
  ///
  /// In pt, this message translates to:
  /// **'Tem a certeza que deseja eliminar o lembrete \"{title}\"?'**
  String confirmDeleteReminder(String title);

  /// No description provided for @deleteButton.
  ///
  /// In pt, this message translates to:
  /// **'Eliminar'**
  String get deleteButton;

  /// No description provided for @editButton.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get editButton;

  /// No description provided for @newReminderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo Lembrete'**
  String get newReminderTitle;

  /// No description provided for @editReminderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Lembrete'**
  String get editReminderTitle;

  /// No description provided for @titleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite o título'**
  String get titleHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite a descrição'**
  String get descriptionHint;

  /// No description provided for @dateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get dateLabel;

  /// No description provided for @colorLabel.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get colorLabel;

  /// No description provided for @createButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get createButton;

  /// No description provided for @saveButton.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get saveButton;

  /// No description provided for @sessionsExpiredLogin.
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada. Faça login novamente.'**
  String get sessionsExpiredLogin;

  /// No description provided for @badgesObtainedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Badges Obtidos ({count})'**
  String badgesObtainedTitle(int count);

  /// No description provided for @deselectAll.
  ///
  /// In pt, this message translates to:
  /// **'Desselecionar'**
  String get deselectAll;

  /// No description provided for @selectAll.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar tudo'**
  String get selectAll;

  /// No description provided for @selectedCountBadges.
  ///
  /// In pt, this message translates to:
  /// **'{count} selecionados'**
  String selectedCountBadges(int count);

  /// No description provided for @exportPDF.
  ///
  /// In pt, this message translates to:
  /// **'Exportar PDF'**
  String get exportPDF;

  /// No description provided for @exportExcel.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Excel'**
  String get exportExcel;

  /// No description provided for @selectAtLeastOneBadge.
  ///
  /// In pt, this message translates to:
  /// **'Selecione pelo menos um badge para exportar.'**
  String get selectAtLeastOneBadge;

  /// No description provided for @noBadgesFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum badge encontrado.'**
  String get noBadgesFound;

  /// No description provided for @selectBadgeCertificate.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar badge para certificado'**
  String get selectBadgeCertificate;

  /// No description provided for @noBadgesAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum badge obtido disponível.'**
  String get noBadgesAvailable;

  /// No description provided for @exportCertificatePDF.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Certificado PDF'**
  String get exportCertificatePDF;

  /// No description provided for @certificateTitle.
  ///
  /// In pt, this message translates to:
  /// **'SOFTINSA'**
  String get certificateTitle;

  /// No description provided for @certificateSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Certificado de Conquista'**
  String get certificateSubtitle;

  /// No description provided for @certificateIssuedTo.
  ///
  /// In pt, this message translates to:
  /// **'Concedemos o presente certificado a'**
  String get certificateIssuedTo;

  /// No description provided for @certificateBadge.
  ///
  /// In pt, this message translates to:
  /// **'pela conquista da badge'**
  String get certificateBadge;

  /// No description provided for @nearExpiry.
  ///
  /// In pt, this message translates to:
  /// **'Perto de expirar'**
  String get nearExpiry;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @loadingError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados. Tente novamente.'**
  String get loadingError;

  /// No description provided for @rankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get rankingTitle;

  /// No description provided for @searchNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar notificações'**
  String get searchNotifications;

  /// No description provided for @filterNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar notificações'**
  String get filterNotifications;

  /// No description provided for @sortNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar notificações'**
  String get sortNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get allNotifications;

  /// No description provided for @alerts.
  ///
  /// In pt, this message translates to:
  /// **'Alertas'**
  String get alerts;

  /// No description provided for @informations.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get informations;

  /// No description provided for @success.
  ///
  /// In pt, this message translates to:
  /// **'Sucesso'**
  String get success;

  /// No description provided for @mostRecent.
  ///
  /// In pt, this message translates to:
  /// **'Mais recentes'**
  String get mostRecent;

  /// No description provided for @oldest.
  ///
  /// In pt, this message translates to:
  /// **'Mais antigas'**
  String get oldest;

  /// No description provided for @titleAZ.
  ///
  /// In pt, this message translates to:
  /// **'Título (A-Z)'**
  String get titleAZ;

  /// No description provided for @noNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Sem notificações para mostrar.'**
  String get noNotifications;

  /// No description provided for @showLess.
  ///
  /// In pt, this message translates to:
  /// **'Ver menos'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In pt, this message translates to:
  /// **'Ver mais'**
  String get showMore;

  /// No description provided for @messagesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens e Avisos'**
  String get messagesTitle;

  /// No description provided for @searchMessages.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar mensagens'**
  String get searchMessages;

  /// No description provided for @filterMessages.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar mensagens'**
  String get filterMessages;

  /// No description provided for @sortMessages.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar mensagens'**
  String get sortMessages;

  /// No description provided for @allMessages.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get allMessages;

  /// No description provided for @messages.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens'**
  String get messages;

  /// No description provided for @warnings.
  ///
  /// In pt, this message translates to:
  /// **'Avisos'**
  String get warnings;

  /// No description provided for @important.
  ///
  /// In pt, this message translates to:
  /// **'Importantes'**
  String get important;

  /// No description provided for @priority.
  ///
  /// In pt, this message translates to:
  /// **'Prioridade'**
  String get priority;

  /// No description provided for @noMessages.
  ///
  /// In pt, this message translates to:
  /// **'Sem mensagens para mostrar.'**
  String get noMessages;

  /// No description provided for @messagesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} mensagens'**
  String messagesCount(int count);

  /// No description provided for @attachments.
  ///
  /// In pt, this message translates to:
  /// **'Anexos'**
  String get attachments;

  /// No description provided for @couldNotOpenAttachment.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o anexo.'**
  String get couldNotOpenAttachment;

  /// No description provided for @alertType.
  ///
  /// In pt, this message translates to:
  /// **'Alerta'**
  String get alertType;

  /// No description provided for @infoType.
  ///
  /// In pt, this message translates to:
  /// **'Informação'**
  String get infoType;

  /// No description provided for @warningType.
  ///
  /// In pt, this message translates to:
  /// **'Aviso'**
  String get warningType;

  /// No description provided for @importantType.
  ///
  /// In pt, this message translates to:
  /// **'Importante'**
  String get importantType;

  /// No description provided for @messageType.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get messageType;

  /// No description provided for @rankingTitleScreen.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get rankingTitleScreen;

  /// No description provided for @suggestionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões'**
  String get suggestionsTitle;

  /// No description provided for @suggestionsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões personalizadas para si'**
  String get suggestionsSubtitle;

  /// No description provided for @suggestionsDescription.
  ///
  /// In pt, this message translates to:
  /// **'Explore áreas alinhadas com o seu perfil e descubra badges que fazem sentido para a sua evolução.'**
  String get suggestionsDescription;

  /// No description provided for @definePreferencesInSettings.
  ///
  /// In pt, this message translates to:
  /// **'Defina as suas preferências nas definições para receber sugestões alinhadas com a sua área.'**
  String get definePreferencesInSettings;

  /// No description provided for @suggestionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões e badges alinhados com as suas preferências.'**
  String get suggestionDescription;

  /// No description provided for @exportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportações'**
  String get exportsTitle;

  /// No description provided for @badgesTab.
  ///
  /// In pt, this message translates to:
  /// **'Badges'**
  String get badgesTab;

  /// No description provided for @certificateTab.
  ///
  /// In pt, this message translates to:
  /// **'Certificado'**
  String get certificateTab;

  /// No description provided for @certificateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Certificado'**
  String get certificateLabel;

  /// No description provided for @uploadEvidence.
  ///
  /// In pt, this message translates to:
  /// **'Anexar ficheiro'**
  String get uploadEvidence;

  /// No description provided for @submeter.
  ///
  /// In pt, this message translates to:
  /// **'Submeter'**
  String get submeter;

  /// No description provided for @requisitos.
  ///
  /// In pt, this message translates to:
  /// **'Requisitos'**
  String get requisitos;

  /// No description provided for @comentarioAvaliador.
  ///
  /// In pt, this message translates to:
  /// **'Comentário do Avaliador'**
  String get comentarioAvaliador;

  /// No description provided for @aAguardarValidacao.
  ///
  /// In pt, this message translates to:
  /// **'A aguardar validação.'**
  String get aAguardarValidacao;

  /// No description provided for @detalhesRequisito.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do requisito associado à candidatura.'**
  String get detalhesRequisito;

  /// No description provided for @ficheirosSubmetidos.
  ///
  /// In pt, this message translates to:
  /// **'Ficheiros submetidos:'**
  String get ficheirosSubmetidos;

  /// No description provided for @selecionarFicheiros.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar ficheiros'**
  String get selecionarFicheiros;

  /// No description provided for @enviar.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get enviar;

  /// No description provided for @candidatura.
  ///
  /// In pt, this message translates to:
  /// **'Candidatura'**
  String get candidatura;

  /// No description provided for @aprovadoStatus.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get aprovadoStatus;

  /// No description provided for @rejeitadoStatus.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitado'**
  String get rejeitadoStatus;

  /// No description provided for @emValidacaoStatus.
  ///
  /// In pt, this message translates to:
  /// **'Em Validação'**
  String get emValidacaoStatus;

  /// No description provided for @candidaturaEmProgressoStatus.
  ///
  /// In pt, this message translates to:
  /// **'Candidatura em Progresso'**
  String get candidaturaEmProgressoStatus;

  /// No description provided for @arquivosSubmetidos.
  ///
  /// In pt, this message translates to:
  /// **'{count} Arquivos Submetidos'**
  String arquivosSubmetidos(String count);

  /// No description provided for @jaPossuiBadge.
  ///
  /// In pt, this message translates to:
  /// **'Já possui esta badge!'**
  String get jaPossuiBadge;

  /// No description provided for @pedidoEnviadoSucesso.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado com sucesso! Em validação pelo Talent Manager.'**
  String get pedidoEnviadoSucesso;

  /// No description provided for @candidaturaCriada.
  ///
  /// In pt, this message translates to:
  /// **'Candidatura criada. Submeta evidências para continuar.'**
  String get candidaturaCriada;

  /// No description provided for @pedidoProcessado.
  ///
  /// In pt, this message translates to:
  /// **'Pedido processado.'**
  String get pedidoProcessado;

  /// No description provided for @erroSubmeterPedido.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao submeter pedido. Tente novamente.'**
  String get erroSubmeterPedido;

  /// No description provided for @evidenciasEnviadas.
  ///
  /// In pt, this message translates to:
  /// **'Evidências enviadas com sucesso.'**
  String get evidenciasEnviadas;

  /// No description provided for @falhaSubmeterEvidencias.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao submeter evidências: {error}'**
  String falhaSubmeterEvidencias(Object error);

  /// No description provided for @candidaturaSubmetida.
  ///
  /// In pt, this message translates to:
  /// **'Candidatura submetida com sucesso para avaliação.'**
  String get candidaturaSubmetida;

  /// No description provided for @falhaSubmeter.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao submeter: {error}'**
  String falhaSubmeter(Object error);

  /// No description provided for @erroCarregarRequisitos.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar requisitos: {error}'**
  String erroCarregarRequisitos(Object error);

  /// No description provided for @languageOption.
  ///
  /// In pt, this message translates to:
  /// **'Linguagem'**
  String get languageOption;

  /// No description provided for @languageOptionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma da aplicação'**
  String get languageOptionSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar idioma'**
  String get selectLanguage;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get spanish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
