import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/consultor_api.dart';
import '../services/auth_session.dart';
import 'order_detail_screen.dart';

enum BadgeState { owned, inProgress, review, warning, locked }

class BackendBadge {
  const BackendBadge({
    required this.id,
    required this.title,
    required this.level,
    required this.date,
    required this.state,
    required this.frameColor,
    this.requestId,
    this.isOwned = false,
  });

  final int id;
  final String title;
  final String level;
  final String date;
  final BadgeState? state;
  final Color frameColor;
  final int? requestId;
  final bool isOwned;
}

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<BackendBadge> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    // Simulação ou chamada real à API para carregar badges do utilizador
    setState(() => _isLoading = false);
  }

  void _openBadgeDetail(BackendBadge badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BadgeDetailSheet(badge: badge, onUpdate: _loadBadges),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('As Minhas Badges')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          final badge = _badges[index];
          return ListTile(
            title: Text(badge.title),
            subtitle: Text(badge.level),
            onTap: () => _openBadgeDetail(badge),
          );
        },
      ),
    );
  }
}

class _BadgeDetailSheet extends StatefulWidget {
  const _BadgeDetailSheet({required this.badge, required this.onUpdate});
  final BackendBadge badge;
  final VoidCallback onUpdate;

  @override
  State<_BadgeDetailSheet> createState() => _BadgeDetailSheetState();
}

class _BadgeDetailSheetState extends State<_BadgeDetailSheet> {
  bool _isRequesting = false;
  String? _resultMessage;
  bool _success = false;

  bool get _canRequest => widget.badge.state == null || widget.badge.state == BadgeState.locked;
  bool get _canContinue => widget.badge.state == BadgeState.inProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.badge.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (_canRequest)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isRequesting ? null : _handleRequest,
                child: _isRequesting ? const CircularProgressIndicator() : const Text('Pedir Badge'),
              ),
            ),
          if (_canContinue)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A90F0)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(
                        order: OrderDetailData(
                          id: widget.badge.requestId ?? 0,
                          badge: widget.badge.title,
                          level: widget.badge.level,
                          status: OrderStatus.pending,
                          date: widget.badge.date,
                          badgeDbId: widget.badge.id,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Continuar Candidatura', style: TextStyle(color: Colors.white)),
              ),
            ),
          const SizedBox(height: 16),
          if (_resultMessage != null)
            Text(_resultMessage!, style: TextStyle(color: _success ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Future<void> _handleRequest() async {
    setState(() => _isRequesting = true);
    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId != null) {
        final res = await ConsultorApi.instance.requestBadgeAcquisition(
          accountId: accountId,
          badgeId: widget.badge.id,
        );
        setState(() {
          _success = true;
          _resultMessage = 'Pedido criado! Continue para anexar ficheiros.';
          _isRequesting = false;
        });
        widget.onUpdate();
      }
    } catch (e) {
      setState(() {
        _success = false;
        _resultMessage = 'Erro: $e';
        _isRequesting = false;
      });
    }
  }
}
