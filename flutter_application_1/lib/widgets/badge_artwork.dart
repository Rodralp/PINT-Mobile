import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

String _stripDiacritics(String input) {
  var out = input;
  const map = {
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
    'é': 'e', 'è': 'e', 'ê': 'e', 'É': 'E', 'È': 'E', 'Ê': 'E',
    'í': 'i', 'ì': 'i', 'î': 'i', 'Í': 'I', 'Ì': 'I', 'Î': 'I',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
    'ç': 'c', 'Ç': 'C',
  };
  map.forEach((k, v) => out = out.replaceAll(k, v));
  return out;
}

String _normalize(String? value) => _stripDiacritics('${value ?? ''}').trim().toLowerCase();

Uint8List? _decodeDataUrl(String url) {
  if (!url.contains('base64,')) return null;
  final b64 = url.split('base64,').last.trim();
  if (b64.isEmpty) return null;
  try {
    return base64Decode(b64);
  } catch (_) {
    return null;
  }
}

String? resolveBadgeArtworkPath({
  String? badgeImage,
  String? levelKey,
  String? title,
  String? subtitle,
}) {
  final nLevel = _normalize(levelKey);
  if (nLevel.isNotEmpty) {
    if (nLevel.contains('junior')) return 'assets/badges/junior_frame.png';
    if (nLevel.contains('intermediate') || nLevel.contains('intermedio') || nLevel.contains('interm')) {
      return 'assets/badges/intermediate_frame.png';
    }
    if (nLevel.contains('senior')) return 'assets/badges/senior_frame.png';
    if (nLevel.contains('especialista') || nLevel.contains('specialist')) {
      return 'assets/badges/specialist_frame.png';
    }
    if (nLevel.contains('knowledge_lead') || nLevel.contains('lider') || nLevel.contains('lead')) {
      return 'assets/badges/knowledge_lead_frame.png';
    }
    if (nLevel.contains('special')) return 'assets/badges/special_frame.png';
  }

  for (final candidate in [title, subtitle]) {
    final n = _normalize(candidate);
    if (n.isEmpty) continue;
    if (n.contains('junior')) return 'assets/badges/junior_frame.png';
    if (n.contains('intermedio') || n.contains('interm')) return 'assets/badges/intermediate_frame.png';
    if (n.contains('senior')) return 'assets/badges/senior_frame.png';
    if (n.contains('especialista') || n.contains('specialist')) return 'assets/badges/specialist_frame.png';
    if (n.contains('lider') || n.contains('conhecimento')) return 'assets/badges/knowledge_lead_frame.png';
    if (n.contains('especial') || n.contains('special')) return 'assets/badges/special_frame.png';
  }

  return null;
}

String? resolveBadgeFramePath({String? levelKey, String? title, String? subtitle}) {
  final nLevel = _normalize(levelKey);
  if (nLevel.isNotEmpty && nLevel != 'null') {
    if (nLevel.contains('junior')) return 'assets/badges/junior_frame.png';
    if (nLevel.contains('intermediate') || nLevel.contains('intermedio') || nLevel.contains('interm')) {
      return 'assets/badges/intermediate_frame.png';
    }
    if (nLevel.contains('senior')) return 'assets/badges/senior_frame.png';
    if (nLevel.contains('especialista') || nLevel.contains('specialist')) {
      return 'assets/badges/specialist_frame.png';
    }
    if (nLevel.contains('knowledge_lead') || nLevel.contains('lider') || nLevel.contains('lead')) {
      return 'assets/badges/knowledge_lead_frame.png';
    }
    if (nLevel.contains('special')) return 'assets/badges/special_frame.png';
  }

  for (final candidate in [title, subtitle]) {
    final n = _normalize(candidate);
    if (n.isEmpty) continue;
    if (n.contains('junior')) return 'assets/badges/junior_frame.png';
    if (n.contains('intermedio') || n.contains('interm')) return 'assets/badges/intermediate_frame.png';
    if (n.contains('senior')) return 'assets/badges/senior_frame.png';
    if (n.contains('especialista') || n.contains('specialist')) return 'assets/badges/specialist_frame.png';
    if (n.contains('lider') || n.contains('conhecimento')) return 'assets/badges/knowledge_lead_frame.png';
    if (n.contains('especial') || n.contains('special')) return 'assets/badges/special_frame.png';
  }

  return 'assets/badges/special_frame.png';
}

String? resolveBadgeMaskPath({String? levelKey, String? title, String? subtitle}) {
  final nLevel = _normalize(levelKey);
  if (nLevel.isNotEmpty && nLevel != 'null') {
    if (nLevel.contains('junior')) return 'assets/badges/junior_mask.png';
    if (nLevel.contains('intermediate') || nLevel.contains('intermedio') || nLevel.contains('interm')) {
      return 'assets/badges/intermediate_mask.png';
    }
    if (nLevel.contains('senior')) return 'assets/badges/senior_mask.png';
    if (nLevel.contains('especialista') || nLevel.contains('specialist')) {
      return 'assets/badges/specialist_mask.png';
    }
    if (nLevel.contains('knowledge_lead') || nLevel.contains('lider') || nLevel.contains('lead')) {
      return 'assets/badges/knowledge_lead_mask.png';
    }
    if (nLevel.contains('special')) return 'assets/badges/special_mask.png';
  }

  for (final candidate in [title, subtitle]) {
    final n = _normalize(candidate);
    if (n.isEmpty) continue;
    if (n.contains('junior')) return 'assets/badges/junior_mask.png';
    if (n.contains('intermedio') || n.contains('interm')) return 'assets/badges/intermediate_mask.png';
    if (n.contains('senior')) return 'assets/badges/senior_mask.png';
    if (n.contains('especialista') || n.contains('specialist')) return 'assets/badges/specialist_mask.png';
    if (n.contains('lider') || n.contains('conhecimento')) return 'assets/badges/knowledge_lead_mask.png';
    if (n.contains('especial') || n.contains('special')) return 'assets/badges/special_mask.png';
  }

  return 'assets/badges/special_mask.png';
}

