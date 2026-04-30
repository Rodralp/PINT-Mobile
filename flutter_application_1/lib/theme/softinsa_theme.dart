import 'package:flutter/material.dart';

class SoftinsaColors {
  static const Color blue = Color(0xFF0088FF);
  static const Color blueDark = Color(0xFF003A8C);
  static const Color ink = Color(0xFF0A0A0A);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF7F9FC);
  static const Color border = Color(0xFFE4EAF2);
  static const Color textMuted = Color(0xFF5B6472);
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0088FF), Color(0xFF002F59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SoftinsaShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}