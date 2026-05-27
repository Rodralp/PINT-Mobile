import 'package:flutter/material.dart';

import '../services/auth_session.dart';
import 'profile_screen.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late String _name = 'A carregar...';
  late String _email = 'A carregar...';
  late String _permissions = 'A carregar...';

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    try {
      final name = await AuthSession.getAccountName();
      final email = await AuthSession.getAccountEmail();
      final permissions = await AuthSession.getAccountPermissions();

      if (mounted) {
        setState(() {
          _name = _displayValue(name);
          _email = _displayValue(email);
          _permissions = _displayValue(_formatPermissions(permissions));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _name = 'Erro ao carregar';
          _email = 'Erro ao carregar';
          _permissions = 'Erro ao carregar';
        });
      }
    }
  }

  Future<void> _refreshAccountInfo() async {
    await _loadAccountInfo();
  }

  String _displayValue(String? value) {
    final cleaned = value?.trim() ?? '';
    return cleaned.isEmpty ? 'Sem informação' : cleaned;
  }

  String _formatPermissions(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return '';
    }

    return cleaned
        .split(';')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
  }

  void _goToDashboard() {
    Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAccountInfo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // HEADER COM BOTÃO VOLTAR
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 28),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Informação da conta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF243047),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // SUBTÍTULO
                  const Text(
                    'Consulte os dados principais da sua conta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  // CARD NOME
                  _InfoCard(label: 'Nome', value: _name),

                  const SizedBox(height: 16),

                  // CARD EMAIL
                  _InfoCard(label: 'Email', value: _email),

                  const SizedBox(height: 16),

                  // CARD PERFIL
                  _InfoCard(label: 'Perfil', value: _permissions),

                  const SizedBox(height: 30),

                  // BOTÃO IR PARA PERFIL
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _goToProfile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F2937),
                        side: const BorderSide(
                          color: Color(0xFFD7DDE7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ir para perfil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTÃO VOLTAR AO DASHBOARD
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _goToDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Voltar ao dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4EAF2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
