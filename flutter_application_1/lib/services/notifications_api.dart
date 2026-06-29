import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_session.dart';
import 'backend_config.dart';

class BackendNotificationItem {
  const BackendNotificationItem({
    required this.id,
    required this.logId,
    required this.isRead,
    required this.title,
    required this.summary,
    required this.message,
    required this.type,
    required this.date,
    required this.author,
  });

  factory BackendNotificationItem.fromJson(Map<String, dynamic> json) {
    return BackendNotificationItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      logId: int.tryParse(json['logId']?.toString() ?? '') ?? 0,
      isRead: json['isRead'] == true,
      title: json['title']?.toString() ?? 'Notificacao',
      summary: json['summary']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'mensagem',
      date: json['date']?.toString() ?? '',
      author: json['author']?.toString() ?? 'Sistema',
    );
  }

  final int id;
  final int logId;
  final bool isRead;
  final String title;
  final String summary;
  final String message;
  final String type;
  final String date;
  final String author;
}

class NotificationsApiException implements Exception {
  const NotificationsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotificationsApi {
  NotificationsApi._();

  static final NotificationsApi instance = NotificationsApi._();
  static const Duration _requestTimeout = Duration(seconds: 60);

  Future<int> _requireAccountId() async {
    final accountId = await AuthSession.getAccountId();
    if (accountId == null || accountId <= 0) {
      throw const NotificationsApiException('Missing logged account id.');
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
    throw NotificationsApiException(
      body['message']?.toString() ?? 'Request failed.',
    );
  }

  Future<http.Response> _getJson(Uri uri) async {
    try {
      return await http
          .get(uri, headers: const {'Content-Type': 'application/json'})
          .timeout(_requestTimeout);
    } on SocketException {
      throw NotificationsApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw NotificationsApiException(
        'Falha de comunicacao com o servidor ($uri).',
      );
    } on TimeoutException {
      throw NotificationsApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<http.Response> _patchJson(Uri uri, Map<String, dynamic> payload) async {
    try {
      return await http
          .patch(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);
    } on SocketException {
      throw NotificationsApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw NotificationsApiException(
        'Falha de comunicacao com o servidor ($uri).',
      );
    } on TimeoutException {
      throw NotificationsApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<List<BackendNotificationItem>> fetchNotifications() async {
    final accountId = await _requireAccountId();
    final uri = await _uri('/notifications', accountId);
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
        .map(BackendNotificationItem.fromJson)
        .where((item) => item.id > 0)
        .toList(growable: false);
  }

  Future<void> markAsRead(int notificationId) async {
    final accountId = await _requireAccountId();
    final baseUrl = await BackendConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrl/notifications/${Uri.encodeComponent(notificationId.toString())}/read');
    final response = await _patchJson(uri, {'accountId': accountId});

    if (response.statusCode != 200) {
      _throwApiError(response);
    }
  }
}