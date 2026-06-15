import 'package:flutter/material.dart';

import '../services/notifications_api.dart';

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
      final items = await NotificationsApi.instance.fetchNotifications();
      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = items;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

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

  String _notificationTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'aviso':
        return 'Alerta';
      case 'importante':
        return 'Alerta';
      case 'evento':
        return 'Informação';
      default:
        return 'Informação';
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

  List<BackendNotificationItem> get _filteredNotifications {
    final search = _searchTerm.trim().toLowerCase();

    return _notifications.where((item) {
      final filterMatch = _activeFilter == 'todos' || _filterIdForType(item.type) == _activeFilter;
      final searchMatch = search.isEmpty ||
          item.title.toLowerCase().contains(search) ||
          item.summary.toLowerCase().contains(search) ||
          item.message.toLowerCase().contains(search) ||
          _notificationTypeLabel(item.type).toLowerCase().contains(search);

      return filterMatch && searchMatch;
    }).toList(growable: false);
  }

  List<BackendNotificationItem> get _sortedNotifications {
    final items = [..._filteredNotifications];

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

  int get _totalPages {
    final pages = (_sortedNotifications.length / _itemsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }

  List<BackendNotificationItem> get _pagedNotifications {
    final start = (_page - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (_sortedNotifications.isEmpty) {
      return const [];
    }

    return _sortedNotifications.sublist(
      start.clamp(0, _sortedNotifications.length),
      end.clamp(0, _sortedNotifications.length),
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
    if (item.isRead) {
      return;
    }

    try {
      await NotificationsApi.instance.markAsRead(item.id);
    } catch (_) {
      // Keep UI responsive even if the update fails.
    }

    if (!mounted) {
      return;
    }

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

  String _filterLabelFor(String value) {
    switch (value) {
      case 'alerta':
        return 'Alertas';
      case 'info':
        return 'Informações';
      case 'sucesso':
        return 'Sucesso';
      case 'todos':
      default:
        return 'Todas';
    }
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

  @override
  Widget build(BuildContext context) {
    final sortOptions = const [
      ('recentes', 'Mais recentes'),
      ('antigas', 'Mais antigas'),
      ('titulo_asc', 'Título (A-Z)'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 36),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Notificações',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF243047),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Pesquisar notificações',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton<String>(
                          onSelected: _setFilter,
                          position: PopupMenuPosition.over,
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'todos', child: Text('Todas')),
                            PopupMenuItem(value: 'alerta', child: Text('Alertas')),
                            PopupMenuItem(value: 'info', child: Text('Informações')),
                            PopupMenuItem(value: 'sucesso', child: Text('Sucesso')),
                          ],
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD7DDE7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.filter_alt_outlined, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _filterLabelFor(_activeFilter),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PopupMenuButton<String>(
                          onSelected: _setSort,
                          itemBuilder: (context) => sortOptions
                              .map(
                                (entry) => PopupMenuItem<String>(
                                  value: entry.$1,
                                  child: Text(entry.$2),
                                ),
                              )
                              .toList(growable: false),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD7DDE7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sort, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _sortBy == 'antigas'
                                        ? 'Mais antigas'
                                        : _sortBy == 'titulo_asc'
                                            ? 'Título (A-Z)'
                                            : 'Mais recentes',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                  else if (_pagedNotifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Text(
                          'Sem notificações para mostrar.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ..._pagedNotifications.expand((item) {
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
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
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
                                                  _notificationTypeLabel(item.type),
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
                                            ],
                                          ),
                                          if (expanded && details.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              details,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF243047),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _notificationIcon(item.type),
                                          color: accent,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () => _handleNotificationTap(item),
                                          child: Text(expanded ? 'Ver menos' : 'Ver mais'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        }),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _page > 1
                                  ? () => setState(() => _page -= 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            ...List.generate(_totalPages, (index) {
                              final pageNumber = index + 1;
                              final selected = pageNumber == _page;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: InkWell(
                                  onTap: () => setState(() => _page = pageNumber),
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
                                      '$pageNumber',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: selected ? const Color(0xFF1A90F0) : const Color(0xFF243047),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            IconButton(
                              onPressed: _page < _totalPages
                                  ? () => setState(() => _page += 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}