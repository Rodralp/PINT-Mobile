import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_session.dart';
import '../services/notification_repository.dart';
import '../services/notifications_api.dart';

class _FilterOption {
  const _FilterOption(this.id, this.label);

  final String id;
  final String label;
}

class NotificationsFullScreen extends StatefulWidget {
  const NotificationsFullScreen({super.key});

  @override
  State<NotificationsFullScreen> createState() => _NotificationsFullScreenState();
}

class _NotificationsFullScreenState extends State<NotificationsFullScreen> {
  static const int _itemsPerPage = 10;

  final TextEditingController _searchController = TextEditingController();
  List<BackendNotificationItem> _notifications = const [];
  bool _isLoading = true;
  String _searchTerm = '';
  String _activeFilter = 'todos';
  String _sortBy = 'recentes';
  int _page = 1;
  int? _expandedNotificationId;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId == null || accountId <= 0) {
        if (!mounted) return;
        setState(() {
          _notifications = const [];
        });
        return;
      }

      final items = await NotificationRepository.instance.loadNotifications(
        accountId: accountId,
      );
      if (!mounted) return;

      setState(() {
        _notifications = items;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _notifications = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) {
      return value.isEmpty ? '-' : value;
    }

    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _notificationTypeLabel(BuildContext context, String type) {
    final loc = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'aviso':
        return loc.alertType;
      case 'importante':
        return loc.alertType;
      case 'evento':
        return loc.infoType;
      default:
        return loc.infoType;
    }
  }

  Color _notificationAccent(String type) {
    switch (type.toLowerCase()) {
      case 'aviso':
        return const Color(0xFFF4C20D);
      case 'importante':
        return const Color(0xFFEF4444);
      case 'evento':
        return const Color(0xFF4CD07D);
      case 'mensagem':
      default:
        return const Color(0xFF1A90F0);
    }
  }

  IconData _notificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'aviso':
        return Icons.warning_amber_rounded;
      case 'importante':
        return Icons.error_outline;
      case 'evento':
        return Icons.event_available_outlined;
      case 'mensagem':
      default:
        return Icons.notifications_none_outlined;
    }
  }

  List<BackendNotificationItem> _filteredNotifications(BuildContext context) {
    final search = _searchTerm.trim().toLowerCase();

    return _notifications.where((item) {
      final filterMatch = _activeFilter == 'todos' || _filterIdForType(item.type) == _activeFilter;
      final searchMatch = search.isEmpty ||
          item.title.toLowerCase().contains(search) ||
          item.summary.toLowerCase().contains(search) ||
          item.message.toLowerCase().contains(search) ||
          _notificationTypeLabel(context, item.type).toLowerCase().contains(search);

      return filterMatch && searchMatch;
    }).toList(growable: false);
  }

  List<BackendNotificationItem> _sortedNotifications(BuildContext context) {
    final items = [..._filteredNotifications(context)];

    items.sort((a, b) {
      if (_sortBy == 'antigas') {
        return DateTime.tryParse(a.date)?.compareTo(DateTime.tryParse(b.date) ?? DateTime(1970)) ?? 0;
      }

      if (_sortBy == 'titulo_asc') {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }

      return (DateTime.tryParse(b.date)?.millisecondsSinceEpoch ?? 0)
          .compareTo(DateTime.tryParse(a.date)?.millisecondsSinceEpoch ?? 0);
    });

    return items;
  }

  int _totalPages(BuildContext context) {
    final pages = (_sortedNotifications(context).length / _itemsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }

  List<BackendNotificationItem> _pagedNotifications(BuildContext context) {
    final start = (_page - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (_sortedNotifications(context).isEmpty) {
      return const [];
    }

    return _sortedNotifications(context).sublist(
      start.clamp(0, _sortedNotifications(context).length),
      end.clamp(0, _sortedNotifications(context).length),
    );
  }

  String _filterIdForType(String type) {
    switch (type.toLowerCase()) {
      case 'aviso':
      case 'importante':
        return 'alerta';
      case 'evento':
        return 'sucesso';
      case 'mensagem':
      default:
        return 'info';
    }
  }

  Future<void> _markAsRead(BackendNotificationItem item) async {
    if (item.isRead) return;

    final accountId = await AuthSession.getAccountId();
    if (accountId == null || accountId <= 0) return;

    await NotificationRepository.instance.markAsRead(
      accountId: accountId,
      notificationId: item.id,
    );

    if (!mounted) return;

    setState(() {
      _notifications = _notifications
          .map((entry) => entry.id == item.id
              ? BackendNotificationItem(
                  id: entry.id,
                  logId: entry.logId,
                  isRead: true,
                  title: entry.title,
                  summary: entry.summary,
                  message: entry.message,
                  type: entry.type,
                  date: entry.date,
                  author: entry.author,
                )
              : entry)
          .toList(growable: false);
    });
  }

  Future<void> _handleNotificationTap(BackendNotificationItem item) async {
    await _markAsRead(item);

    if (!mounted) {
      return;
    }

    final details = item.message.trim().isNotEmpty ? item.message : item.summary.trim();

    if (details.isEmpty) {
      return;
    }

    setState(() {
      _expandedNotificationId = _expandedNotificationId == item.id ? null : item.id;
    });
  }

  void _setFilter(String value) {
    setState(() {
      _activeFilter = value;
      _page = 1;
      _expandedNotificationId = null;
    });
  }

  void _setSort(String value) {
    setState(() {
      _sortBy = value;
      _page = 1;
      _expandedNotificationId = null;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value;
      _page = 1;
      _expandedNotificationId = null;
    });
  }

  Widget _buildPagination() {
    final totalPages = _totalPages(context);
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = <Widget>[];

    pages.add(
      IconButton(
        onPressed: _page > 1 ? () => setState(() => _page -= 1) : null,
        icon: const Icon(Icons.chevron_left),
      ),
    );

    List<int> visiblePages = [];

    if (totalPages <= 7) {
      visiblePages = List.generate(totalPages, (i) => i + 1);
    } else {
      visiblePages.add(1);
      if (_page > 3) {
        visiblePages.add(-1);
      }
      final start = (_page - 1).clamp(2, totalPages - 1);
      final end = (_page + 1).clamp(2, totalPages - 1);
      for (var i = start; i <= end; i++) {
        if (!visiblePages.contains(i)) {
          visiblePages.add(i);
        }
      }
      if (_page < totalPages - 2) {
        visiblePages.add(-1);
      }
      if (!visiblePages.contains(totalPages)) {
        visiblePages.add(totalPages);
      }
    }

    for (final page in visiblePages) {
      if (page == -1) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          ),
        );
      } else {
        final selected = page == _page;
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => setState(() => _page = page),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFEAF2FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF1A90F0) : const Color(0xFF243047),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    pages.add(
      IconButton(
        onPressed: _page < totalPages
            ? () => setState(() => _page += 1)
            : null,
        icon: const Icon(Icons.chevron_right),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pages,
    );
  }

  void _showFilterSheet() {
    final loc = AppLocalizations.of(context)!;
    final options = [
      _FilterOption('todos', loc.allNotifications),
      _FilterOption('alerta', loc.alerts),
      _FilterOption('info', loc.informations),
      _FilterOption('sucesso', loc.success),
    ];

    _showOptionsSheet(
      title: loc.filterNotifications,
      options: options,
      selectedId: _activeFilter,
      onSelected: _setFilter,
    );
  }

  void _showSortSheet() {
    final loc = AppLocalizations.of(context)!;
    final options = [
      _FilterOption('recentes', loc.mostRecent),
      _FilterOption('antigas', loc.oldest),
      _FilterOption('titulo_asc', loc.titleAZ),
    ];

    _showOptionsSheet(
      title: loc.sortNotifications,
      options: options,
      selectedId: _sortBy,
      onSelected: _setSort,
    );
  }

  void _showOptionsSheet({
    required String title,
    required List<_FilterOption> options,
    required String selectedId,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...options.map(
                    (option) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option.label),
                      trailing: selectedId == option.id
                          ? const Icon(Icons.check, color: Color(0xFF1A90F0))
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(option.id);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF243047)),
        ),
        title: Text(
          loc.notificationPrefsTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243047),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E6F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[500], size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: loc.searchNotifications,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _toolButton(
                      icon: Icons.filter_alt_outlined,
                      label: loc.filterNotifications,
                      onTap: _showFilterSheet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _toolButton(
                      icon: Icons.tune_rounded,
                      label: loc.sortNotifications,
                      onTap: _showSortSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_pagedNotifications(context).isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      loc.noNotifications,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ..._pagedNotifications(context).expand((item) {
                          final details = item.message.trim().isNotEmpty ? item.message : item.summary;
                          final accent = _notificationAccent(item.type);
                          final expanded = _expandedNotificationId == item.id;

                          return [
                            InkWell(
                              onTap: () => _handleNotificationTap(item),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: accent.withValues(alpha: 0.25), width: 2.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: accent.withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _notificationIcon(item.type),
                                            color: accent,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  if (!item.isRead)
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      margin: const EdgeInsets.only(right: 8),
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xFF1A90F0),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF243047),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.summary.isNotEmpty ? item.summary : details,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: accent.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                    child: Text(
                                                      _notificationTypeLabel(context, item.type),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: accent,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    _formatDate(item.date),
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () => _handleNotificationTap(item),
                                                    child: Text(
                                                      expanded ? loc.showLess : loc.showMore,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF1A90F0),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (expanded && details.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                                      const SizedBox(height: 12),
                                      Text(
                                        details,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF243047),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ];
                        }),
                        const SizedBox(height: 10),
                        _buildPagination(),
                      ],
                    ),
                ],
              ),
            ),
          ),
    );
  }
}
