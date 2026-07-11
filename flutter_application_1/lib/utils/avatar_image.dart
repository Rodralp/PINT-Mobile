import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

ImageProvider<Object>? avatarImageProvider(String? rawAvatar) {
  final avatar = (rawAvatar ?? '').trim();
  if (avatar.isEmpty) {
    return null;
  }

  if (avatar.startsWith('data:image/')) {
    final commaIndex = avatar.indexOf(',');
    if (commaIndex <= 0 || commaIndex >= avatar.length - 1) {
      return null;
    }

    final base64Part = avatar.substring(commaIndex + 1).trim();
    if (base64Part.isEmpty) {
      return null;
    }

    try {
      final bytes = base64Decode(base64Part);
      if (bytes.isEmpty) {
        return null;
      }
      return MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }

  return NetworkImage(avatar);
}