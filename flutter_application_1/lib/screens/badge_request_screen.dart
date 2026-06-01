import 'package:flutter/material.dart';

import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import 'messages_screen.dart';
import '../widgets/app_top_bar.dart';
import '../services/auth_session.dart';
import '../services/consultor_api.dart';

enum _RequestStatus { approved, pending, rejected }

class _RequestData {
  const _RequestData({
    required this.id,
    required this.title,
    required this.level,
    required this.date,
    required this.status,
  });

  final int id;
  final String title;
  final String level;
  final String date;
  final _RequestStatus status;
}

extension on _RequestStatus {
  String get label {
    switch (this) {
      case _RequestStatus.approved:
        return 'Aprovado';
      case _RequestStatus.pending:
        return 'Pendente';
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
    _RequestStatus.values,
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
          .map(
            (request) => _RequestData(
              id: request.id,
              title: request.badge,
              level: request.level,
              date: request.date ?? '',
              status: _requestStatusFromApi(request.status),
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
        return _RequestStatus.approved;
      case 'rejeitado':
      case 'rejected':
        return _RequestStatus.rejected;
      case 'pendente':
      case 'pending':
      case 'validacao':
      case 'em_validacao':
      case 'em_validacao_talento':
      case 'em_analise':
      case 'em_analise_talento':
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        size: 28,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            request.level.isEmpty ? 'Sem nivel' : request.level,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _detailChip('Estado', request.status.label,
                        color: request.status.textColor),
                    _detailChip(
                      'Data',
                      request.date.isEmpty ? '-' : request.date,
                    ),
                    _detailChip('Pedido', '#${request.id}'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Detalhes do pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Badge: ${request.title}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nivel: ${request.level.isEmpty ? '-' : request.level}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estado: ${request.status.label}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailChip(String label, String value, {Color? color}) {
    final chipColor = color ?? const Color(0xFF1A90F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
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
                  AppTopBar(
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
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Text(
                      'Lista de pedidos',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
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
