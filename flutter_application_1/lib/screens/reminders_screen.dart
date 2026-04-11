import 'package:flutter/material.dart';

import 'app_shell_screen.dart';
import 'change_password_screen.dart';
import 'notifications_full_screen.dart';
import 'profile_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<_ReminderItem> _reminders = [
    _ReminderItem(
      title: 'Conferir requisitos enviados',
      description: 'Rever todos os requisitos do novo projeto',
      date: '07 Dez 2025',
      color: const Color(0xFF39D98A),
    ),
    _ReminderItem(
      title: 'Badge "C++ Mastery" expira em 30 dias',
      description: 'Renovar certificação antes do prazo',
      date: '29 Nov 2025',
      color: const Color(0xFFF7C500),
    ),
    _ReminderItem(
      title: 'Lembrete: Meta de 15 badges até ao fim do mês',
      description: 'Completar badges restantes para atingir a meta',
      date: '27 Nov 2025',
      color: const Color(0xFF1A90F0),
    ),
    _ReminderItem(
      title: 'Reunião de equipe trimestral',
      description: 'Preparar atualização de conquistas para partilha',
      date: '25 Nov 2025',
      color: const Color(0xFFA855F7),
    ),
  ];

  Future<void> _openReminderForm({_ReminderItem? existing, int? index}) async {
    final result = await showDialog<_ReminderItem>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _ReminderFormDialog(existing: existing),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      if (index != null) {
        _reminders[index] = result;
      } else {
        _reminders.insert(0, result);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index == null ? 'Lembrete criado com sucesso.' : 'Lembrete atualizado com sucesso.',
        ),
      ),
    );
  }

  void _removeReminder(int index) {
    final removedTitle = _reminders[index].title;
    setState(() {
      _reminders.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lembrete "$removedTitle" removido.'),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined, size: 32),
                    ),
                    Image.asset(
                      'assets/images/softinsa.png',
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsFullScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_none, size: 32),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lembretes',
                  style: TextStyle(
                    fontSize: 44 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openReminderForm(),
                  child: Container(
                    width: double.infinity,
                    height: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC6D2E1), width: 1.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 42, color: Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        Text(
                          'Novo Lembrete',
                          style: TextStyle(
                            fontSize: 40 / 2,
                            color: Colors.blueGrey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_reminders.length, (index) {
                  final reminder = _reminders[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == _reminders.length - 1 ? 0 : 14),
                    child: _ReminderCard(
                      color: reminder.color,
                      title: reminder.title,
                      subtitle: reminder.description,
                      date: reminder.date,
                      onEdit: () => _openReminderForm(existing: reminder, index: index),
                      onDelete: () => _removeReminder(index),
                    ),
                  );
                }),
              ],
            ),
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
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }

}

class _ReminderFormDialog extends StatefulWidget {
  const _ReminderFormDialog({this.existing});

  final _ReminderItem? existing;

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existing?.description ?? '');
    _dateController = TextEditingController(text: widget.existing?.date ?? '');
    _selectedColor = widget.existing?.color ?? const Color(0xFF39D98A);
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
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _ReminderItem(
        title: title,
        description: description,
        date: date,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Novo Lembrete' : 'Editar Lembrete',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF243047),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Título',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              _formField(
                controller: _titleController,
                hintText: 'Digite o título do lembrete',
              ),
              const SizedBox(height: 16),
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              _formField(
                controller: _descriptionController,
                hintText: 'Digite a descrição do lembrete',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Data',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              _formField(
                controller: _dateController,
                hintText: 'Ex: 15 Jan 2026',
              ),
              const SizedBox(height: 16),
              const Text(
                'Cor',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _colorOption(
                    color: const Color(0xFF39D98A),
                    selectedColor: _selectedColor,
                    onTap: () {
                      setState(() {
                        _selectedColor = const Color(0xFF39D98A);
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  _colorOption(
                    color: const Color(0xFFF7C500),
                    selectedColor: _selectedColor,
                    onTap: () {
                      setState(() {
                        _selectedColor = const Color(0xFFF7C500);
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  _colorOption(
                    color: const Color(0xFF1A90F0),
                    selectedColor: _selectedColor,
                    onTap: () {
                      setState(() {
                        _selectedColor = const Color(0xFF1A90F0);
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  _colorOption(
                    color: const Color(0xFFA855F7),
                    selectedColor: _selectedColor,
                    onTap: () {
                      setState(() {
                        _selectedColor = const Color(0xFFA855F7);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE5A5A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A90F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          widget.existing == null ? 'Criar Lembrete' : 'Guardar',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _formField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 20,
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1A90F0), width: 1.4),
        ),
      ),
    );
  }

  Widget _colorOption({
    required Color color,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedColor == color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? const Color(0xFF111827) : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color,
                        child: const Icon(
                          Icons.alarm,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF243047),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF64748B),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 30, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEdit,
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 34,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 18),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete_outline,
                          size: 34,
                          color: Color(0xFF64748B),
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
    );
  }
}

class _ReminderItem {
  const _ReminderItem({
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  final String title;
  final String description;
  final String date;
  final Color color;
}