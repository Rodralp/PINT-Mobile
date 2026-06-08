import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/consultor_api.dart';
import '../services/auth_session.dart';
import '../widgets/badge_artwork.dart';
import 'app_shell_screen.dart';

enum OrderStatus { approved, pending, rejected }

class OrderRequirement {
  const OrderRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.files,
    required this.attachments,
  });

  final String id;
  final String title;
  final String description;
  final int files;
  final List<String> attachments;
}

class OrderDetailData {
  OrderDetailData({
    required this.id,
    required this.badge,
    required this.level,
    required this.status,
    required this.date,
    this.badgeDbId,
    this.submittedBy = '',
    this.serviceLine = '',
    this.area = '',
    this.badgeImage,
    this.levelKey,
    this.isSpecial = false,
    this.frameColor = const Color(0xFFBFC4CD),
    this.shape = BoxShape.rectangle,
  });

  final int id;
  final String badge;
  final String level;
  OrderStatus status;
  final String date;
  final int? badgeDbId;
  final String submittedBy;
  final String serviceLine;
  final String area;
  final String? badgeImage;
  final String? levelKey;
  final bool isSpecial;
  final Color frameColor;
  final BoxShape shape;
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderDetailData order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final List<OrderRequirement> _requirements = [];
  bool _isLoadingRequirements = false;
  String? _requirementsError;

  final Map<String, List<File>> _filesByRequirement = {};
  final Map<String, bool> _uploadingByRequirement = {};

  bool _submittingAll = false;
  bool _submitted = false;

  String? _reviewerNote;
  String? _reviewerName;

  bool get _canUpload =>
      widget.order.status == OrderStatus.pending &&
      !_submitted;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (widget.order.badgeDbId == null && widget.order.id == 0) return;

    setState(() {
      _isLoadingRequirements = true;
      _requirementsError = null;
    });

