import 'package:flutter/material.dart';

import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import 'messages_screen.dart';
import 'badges_screen.dart';
import '../widgets/app_top_bar.dart';
import '../services/auth_session.dart';
import '../services/consultor_api.dart';

enum _RequestStatus { approved, pending, inProgress, rejected }

class _RequestData {
  const _RequestData({
    required this.id,
    required this.title,
    required this.level,
    required this.date,
    required this.status,
    this.badgeDbId,
  });

  final int id;
  final String title;
  final String level;
  final String date;
  final _RequestStatus status;
  final int? badgeDbId;
}

extension on _RequestStatus {
  String get label {
    switch (this) {
      case _RequestStatus.approved:
        return 'Aprovado';
      case _RequestStatus.pending:
        return 'Pendente';
      case _RequestStatus.inProgress:
        return 'Em Progresso';
      case _RequestStatus.rejected:
        return 'Rejeitado';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case _RequestStatus.approved:
        return const Color(0xFFC9F0DE);
      case _RequestStatus.pending:
        return const Color(0xFFF7E8BF);
      case _RequestStatus.inProgress:
        return const Color(0xFFD0E8F7);
      case _RequestStatus.rejected:
        return const Color(0xFFF5D8D8);
    }
  }

  Color get textColor {
    switch (this) {
      case _RequestStatus.approved:
        return const Color(0xFF05603A);
      case _RequestStatus.pending:
        return const Color(0xFF9A5C09);
      case _RequestStatus.inProgress:
        return const Color(0xFF0B5FA3);
      case _RequestStatus.rejected:
        return const Color(0xFFA32424);
    }
  }
}

class BadgeRequestScreen extends StatefulWidget {
  const BadgeRequestScreen({super.key});

  @override
  State<BadgeRequestScreen> createState() => _BadgeRequestScreenState();
}

class _BadgeRequestScreenState extends State<BadgeRequestScreen> {
  final Set<_RequestStatus> _activeStatuses = Set<_RequestStatus>.from(
    _RequestStatus.values.where((s) => s != _RequestStatus.inProgress),
  );

  final List<_RequestData> _allRequests = [];
  late Future<void> _loadFuture;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId == null) {
        throw const ConsultorApiException('Missing account id.');
      }

      final data = await ConsultorApi.instance.fetchMyRequests(
        accountId: accountId,
      );
      final mapped = data
          .where((request) {
            final normalized = request.status.trim().toLowerCase().replaceAll(' ', '_');
            if (normalized == 'candidatura_em_progresso') return false;
            return true;
          })
          .map(
            (request) => _RequestData(
              id: request.id,
              title: request.badge,
              level: request.level,
              date: request.date ?? '',
              status: _requestStatusFromApi(request.status),
              badgeDbId: request.badgeDbId,
            ),
          )
          .toList(growable: false);

      if (!mounted) {
        return;
      }

      setState(() {
        _allRequests
          ..clear()
          ..addAll(mapped);
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = 'Nao foi possivel carregar a base de dados';
      });
    }
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _loadFuture = _loadRequests();
    });
    await _loadFuture;
  }

  _RequestStatus _requestStatusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'aprovado':
      case 'approved':
      case 'obtido':
        return _RequestStatus.approved;
      case 'rejeitado':
      case 'rejected':
      case 'evidencias_insuficientes':
        return _RequestStatus.rejected;
      case 'pendente-tm':
      case 'pendente-sll':
      case 'pendente':
      case 'pending':
      case 'validacao':
      case 'em_validacao':
      case 'em_validacao_talento':
      case 'em_validacao_tm':
      case 'em_validacao_sl':
      case 'em_validacao_sll':
      case 'em_analise':
      case 'em_analise_talento':
      case 'candidatura_em_progresso':
        return _RequestStatus.pending;
      default:
        return _RequestStatus.pending;
    }
  }

  List<_RequestData> get _filteredRequests {
    return _allRequests
        .where((request) => _activeStatuses.contains(request.status))
        .toList();
  }

  void _showRequestDetails(_RequestData request) {
    BadgeState? badgeState;
    switch (request.status) {
      case _RequestStatus.approved:
        badgeState = BadgeState.approved;
        break;
      case _RequestStatus.pending:
        badgeState = BadgeState.review;
        break;
      case _RequestStatus.rejected:
        badgeState = BadgeState.warning;
        break;
      case _RequestStatus.inProgress:
        badgeState = BadgeState.inProgress;
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BadgeLiveDetailScreen(
          badge: BadgeData(
            id: request.badgeDbId ?? 0,
            title: request.title,
            level: request.level,
            points: 0,
            date: request.date,
            badgeImage: null,
            frameColor: const Color(0xFFBFC4CD),
            iconBackground: const Color(0xFFF0F0F0),
            shape: BoxShape.rectangle,
            isOwned: request.status == _RequestStatus.approved,
            isSpecial: false,
            levelKey: null,
            stateId: null,
            state: badgeState,
            requestId: request.id,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) _refreshRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsMenuScreen(),
            ),
          );
        },
        onNotificationsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsFullScreen(),
            ),
          );
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
        onMessagesTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessagesScreen(),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRequests,
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _allRequests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_loadError != null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      _loadError!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: Text(
                    'Pedidos de Badges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF243047),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrar por:',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _RequestStatus.values
                              .where((s) => s != _RequestStatus.inProgress)
                              .map(
                                (status) => _FilterChipPill(
                                  label: status.label,
                                  backgroundColor: status.backgroundColor,
                                  textColor: status.textColor,
                                  selected: _activeStatuses.contains(status),
                                  onTap: () {
                                    setState(() {
                                      if (_activeStatuses.contains(status)) {
                                        _activeStatuses.remove(status);
                                      } else {
                                        _activeStatuses.add(status);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),
                  if (_filteredRequests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Sem pedidos para os filtros escolhidos.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ..._filteredRequests.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key == _filteredRequests.length - 1
                            ? 0
                            : 10,
                      ),
                      child: _RequestCard(
                        request: entry.value,
                        onView: () => _showRequestDetails(entry.value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            },
          ),
        ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const inactiveBackgroundColor = Color(0xFFF1F5F9);
    const inactiveTextColor = Color(0xFF64748B);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? backgroundColor : inactiveBackgroundColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: selected ? textColor : inactiveTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onView});

  final _RequestData request;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF243047),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.level,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: request.status.backgroundColor,
                ),
                child: Text(
                  request.status.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: request.status.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Data: ',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
              ),
              Text(
                request.date.isEmpty ? '-' : request.date,
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onView,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(82, 44),
                  side: const BorderSide(color: Color(0xFF1F2937), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ver',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
