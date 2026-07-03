import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'badges_api.dart';
import 'consultor_api.dart';

class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  static const PdfColor _brandColor = PdfColor.fromInt(0xFF1D8CF8);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF111111);
  static const PdfColor _textMuted = PdfColor.fromInt(0xFF666666);

  String _translateLevel(String? levelKey) {
    const map = {
      'badge_level_junior': 'Nível Júnior',
      'badge_level_intermediate': 'Nível Intermédio',
      'badge_level_senior': 'Nível Sénior',
      'badge_level_specialist': 'Nível Especialista',
      'badge_level_knowledge_lead': 'Nível Líder de Conhecimento',
      'special': 'Especial',
      'junior': 'Nível Júnior',
      'intermedio': 'Nível Intermédio',
      'senior': 'Nível Sénior',
      'especialista': 'Nível Especialista',
      'lider': 'Nível Líder de Conhecimento',
    };
    return map[levelKey?.toLowerCase()] ?? levelKey ?? 'Nível';
  }

  String _escapeCsv(String? value) {
    final text = value ?? '';
    if (text.contains('"') || text.contains(';') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String todayIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ==================== PDF: Badges ====================

  Future<Uint8List> generateBadgesPDF(
    List<BackendBadge> badges,
    String userName,
  ) async {
    final doc = pw.Document();

    for (int i = 0; i < badges.length; i++) {
      final badge = badges[i];
      final levelLabel = _translateLevel(badge.levelKey);

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'SOFTINSA',
                style: pw.TextStyle(
                  color: _brandColor,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Badge ${i + 1} de ${badges.length}',
              style: pw.TextStyle(
                fontSize: 16,
                color: _textMuted,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _brandColor, width: 2),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _detailRow('Área', badge.area ?? badge.title),
                  pw.SizedBox(height: 8),
                  _detailRow('Nível', levelLabel),
                  pw.SizedBox(height: 8),
                  _detailRow('Pontos', badge.points.toString()),
                  pw.SizedBox(height: 8),
                  _detailRow('Data', badge.date ?? _todayFormatted()),
                  pw.SizedBox(height: 8),
                  _detailRow('ID', badge.id.toString()),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Dados da Badge',
              style: pw.TextStyle(
                color: _textMuted,
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              userName,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              badge.date ?? _todayFormatted(),
              style: pw.TextStyle(
                color: _textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return doc.save();
  }

  pw.Widget _detailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: _textDark,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            color: _brandColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==================== PDF: Certificado ====================

  Future<Uint8List> generateCertificatePDF(
    BackendBadge badge,
    String userName,
  ) async {
    final doc = pw.Document();
    final levelLabel = _translateLevel(badge.levelKey);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Center(
          child: pw.Container(
            width: 600,
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _brandColor, width: 3),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'SOFTINSA',
                  style: pw.TextStyle(
                    color: _brandColor,
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Certificado de Conquista',
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: _textDark,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Concedemos o presente certificado a',
                  style: pw.TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  userName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'pela conquista da badge',
                  style: pw.TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  badge.area ?? badge.title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _brandColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  levelLabel,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  badge.date ?? _todayFormatted(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return doc.save();
  }

  // ==================== PDF: Pedidos ====================

  Future<Uint8List> generateRequestsPDF(
    List<BackendRequest> requests,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Pedidos',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Data: ${_todayFormatted()}',
                    style: pw.TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 12,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0066FF),
              ),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellAlignment: pw.Alignment.centerLeft,
              cellHeight: 32,
              headerAlignment: pw.Alignment.centerLeft,
              headers: ['ID', 'Consultor', 'Badge', 'Nível', 'Data', 'Estado'],
              data: requests.map((r) => [
                r.id.toString(),
                r.badge,
                r.badge,
                r.level,
                r.date ?? '--',
                r.status,
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  // ==================== CSV ====================

  String generateBadgesCSV(List<BackendBadge> badges) {
    final bom = '\uFEFF';
    final headers = ['Nome', 'Área', 'Nível', 'Pontos', 'Data', 'ID'];
    final rows = badges.map((b) => [
      _escapeCsv(b.title),
      _escapeCsv(b.area),
      _escapeCsv(_translateLevel(b.levelKey)),
      b.points.toString(),
      _escapeCsv(b.date),
      b.id.toString(),
    ]).join(';');

    return '$bom${headers.join(';')}\n$rows';
  }

  String generateRequestsCSV(List<BackendRequest> requests) {
    const bom = '\uFEFF';
    final headers = ['ID', 'Consultor', 'Badge', 'Nível', 'Data', 'Estado'];
    final rows = requests.map((r) => [
      r.id.toString(),
      _escapeCsv(r.badge),
      _escapeCsv(r.badge),
      _escapeCsv(r.level),
      _escapeCsv(r.date),
      _escapeCsv(r.status),
    ]).join(';');

    return '$bom${headers.join(';')}\n$rows';
  }

  // ==================== Partilha / Guardar ====================

  Future<void> shareOrSavePDF(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
    );
  }

  Future<void> saveCSVToDevice(String csvContent, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
    );
  }
}