    try {
      final detail = await ConsultorApi.instance.fetchPedidoDetail(
        pedidoId: widget.order.id,
      );

      if (!mounted) return;

      if (detail != null) {
        final reviewerNote = detail['reviewerNote']?.toString() ??
            detail['comentario']?.toString() ??
            detail['nota']?.toString();
        final reviewerName = detail['reviewerName']?.toString() ??
            detail['avaliador']?.toString();

        setState(() {
          _reviewerNote = reviewerNote;
          _reviewerName = reviewerName;
        });
      }

      final reqData = detail?['requirements'];
      final List<Map<String, dynamic>> reqList;
      if (reqData is List) {
        reqList = reqData.whereType<Map<String, dynamic>>().toList();
      } else {
        reqList = await ConsultorApi.instance.fetchBadgeRequirements(
          badgeId: widget.order.badgeDbId!,
        );
      }

      if (!mounted) return;

      setState(() {
        _requirements.clear();
        for (final item in reqList) {
          final title = item['titulo']?.toString() ??
              item['name']?.toString() ??
              item['requisito']?.toString() ??
              item['title']?.toString() ??
              'Sem titulo';
          final desc = item['descricao']?.toString() ??
              item['description']?.toString() ??
              '';
          final nreq = item['nreq']?.toString() ?? '';

          final List<String> attachments = [];
          if (item['evidencias'] is List) {
            for (final ev in item['evidencias']) {
              if (ev is Map && ev['ficheiro'] != null) {
                attachments.add(ev['ficheiro'].toString());
              }
            }
          }

          _requirements.add(OrderRequirement(
            id: nreq,
            title: title,
            description: desc,
            files: attachments.length,
            attachments: attachments,
          ));
        }
        _isLoadingRequirements = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRequirements = false;
        _requirementsError = 'Erro ao carregar requisitos: $e';
      });
    }
  }

  Future<void> _refreshDetail() async {
    _filesByRequirement.clear();
    _submitted = false;
    await _loadDetail();
  }

  int _extractNreq(String id) {
    return int.tryParse(id) ?? 0;
  }

  Future<void> _pickFiles(String requirementId) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final current = _filesByRequirement[requirementId] ?? [];
        current.addAll(result.paths.whereType<String>().map((p) => File(p)));
        _filesByRequirement[requirementId] = current;
      });
    }
  }

  void _removeFile(String requirementId, int index) {
    setState(() {
      _filesByRequirement[requirementId]?.removeAt(index);
    });
  }

  Future<void> _uploadRequirement(String requirementId) async {
    final files = _filesByRequirement[requirementId];
    if (files == null || files.isEmpty) return;

    final nreq = _extractNreq(requirementId);
    if (nreq <= 0) return;

    setState(() => _uploadingByRequirement[requirementId] = true);

    try {
      await ConsultorApi.instance.uploadEvidence(
        pedidoId: widget.order.id,
        nreq: nreq,
        files: files,
      );

      if (!mounted) return;

      setState(() {
        _uploadingByRequirement[requirementId] = false;
        _filesByRequirement[requirementId] = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencias enviadas com sucesso.')),
      );

      _loadDetail();
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingByRequirement[requirementId] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao submeter evidencias: $e')),
      );
    }
  }

  Future<void> _submitAllAndRequest() async {
    if (_submittingAll) return;

    setState(() => _submittingAll = true);

    try {
      for (final entry in _filesByRequirement.entries) {
        if (entry.value.isEmpty) continue;
        final nreq = _extractNreq(entry.key);
        if (nreq <= 0) continue;

        await ConsultorApi.instance.uploadEvidence(
          pedidoId: widget.order.id,
          nreq: nreq,
          files: entry.value,
        );
      }

      await ConsultorApi.instance.requestBadgeAcquisition(
        accountId: (await AuthSession.getAccountId())!,
        badgeId: widget.order.badgeDbId!,
      );

      if (!mounted) return;

      setState(() {
        _submittingAll = false;
        _submitted = true;
        _filesByRequirement.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidatura submetida com sucesso para avaliacao.'),
          backgroundColor: Color(0xFF05603A),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submittingAll = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao submeter: $e'),
          backgroundColor: const Color(0xFFA32424),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusMeta = _statusMeta(order.status);

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
          'Candidatura',
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
        onRefresh: _refreshDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(order, statusMeta),
              const SizedBox(height: 16),
              _buildRequirementsSection(),
              _buildReviewerSection(),
              if (_canUpload) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submittingAll ? null : _submitAllAndRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A90F0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _submittingAll
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Submeter',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: 1,
          onDestinationSelected: (index) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AppShellScreen(initialIndex: index)),
            );
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEAF2FF),
          height: 74,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Badges'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Jornada'),
            NavigationDestination(icon: Icon(Icons.history_outlined), label: 'Pedidos'),
            NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(OrderDetailData order, _StatusMeta statusMeta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: BadgeArtwork(
              size: 160,
              frameColor: order.frameColor,
              backgroundColor: const Color(0xFFF0F0F0).withOpacity(0.35),
              shape: order.shape,
              borderWidth: 10,
              iconSize: 86,
              badgeImage: order.badgeImage,
              levelKey: order.levelKey,
              title: order.badge,
              subtitle: order.level,
              isSpecial: order.isSpecial,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            order.badge,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243047),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.level,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF243047),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: statusMeta.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: statusMeta.frameColor, width: 1.6),
            ),
            child: Row(
              children: [
                Icon(statusMeta.icon, color: statusMeta.textColor, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusMeta.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: statusMeta.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (order.date.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 24),
                const SizedBox(width: 6),
                Text(
                  order.date,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requisitos',
            style: TextStyle(fontSize: 24 / 2, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_isLoadingRequirements)
            const Center(child: CircularProgressIndicator())
          else if (_requirementsError != null)
            Text(
              _requirementsError!,
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            )
          else if (_requirements.isEmpty)
            const Text(
              'Sem requisitos associados.',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            )
          else
            ..._requirements.map(
              (req) => _RequirementItem(
                requirement: req,
                canUpload: _canUpload,
                files: _filesByRequirement[req.id] ?? const [],
                isUploading: _uploadingByRequirement[req.id] ?? false,
                onPickFiles: () => _pickFiles(req.id),
                onRemoveFile: (index) => _removeFile(req.id, index),
                onUpload: () => _uploadRequirement(req.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewerSection() {
    final hasReviewer = _reviewerName != null && _reviewerName!.isNotEmpty;
    final hasNote = _reviewerNote != null && _reviewerNote!.isNotEmpty;

    if (!hasReviewer && !hasNote) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comentario do Avaliador',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (hasReviewer) ...[
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _reviewerName![0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _reviewerName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (hasNote)
            Text(
              _reviewerNote!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            )
          else
            const Text(
              'A aguardar validacao.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  _StatusMeta _statusMeta(OrderStatus status) {
    switch (status) {
      case OrderStatus.approved:
        return _StatusMeta(
          label: 'Aprovado',
          icon: Icons.check_circle_outline,
          textColor: const Color(0xFF05603A),
          backgroundColor: const Color(0xFFE6F9ED),
          frameColor: const Color(0xFF16C524),
        );
      case OrderStatus.rejected:
        return _StatusMeta(
          label: 'Rejeitado',
          icon: Icons.cancel_outlined,
          textColor: const Color(0xFFA32424),
          backgroundColor: const Color(0xFFFEE8E8),
          frameColor: const Color(0xFFFF3B30),
        );
      case OrderStatus.pending:
        return _submitted
            ? const _StatusMeta(
                label: 'Em Validacao',
                icon: Icons.hourglass_empty,
                textColor: Color(0xFF92400E),
                backgroundColor: Color(0xFFFEF3C7),
                frameColor: Color(0xFFF59E0B),
              )
            : const _StatusMeta(
                label: 'Candidatura em Progresso',
                icon: Icons.timelapse,
                textColor: Color(0xFF1565C0),
                backgroundColor: Color(0xFFE3F2FD),
                frameColor: Color(0xFF2196F3),
              );
    }
  }
}

class _StatusMeta {
  const _StatusMeta({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.frameColor,
  });

  final String label;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
  final Color frameColor;
}

class _RequirementItem extends StatefulWidget {
  const _RequirementItem({
    required this.requirement,
    required this.canUpload,
    required this.files,
    required this.isUploading,
    required this.onPickFiles,
    required this.onRemoveFile,
    required this.onUpload,
  });

  final OrderRequirement requirement;
  final bool canUpload;
  final List<File> files;
  final bool isUploading;
  final VoidCallback onPickFiles;
  final void Function(int index) onRemoveFile;
  final VoidCallback onUpload;

  @override
  State<_RequirementItem> createState() => _RequirementItemState();
}

class _RequirementItemState extends State<_RequirementItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final req = widget.requirement;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${req.files.toString().padLeft(2, '0')} Arquivos Submetidos',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 22,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.description.isNotEmpty
                        ? req.description
                        : 'Detalhes do requisito associado a candidatura.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  if (req.attachments.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Ficheiros submetidos:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...req.attachments.map(
                      (att) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                att,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (widget.canUpload) ...[
                    const SizedBox(height: 10),
                    _buildUploadArea(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    final pendingFiles = widget.files;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.isUploading ? null : widget.onPickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                SizedBox(width: 8),
                Text(
                  'Selecionar ficheiros',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (pendingFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...List.generate(pendingFiles.length, (index) {
            final file = pendingFiles[index];
            final name = file.path.split(Platform.pathSeparator).last;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 16,
                    color: Color(0xFF1A90F0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onRemoveFile(index),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: widget.isUploading ? null : widget.onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05603A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: widget.isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enviar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
