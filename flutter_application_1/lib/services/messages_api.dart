import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_session.dart';
import 'backend_config.dart';

class BackendAnnouncementAttachment {
  const BackendAnnouncementAttachment({
    required this.id,
    required this.logId,
    required this.originalName,
    required this.storedName,
    required this.mimeType,
    required this.size,
    required this.path,
  });

  factory BackendAnnouncementAttachment.fromJson(Map<String, dynamic> json) {
    return BackendAnnouncementAttachment(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      logId: int.tryParse(json['logId']?.toString() ?? '') ?? 0,
      originalName: json['originalName']?.toString() ?? 'Ficheiro',
      storedName: json['storedName']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      size: int.tryParse(json['size']?.toString() ?? '') ?? 0,
      path: json['path']?.toString() ?? '',
    );
  }

  final int id;
  final int logId;
  final String originalName;
  final String storedName;
  final String mimeType;
  final int size;
  final String path;
}

class BackendAnnouncementItem {
  const BackendAnnouncementItem({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.summary,
    required this.author,
    required this.authorEmail,
    required this.date,
    required this.message,
    required this.attachments,
  });

  factory BackendAnnouncementItem.fromJson(Map<String, dynamic> json) {
    final body = json['message']?.toString() ?? '';
    final summary = (json['summary']?.toString() ?? '').trim();
    final attachments = (json['attachments'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendAnnouncementAttachment.fromJson)
        .where((item) => item.id > 0)
        .toList(growable: false);

    return BackendAnnouncementItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? 'mensagem',
      priority: int.tryParse(json['priority']?.toString() ?? '') ?? 3,
      title: json['title']?.toString() ?? '',
      summary: summary.isNotEmpty
          ? summary
          : (body.trim().isNotEmpty ? body.split(RegExp(r'\r?\n')).first.trim() : ''),
      author: json['author']?.toString() ?? 'Sistema',
      authorEmail: json['authorEmail']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      message: body,
      attachments: attachments,
    );
  }

  final int id;
  final String type;
  final int priority;
  final String title;
  final String summary;
  final String author;
  final String authorEmail;
  final String date;
  final String message;
  final List<BackendAnnouncementAttachment> attachments;
}

class MessagesApiException implements Exception {
  const MessagesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MessagesApi {
  MessagesApi._();

  static final MessagesApi instance = MessagesApi._();
  static const Duration _requestTimeout = Duration(seconds: 60);

  Future<int> _requireAccountId() async {
    final accountId = await AuthSession.getAccountId();
    if (accountId == null || accountId <= 0) {
      throw const MessagesApiException('Missing logged account id.');
    }
    return accountId;
  }

  Future<Uri> _uri(String path, int accountId) async {
    final baseUrl = await BackendConfig.getBaseUrl();
    final separator = path.contains('?') ? '&' : '?';
    return Uri.parse('$baseUrl$path${separator}accountId=$accountId');
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }

  Never _throwApiError(http.Response response) {
    final body = _decodeBody(response);
    throw MessagesApiException(body['message']?.toString() ?? 'Request failed.');
  }

  Future<http.Response> _getJson(Uri uri) async {
    try {
      return await http
          .get(uri, headers: const {'Content-Type': 'application/json'})
          .timeout(_requestTimeout);
    } on SocketException {
      throw MessagesApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw MessagesApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw MessagesApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<List<BackendAnnouncementItem>> fetchMessages() async {
    final accountId = await _requireAccountId();
    final uri = await _uri('/announcements', accountId);
    final response = await _getJson(uri);

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(BackendAnnouncementItem.fromJson)
        .where((item) => item.id > 0)
        .toList(growable: false);
  }

  Future<String> getAttachmentDownloadUrl({
    required int logId,
    required int fileId,
  }) async {
    final accountId = await _requireAccountId();
    final baseUrl = await BackendConfig.getBaseUrl();
    return '$baseUrl/announcements/${Uri.encodeComponent(logId.toString())}/files/${Uri.encodeComponent(fileId.toString())}/download?accountId=$accountId';
  }
}