bool isSpecialBadge({String? levelKey}) {
  final n = _normalize(levelKey);
  return n.isEmpty || n == 'null' || n == 'special';
}

class BadgeArtwork extends StatelessWidget {
  const BadgeArtwork({
    super.key,
    required this.size,
    required this.frameColor,
    required this.backgroundColor,
    required this.shape,
    this.borderWidth = 1,
    this.iconSize = 24,
    this.badgeImage,
    this.levelKey,
    this.title,
    this.subtitle,
    this.isSpecial = false,
    this.imagePadding = EdgeInsets.zero,
  });

  final double size;
  final Color frameColor;
  final Color backgroundColor;
  final BoxShape shape;
  final double borderWidth;
  final double iconSize;
  final String? badgeImage;
  final String? levelKey;
  final String? title;
  final String? subtitle;
  final bool isSpecial;
  final EdgeInsetsGeometry imagePadding;

  @override
  Widget build(BuildContext context) {
    final framePath = resolveBadgeFramePath(levelKey: levelKey, title: title, subtitle: subtitle);
    final maskPath = resolveBadgeMaskPath(levelKey: levelKey, title: title, subtitle: subtitle);
    final hasContent = badgeImage != null && badgeImage!.isNotEmpty;

    if (framePath == null || maskPath == null) {
      return _buildFallback(size, frameColor, iconSize);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasContent)
            _MaskedImage(
              imageUrl: badgeImage!,
              maskAsset: maskPath,
              size: size,
            )
          else
            _buildFrameOnlyBadge(size, maskPath),
          Image.asset(
            framePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameOnlyBadge(double size, String maskPath) {
    final maskProvider = AssetImage(maskPath);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0, 0, 0, 0, 1,
          0, 0, 0, 0, 1,
          0, 0, 0, 0, 1,
          0, 0, 0, 0.9, 0,
        ]),
        child: Image(
          image: maskProvider,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  static Widget _buildFallback(double size, Color frameColor, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: frameColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.workspace_premium_outlined,
        color: frameColor,
        size: iconSize,
      ),
    );
  }
}

class _MaskedImage extends StatefulWidget {
  const _MaskedImage({
    required this.imageUrl,
    required this.maskAsset,
    required this.size,
  });

  final String imageUrl;
  final String maskAsset;
  final double size;

  @override
  State<_MaskedImage> createState() => _MaskedImageState();
}

class _MaskedImageState extends State<_MaskedImage> {
  ui.Image? _contentImage;
  ui.Image? _maskImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didUpdateWidget(covariant _MaskedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.maskAsset != widget.maskAsset) {
      _loadImages();
    }
  }

  Future<ui.Image> _resolveToImage(ImageProvider provider, Size size) async {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration(size: size));
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        stream.removeListener(listener);
        completer.complete(info.image);
      },
      onError: (error, stackTrace) {
        stream.removeListener(listener);
        completer.completeError(error, stackTrace);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  Future<void> _loadImages() async {
    ImageProvider content;
    if (widget.imageUrl.startsWith('data:')) {
      final bytes = _decodeDataUrl(widget.imageUrl);
      if (bytes == null) return;
      content = MemoryImage(bytes);
    } else if (widget.imageUrl.startsWith('http://') || widget.imageUrl.startsWith('https:')) {
      content = NetworkImage(widget.imageUrl);
    } else {
      content = AssetImage(widget.imageUrl);
    }

    final mask = AssetImage(widget.maskAsset);
    final size = Size(widget.size, widget.size);

    try {
      final results = await Future.wait([
        _resolveToImage(content, size),
        _resolveToImage(mask, size),
      ]);
      if (!mounted) return;
      setState(() {
        _contentImage = results[0];
        _maskImage = results[1];
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_contentImage == null || _maskImage == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _MaskedImagePainter(
        contentImage: _contentImage!,
        maskImage: _maskImage!,
      ),
    );
  }
}

class _MaskedImagePainter extends CustomPainter {
  _MaskedImagePainter({required this.contentImage, required this.maskImage});

  final ui.Image contentImage;
  final ui.Image maskImage;

  Rect _containRect(ui.Image img, Size canvasSize) {
    final iw = img.width.toDouble();
    final ih = img.height.toDouble();
    final cw = canvasSize.width;
    final ch = canvasSize.height;
    final scale = cw / iw < ch / ih ? cw / iw : ch / ih;
    final dw = iw * scale;
    final dh = ih * scale;
    return Rect.fromLTWH(
      (cw - dw) / 2,
      (ch - dh) / 2,
      dw,
      dh,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());

    final contentDst = _containRect(contentImage, size);
    canvas.drawImageRect(
      contentImage,
      Rect.fromLTWH(0, 0, contentImage.width.toDouble(), contentImage.height.toDouble()),
      contentDst,
      Paint()..filterQuality = FilterQuality.high,
    );

    final maskDst = _containRect(maskImage, size);
    canvas.drawImageRect(
      maskImage,
      Rect.fromLTWH(0, 0, maskImage.width.toDouble(), maskImage.height.toDouble()),
      maskDst,
      Paint()..blendMode = BlendMode.dstIn,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MaskedImagePainter oldDelegate) =>
      oldDelegate.contentImage != contentImage || oldDelegate.maskImage != maskImage;
}
