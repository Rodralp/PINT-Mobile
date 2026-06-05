import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_session.dart';
import '../services/consultor_api.dart';
import '../widgets/badge_artwork.dart';

enum OrderStatus { approved, pending, rejected }

class OrderDetailData {
  const OrderDetailData({
    required this.id,
    required this.badge,
    required this.level,
    required this.date,
    required this.status,
    this.badgeImage,
    this.badgeDbId,
    this.points = 0,
    this.expiresAt = '',
    this.area = '',
    this.path = '',
    this.submittedBy = '',
    this.submissionDate = '',
    this.reviewerName,
    this.reviewerDate,
    this.reviewerNote,
    this.requirements = const [],
  });

  final int id;
  final String badge;
  final String level;
  final String date;
  final OrderStatus status;
  final String? badgeImage;
  final int? badgeDbId;
  final int points;
  final String expiresAt;
  final String area;
  final String path;
  final String submittedBy;
  final String submissionDate;
  final String? reviewerName;
  final String? reviewerDate;
  final String? reviewerNote;
  final List<OrderRequirement> requirements;
}

class OrderRequirement {
  const OrderRequirement({
    required this.id,
    required this.title,
    required this.description,
    this.files = 0,
    this.attachments = const [],
  });

  final String id;
  final String title;
  final String description;
  final int files;
  final List<String> attachments;
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderDetailData order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderRequirement> _requirements = [];
  bool _isLoadingRequirements = false;
  String? _requirementsError;

  final Map<String, List<File>> _filesByRequirement = {};
  final Map<String, bool> _uploadingByRequirement = {};
  bool _submittingAll = false;
  bool _submitted = false;

  bool get _canUpload =>
      widget.order.status == OrderStatus.pending &&
      !_submitted;

  @override
  void initState() {
    super.initState();
    _requirements = List.from(widget.order.requirements);
    if (_requirements.isEmpty && widget.order.badgeDbId != null) {
      _loadRequirements();
    }
  }

  Future<void> _loadRequirements() async {
    final badgeDbId = widget.order.badgeDbId;
    if (badgeDbId == null) return;

    setState(() {
      _isLoadingRequirements = true;
      _requirementsError = null;
    });

    try {
      final data = await ConsultorApi.instance.fetchBadgeRequirements(
        badgeId: badgeDbId,
      );

      if (!mounted) return;

      setState(() {
        _requirements = data
            .map((r) => OrderRequirement(
                  id: r['id']?.toString() ?? '',
                  title: r['title']?.toString() ?? 'Requisito',
                  description: r['description']?.toString() ?? '',
                  files: r['files'] is int ? r['files'] as int : 0,
                  attachments: (r['attachments'] as List<dynamic>?)
                          ?.map((a) => a.toString())
                          .toList() ??
                      [],
                ))
            .toList();
        _isLoadingRequirements = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingRequirements = false;
        _requirementsError = 'Nao foi possivel carregar os requisitos.';
      });
    }
  }

