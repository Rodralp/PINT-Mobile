import 'package:flutter/material.dart';

String? resolveBadgeArtworkPath({
  String? badgeImage,
  String? levelKey,
  String? title,
  String? subtitle,
}) {
  final candidates = <String?>[badgeImage, levelKey, title, subtitle];

  String _stripDiacritics(String input) {
    var out = input;
    const map = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'Á': 'A',
      'À': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ä': 'A',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'Ó': 'O',
      'Ò': 'O',
      'Õ': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'ç': 'c',
      'Ç': 'C',
    };
    map.forEach((k, v) => out = out.replaceAll(k, v));
    return out;
  }

  for (final candidate in candidates) {
    final raw = candidate?.trim() ?? '';
    if (raw.isEmpty) {
      continue;
    }

    final normalized = _stripDiacritics(raw).toLowerCase();

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return raw;
    }

    if (normalized.contains('assets/badges/')) {
      return raw;
    }

    if (normalized.contains('junior')) {
      return 'assets/badges/junior.png';
    }
    if (normalized.contains('intermedio') || normalized.contains('interm')) {
      return 'assets/badges/intermedio.png';
    }
    if (normalized.contains('senior')) {
      return 'assets/badges/senior.png';
    }
    if (normalized.contains('especialista') ||
        normalized.contains('specialist')) {
      return 'assets/badges/especialista.png';
    }
    if (normalized.contains('badge_level_knowledge_lead') ||
        normalized.contains('knowledge_lead') ||
        normalized.contains('leader of knowledge') ||
        normalized.contains('lider') ||
        normalized.contains('conhecimento')) {
      return 'assets/badges/lider_conhecimento.png';
    }
  }

  return null;
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
  final EdgeInsetsGeometry imagePadding;

  @override
  Widget build(BuildContext context) {
    final resolvedPath = resolveBadgeArtworkPath(
      badgeImage: badgeImage,
      levelKey: levelKey,
      title: title,
      subtitle: subtitle,
    );

    final imageWidget = _buildImage(resolvedPath);

    // Render the badge artwork without an outer framed border.
    // We keep the background shape and color but remove the border
    // so the artwork appears without the square/frame around it.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: shape),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: imagePadding, child: imageWidget),
    );
  }

  Widget _buildImage(String? resolvedPath) {
    if (resolvedPath == null) {
      return Center(
        child: Icon(
          Icons.workspace_premium_outlined,
          color: frameColor,
          size: iconSize,
        ),
      );
    }

    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      return Image.network(
        resolvedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.workspace_premium_outlined,
            color: frameColor,
            size: iconSize,
          ),
        ),
      );
    }

    return Image.asset(
      resolvedPath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.workspace_premium_outlined,
          color: frameColor,
          size: iconSize,
        ),
      ),
    );
  }
}
