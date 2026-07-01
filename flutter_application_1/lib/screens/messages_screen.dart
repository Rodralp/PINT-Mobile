import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/messages_api.dart';

class _FilterOption {
  const _FilterOption(this.id, this.label);

  final String id;
  final String label;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const int _itemsPerPage = 6;

  final TextEditingController _searchController = TextEditingController();
  List<BackendAnnouncementItem> _messages = const [];
  bool _isLoading = true;
  String _searchTerm = '';
  String _activeFilter = 'todos';
  String _sortBy = 'recentes';
  int _page = 1;
  int? _expandedMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await MessagesApi.instance.fetchMessages();
      if (!mounted) {
        return;
      }

      setState(() {
        _messages = items;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshMessages() async {
    await _loadMessages();
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

  String _typeLabel(String value) {
    switch (value.toLowerCase()) {
      case 'aviso':
        return 'Aviso';
      case 'importante':
        return 'Importante';
      case 'mensagem':
      default:
        return 'Mensagem';
    }
  }

  Color _typeAccent(String value) {
    switch (value.toLowerCase()) {
      case 'aviso':
        return const Color(0xFFF4C20D);
      case 'importante':
        return const Color(0xFFEF4444);
      case 'mensagem':
      default:
        return const Color(0xFF1A90F0);
    }
  }

  IconData _typeIcon(String value) {
    switch (value.toLowerCase()) {
      case 'aviso':
        return Icons.warning_amber_rounded;
      case 'importante':
        return Icons.priority_high_rounded;
      case 'mensagem':
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String _attachmentLabel(BackendAnnouncementAttachment attachment) {
    if (attachment.originalName.trim().isNotEmpty) {
      return attachment.originalName.trim();
    }

    return attachment.storedName.trim().isNotEmpty ? attachment.storedName.trim() : 'Anexo';
  }

  String _formatAttachmentSize(int bytes) {
    if (bytes <= 0) {
      return '';
    }

    final megabytes = bytes / (1024 * 1024);
    if (megabytes >= 1) {
      return '${megabytes.toStringAsFixed(megabytes >= 10 ? 0 : 1)} MB';
    }

    final kilobytes = bytes / 1024;
    return '${kilobytes.toStringAsFixed(kilobytes >= 10 ? 0 : 1)} KB';
  }

  List<BackendAnnouncementItem> get _filteredMessages {
    final search = _searchTerm.trim().toLowerCase();

    return _messages.where((item) {
      final filterMatch = _activeFilter == 'todos' || item.type.toLowerCase() == _activeFilter;
      final searchMatch = search.isEmpty ||
          item.title.toLowerCase().contains(search) ||
          item.summary.toLowerCase().contains(search) ||
          item.author.toLowerCase().contains(search) ||
          item.message.toLowerCase().contains(search);

      return filterMatch && searchMatch;
    }).toList(growable: false);
  }

  List<BackendAnnouncementItem> get _sortedMessages {
    final items = [..._filteredMessages];

    items.sort((a, b) {
      if (_sortBy == 'antigas') {
        return DateTime.tryParse(a.date)?.compareTo(DateTime.tryParse(b.date) ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? 0;
      }

      if (_sortBy == 'prioridade') {
        return a.priority.compareTo(b.priority) != 0
            ? a.priority.compareTo(b.priority)
            : (DateTime.tryParse(b.date)?.millisecondsSinceEpoch ?? 0)
                .compareTo(DateTime.tryParse(a.date)?.millisecondsSinceEpoch ?? 0);
      }

      return (DateTime.tryParse(b.date)?.millisecondsSinceEpoch ?? 0)
          .compareTo(DateTime.tryParse(a.date)?.millisecondsSinceEpoch ?? 0);
    });

    return items;
  }

  int get _totalPages {
    final pages = (_sortedMessages.length / _itemsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }

  List<BackendAnnouncementItem> get _pagedMessages {
    final start = (_page - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (_sortedMessages.isEmpty) {
      return const [];
    }

    return _sortedMessages.sublist(
      start.clamp(0, _sortedMessages.length),
      end.clamp(0, _sortedMessages.length),
    );
  }

  Future<void> _openAttachment(BackendAnnouncementItem message, BackendAnnouncementAttachment attachment) async {
    try {
      final url = await MessagesApi.instance.getAttachmentDownloadUrl(
        logId: message.id,
        fileId: attachment.id,
      );

      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Unable to open attachment.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel abrir o anexo.')),
      );
    }
  }

  void _setFilter(String value) {
    setState(() {
      _activeFilter = value;
      _page = 1;
      _expandedMessageId = null;
    });
  }

  void _setSort(String value) {
    setState(() {
      _sortBy = value;
      _page = 1;
      _expandedMessageId = null;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value;
      _page = 1;
      _expandedMessageId = null;
    });
  }

  void _goToPreviousPage() {
    setState(() {
      _page = (_page - 1).clamp(1, _totalPages);
      _expandedMessageId = null;
    });
  }

  void _goToNextPage() {
    setState(() {
      _page = (_page + 1).clamp(1, _totalPages);
      _expandedMessageId = null;
    });
  }

  void _toggleMessage(BackendAnnouncementItem message) {
    setState(() {
      _expandedMessageId = _expandedMessageId == message.id ? null : message.id;
    });
  }

  void _showFilterSheet() {
    final options = [
      const _FilterOption('todos', 'Todas'),
      const _FilterOption('mensagem', 'Mensagens'),
      const _FilterOption('aviso', 'Avisos'),
      const _FilterOption('importante', 'Importantes'),
    ];

    _showOptionsSheet(
      title: 'Filtrar mensagens',
      options: options,
      selectedId: _activeFilter,
      onSelected: _setFilter,
    );
  }

  void _showSortSheet() {
    final options = [
      const _FilterOption('recentes', 'Mais recentes'),
      const _FilterOption('antigas', 'Mais antigas'),
      const _FilterOption('prioridade', 'Prioridade'),
    ];

    _showOptionsSheet(
      title: 'Ordenar mensagens',
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
        title: const Text(
          'Mensagens e Avisos',
          style: TextStyle(
            fontSize: 24,
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
        onRefresh: _refreshMessages,
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
                              decoration: const InputDecoration(
                                hintText: 'Pesquisar mensagens',
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
                      label: 'Filtrar',
                      onTap: _showFilterSheet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _toolButton(
                      icon: Icons.tune_rounded,
                      label: 'Ordenar',
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
              else if (_pagedMessages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      'Sem mensagens para mostrar.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ..._pagedMessages.map((message) {
                          final accent = _typeAccent(message.type);
                          final expanded = _expandedMessageId == message.id;
                          final details = message.message.trim().isNotEmpty ? message.message.trim() : message.summary.trim();
                          final paragraphs = details
                              .split(RegExp(r'\r?\n'))
                              .map((entry) => entry.trim())
                              .where((entry) => entry.isNotEmpty)
                              .toList(growable: false);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: accent.withValues(alpha: 0.22), width: 2),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _toggleMessage(message),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: accent.withValues(alpha: 0.14),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _typeIcon(message.type),
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
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: accent.withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(999),
                                                      ),
                                                      child: Text(
                                                        _typeLabel(message.type),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          color: accent,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Icon(
                                                      expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  message.title.isNotEmpty ? message.title : 'Mensagem',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF243047),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  message.summary.isNotEmpty ? message.summary : details,
                                                  maxLines: expanded ? 10 : 2,
                                                  overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        message.author,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF4B5563),
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      _formatDate(message.date),
                                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (expanded) ...[
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 14),
                                        ...paragraphs.map(
                                          (paragraph) => Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              paragraph,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.45,
                                                color: Color(0xFF374151),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (message.attachments.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'Anexos',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ...message.attachments.map(
                                            (attachment) => Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                              ),
                                              child: ListTile(
                                                dense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                leading: const Icon(Icons.attach_file_rounded, color: Color(0xFF1A90F0)),
                                                title: Text(
                                                  _attachmentLabel(attachment),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  [
                                                    if (attachment.mimeType.trim().isNotEmpty) attachment.mimeType.trim(),
                                                    _formatAttachmentSize(attachment.size),
                                                  ].where((value) => value.trim().isNotEmpty).join(' • '),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                trailing: TextButton(
                                                  onPressed: () => _openAttachment(message, attachment),
                                                  child: const Text('Abrir'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_sortedMessages.length} mensagens',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _page > 1 ? _goToPreviousPage : null,
                                  icon: const Icon(Icons.chevron_left_rounded),
                                ),
                                Text('$_page / $_totalPages'),
                                IconButton(
                                  onPressed: _page < _totalPages ? _goToNextPage : null,
                                  icon: const Icon(Icons.chevron_right_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
    );
  }
}