  int _extractNreq(String requirementId) {
    final match = RegExp(r'(\d+)').firstMatch(requirementId);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  Future<void> _pickFiles(String requirementId) async {
    if (!_canUpload) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      final files = result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      if (!mounted) return;

      setState(() {
        _filesByRequirement.putIfAbsent(requirementId, () => []);
        _filesByRequirement[requirementId]!.addAll(files);
      });
    } on PlatformException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel selecionar ficheiros.'),
        ),
      );
    }
  }

  void _removeFile(String requirementId, int fileIndex) {
    setState(() {
      final files = _filesByRequirement[requirementId];
      if (files != null && fileIndex < files.length) {
        files.removeAt(fileIndex);
        if (files.isEmpty) {
          _filesByRequirement.remove(requirementId);
        }
      }
    });
  }

  Future<void> _uploadRequirement(String requirementId) async {
    final files = _filesByRequirement[requirementId];
    if (files == null || files.isEmpty) return;

    final nreq = _extractNreq(requirementId);
    if (nreq <= 0) return;

    setState(() {
      _uploadingByRequirement[requirementId] = true;
    });

    try {
      await ConsultorApi.instance.uploadEvidence(
        pedidoId: widget.order.id,
        nreq: nreq,
        files: files,
      );

      if (!mounted) return;

      setState(() {
        _filesByRequirement.remove(requirementId);
        _uploadingByRequirement[requirementId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencias submetidas com sucesso.'),
          backgroundColor: Color(0xFF05603A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadingByRequirement[requirementId] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao submeter evidencias: $e'),
          backgroundColor: const Color(0xFFA32424),
        ),
      );
    }
  }

  Future<void> _submitAllAndRequest() async {
    if (_submittingAll) return;

    final hasAnyFiles = _filesByRequirement.values.any(
      (files) => files.isNotEmpty,
    );

    if (!hasAnyFiles && _requirements.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um ficheiro antes de submeter.'),
        ),
      );
      return;
    }

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

      final accountId = await AuthSession.getAccountId();
      if (accountId == null) {
        throw const ConsultorApiException('Missing account id.');
      }

      await ConsultorApi.instance.requestBadgeAcquisition(
        accountId: accountId,
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
          content: Text('Candidatura submetida com sucesso.'),
          backgroundColor: Color(0xFF05603A),
        ),
      );
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildHeroCard(order, statusMeta),
                  _buildBreadcrumb(order),
                  _buildRequirementsSection(order),
                  if (_canUpload && _requirements.isNotEmpty) ...[
                    _buildSubmitButton(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: const Color(0xFF243047),
          ),
          const SizedBox(width: 8),
          const Text(
            'Candidatura',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243047),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(OrderDetailData order, _StatusMeta statusMeta) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: BadgeArtwork(
              size: 140,
              frameColor: statusMeta.frameColor,
              backgroundColor: statusMeta.frameColor.withOpacity(0.15),
              shape: BoxShape.circle,
              borderWidth: 8,
              iconSize: 72,
              badgeImage: order.badgeImage,
              levelKey: null,
              title: order.badge,
              subtitle: order.level,
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
            'Nivel ${order.level}',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF243047),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (order.expiresAt.isNotEmpty)
                _metaItem(Icons.schedule, 'Expira ${order.expiresAt}'),
              if (order.points > 0)
                _metaItem(Icons.emoji_events_outlined, '${order.points} pontos'),
              _metaItem(
                Icons.description_outlined,
                '${_requirements.length} requisitos',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: statusMeta.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: statusMeta.textColor, width: 1.6),
            ),
            child: Row(
              children: [
                Icon(statusMeta.icon, color: statusMeta.textColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusMeta.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: statusMeta.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(OrderDetailData order) {
    if (order.area.isEmpty && order.path.isEmpty) {
      return const SizedBox.shrink();
    }

    final parts = <String>[
      if (order.area.isNotEmpty) order.area,
      if (order.path.isNotEmpty) order.path,
      order.badge,
      order.level,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        parts.join(' > '),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildRequirementsSection(OrderDetailData order) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E2EC), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Requisitos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (_isLoadingRequirements)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_requirementsError != null)
            Text(
              _requirementsError!,
              style: const TextStyle(fontSize: 14, color: Color(0xFFA32424)),
            )
          else if (_requirements.isEmpty && !_isLoadingRequirements)
            const Text(
              'Sem requisitos disponiveis.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
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

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _submittingAll ? null : _submitAllAndRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A90F0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _submittingAll
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Submeter Candidatura',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
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
        return _StatusMeta(
          label: 'Candidatura em Progresso',
          icon: Icons.timelapse,
          textColor: const Color(0xFF1565C0),
          backgroundColor: const Color(0xFFE3F2FD),
          frameColor: const Color(0xFF2196F3),
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
