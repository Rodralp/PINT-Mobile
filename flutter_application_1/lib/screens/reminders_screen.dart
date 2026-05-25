import 'package:flutter/material.dart';

import '../services/auth_session.dart';
import '../services/reminder_api.dart';
import '../services/reminder_repository.dart';
import 'app_shell_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';
import 'settings_menu_screen.dart';
import 'messages_screen.dart';
import '../widgets/app_top_bar.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;
  int? _accountId;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final accountId = await AuthSession.getAccountId();

      if (!mounted) return;

      if (accountId == null || accountId <= 0) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível identificar a sua conta.'),
            ),
          );
        }
        return;
      }

      setState(() {
        _accountId = accountId;
      });

      final reminders = await ReminderRepository.instance.loadReminders(
        accountId: accountId,
      );

      if (mounted) {
        setState(() {
          _reminders = List<Reminder>.from(reminders);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar lembretes: ${e.toString()}',
          ),
        ),
      );
    }
  }

  Color _colorStringToColor(String colorStr) {
    switch (colorStr) {
      case 'green':
      case '#4cd07d':
        return const Color(0xFF4cd07d);
      case 'yellow':
      case '#f4c20d':
        return const Color(0xFFF4c20d);
      case 'blue':
      case '#1f8fe5':
        return const Color(0xFF1f8fe5);
      case 'purple':
      case '#9851e8':
        return const Color(0xFF9851e8);
      default:
        return const Color(0xFF4cd07d);
    }
  }

  Future<void> _openReminderForm({Reminder? existing}) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _ReminderFormDialog(existing: existing),
    );

    if (result == null || !mounted) {
      return;
    }

    if (_accountId == null || _accountId! <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível identificar a conta ativa.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isEditing = existing != null;
      if (isEditing) {
        final updated = await ReminderRepository.instance.updateReminder(
          accountId: _accountId!,
          reminder: existing!,
          title: result['title']!,
          description: result['description']!,
          date: result['date']!,
          color: result['color']!,
        );

        if (!mounted) return;

        setState(() {
          final index = _reminders.indexWhere((r) => r.id == existing.id);
          if (index != -1) {
            _reminders[index] = updated;
          }
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lembrete atualizado com sucesso.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final created = await ReminderRepository.instance.createReminder(
          accountId: _accountId!,
          title: result['title']!,
          description: result['description']!,
          date: result['date']!,
          color: result['color']!,
        );

        if (!mounted) return;

        setState(() {
          _reminders.insert(0, created);
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lembrete criado com sucesso.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao processar lembrete: ${e.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    if (_accountId == null || _accountId! <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível identificar a conta ativa.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ReminderRepository.instance.deleteReminder(
        accountId: _accountId!,
        reminder: reminder,
      );

      if (!mounted) return;

      setState(() {
        _reminders.removeWhere((r) => r.id == reminder.id);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lembrete "${reminder.title}" removido.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao remover lembrete: ${e.toString()}',
          ),
        ),
      );
    }
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
      body: _isLoading && _reminders.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF243047),
                          ),
                          tooltip: 'Voltar',
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Lembretes',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF243047),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 24),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openReminderForm(),
                      child: Container(
                        width: double.infinity,
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFC6D2E1),
                            width: 1.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 32,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Novo Lembrete',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_reminders.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'Sem lembretes para mostrar.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_reminders.length, (index) {
                        final reminder = _reminders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ReminderCard(
                            color: _colorStringToColor(reminder.color),
                            title: reminder.title,
                            subtitle: reminder.description,
                            date: reminder.date,
                            onEdit: () => _openReminderForm(existing: reminder),
                            onDelete: () => _deleteReminder(reminder),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: NavigationBar(
        selectedIndex: 4,
        onDestinationSelected: (index) {
          if (index == 4) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AppShellScreen(initialIndex: index),
            ),
          );
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF2FF),
        height: 74,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Jornada',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'Pedidos',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
    );
  }
}

class _ReminderFormDialog extends StatefulWidget {
  const _ReminderFormDialog({this.existing});

  final Reminder? existing;

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late String _selectedColor;

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initial = DateTime.parse(_dateController.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _dateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  final List<Map<String, dynamic>> _colorOptions = [
    {'id': 'green', 'color': Color(0xFF4cd07d)},
    {'id': 'yellow', 'color': Color(0xFFf4c20d)},
    {'id': 'blue', 'color': Color(0xFF1f8fe5)},
    {'id': 'purple', 'color': Color(0xFF9851e8)},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _dateController = TextEditingController(text: widget.existing?.date ?? '');
    _selectedColor = widget.existing?.color ?? 'green';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final date = _dateController.text.trim();

    if (title.isEmpty || description.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'title': title,
        'description': description,
        'date': date,
        'color': _selectedColor,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Novo Lembrete' : 'Editar Lembrete',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF243047),
                ),
              ),
              const SizedBox(height: 24),
              _fieldLabel('Título'),
              const SizedBox(height: 8),
              _formField(
                controller: _titleController,
                hintText: 'Digite o título',
              ),
              const SizedBox(height: 20),
              _fieldLabel('Descrição'),
              const SizedBox(height: 8),
              _formField(
                controller: _descriptionController,
                hintText: 'Digite a descrição',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _fieldLabel('Data'),
              const SizedBox(height: 8),
              _formField(
                controller: _dateController,
                hintText: 'YYYY-MM-DD',
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              _fieldLabel('Cor'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colorOptions.map((option) {
                  return _colorOption(
                    option['id'] as String,
                    option['color'] as Color,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A90F0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        widget.existing == null ? 'Criar' : 'Guardar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1A90F0), width: 1.5),
        ),
      ),
    );
  }

  Widget _colorOption(String colorId, Color color) {
    final isSelected = _selectedColor == colorId;
    return InkWell(
      onTap: () => setState(() => _selectedColor = colorId),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? const Color(0xFF243047) : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  final Color color;
  final String title;
  final String subtitle;
  final String date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF243047),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                onEdit();
                              } else if (value == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Confirmar eliminação'),
                                    content: Text(
                                      'Tem a certeza que deseja eliminar o lembrete "$title"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirmed == true) {
                                  onDelete();
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert_rounded,
                                color: Color(0xFF64748B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
