import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'backend_config.dart';

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: int.tryParse(
        json['nlembrete']?.toString() ?? 
        json['id']?.toString() ?? 
        json['id']?.toString() ?? 
        ''
      ) ?? 0,
      title: json['title']?.toString() ?? json['titulo']?.toString() ?? '',
      description: json['description']?.toString() ?? json['descricao']?.toString() ?? '',
      date: json['data_lembrete']?.toString() ?? 
            json['date']?.toString() ?? 
            json['data']?.toString() ?? '',
      color: json['color']?.toString() ?? json['cor']?.toString() ?? 'green',
    );
  }

  final int id;
  final String title;
  final String description;
  final String date;
  final String color;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'date': date,
    'color': color,
  };
}

class ReminderApiException implements Exception {
  const ReminderApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.responseBody,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? responseBody;

  @override
  String toString() => message;
}

class ReminderApi {
  ReminderApi._();

  static final ReminderApi instance = ReminderApi._();
  static const Duration _requestTimeout = Duration(seconds: 8);

  Future<Uri> _uri(String path) async {
    final baseUrl = await BackendConfig.getBaseUrl();
    return Uri.parse('$baseUrl$path');
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'data': response.body};
    }
  }

  Never _throwApiError(http.Response response) {
    final body = _decodeBody(response);
    throw ReminderApiException(
      body['message']?.toString() ?? 'Request failed.',
      statusCode: response.statusCode,
      code: body['code']?.toString(),
      responseBody: response.body,
    );
  }

  Future<http.Response> _getJson(Uri uri) async {
    try {
      return await http
          .get(uri, headers: const {'Content-Type': 'application/json'})
          .timeout(_requestTimeout);
    } on SocketException {
      throw ReminderApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw ReminderApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw ReminderApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<http.Response> _postJson(Uri uri, Map<String, dynamic> payload) async {
    try {
      return await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);
    } on SocketException {
      throw ReminderApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw ReminderApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw ReminderApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<http.Response> _putJson(Uri uri, Map<String, dynamic> payload) async {
    try {
      return await http
          .put(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);
    } on SocketException {
      throw ReminderApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw ReminderApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw ReminderApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<http.Response> _deleteJson(Uri uri) async {
    try {
      return await http
          .delete(uri, headers: const {'Content-Type': 'application/json'})
          .timeout(_requestTimeout);
    } on SocketException {
      throw ReminderApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw ReminderApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw ReminderApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<List<Reminder>> fetchReminders({required int accountId}) async {
    final uri = await _uri('/consultor/lembretes?accountId=$accountId');
    final response = await _getJson(uri);

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return <Reminder>[];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Reminder.fromJson)
          .toList();
    } catch (_) {
      return <Reminder>[];
    }
  }

  Future<Reminder> createReminder({
    required int accountId,
    required String title,
    required String description,
    required String date,
    required String color,
  }) async {
    final uri = await _uri('/consultor/lembretes');
    final payload = {
      'accountId': accountId,
      'title': title,
      'description': description,
      'date': date,
      'color': color,
    };

    // Debug log: payload being sent to server
    try {
      print('ReminderApi.createReminder -> POST $uri');
      print('Payload: ${jsonEncode(payload)}');
    } catch (_) {}

    final response = await _postJson(uri, payload);

    if (response.statusCode != 201 && response.statusCode != 200) {
      // Log response for debugging
      try {
        print('ReminderApi.createReminder -> Response ${response.statusCode}: ${response.body}');
      } catch (_) {}
      _throwApiError(response);
    }

    try {
      final decoded = jsonDecode(response.body);

      // Debug log
      try {
        print('ReminderApi.createReminder -> Success body: \\${response.body}');
      } catch (_) {}

      // Se a resposta é um array, pega o primeiro elemento
      if (decoded is List && decoded.isNotEmpty) {
        return Reminder.fromJson(decoded.first as Map<String, dynamic>);
      }

      // Se é um Map direto
      if (decoded is Map<String, dynamic>) {
        return Reminder.fromJson(decoded);
      }

      throw ReminderApiException('Formato de resposta inválido do servidor.');
    } catch (e) {
      if (e is ReminderApiException) rethrow;
      throw ReminderApiException('Erro ao processar resposta do servidor: ${e.toString()}');
    }
  }

  Future<Reminder> updateReminder({
    required int accountId,
    required int reminderId,
    required String title,
    required String description,
    required String date,
    required String color,
  }) async {
    final uri = await _uri('/consultor/lembretes/$reminderId');
    final payload = {
      'accountId': accountId,
      'title': title,
      'description': description,
      'date': date,
      'color': color,
    };

    final response = await _putJson(uri, payload);

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    try {
      final decoded = jsonDecode(response.body);
      
      // Se a resposta é um array, pega o primeiro elemento
      if (decoded is List && decoded.isNotEmpty) {
        return Reminder.fromJson(decoded.first as Map<String, dynamic>);
      }
      
      // Se é um Map direto
      if (decoded is Map<String, dynamic>) {
        return Reminder.fromJson(decoded);
      }
      
      throw ReminderApiException('Formato de resposta inválido do servidor.');
    } catch (e) {
      if (e is ReminderApiException) rethrow;
      throw ReminderApiException('Erro ao processar resposta do servidor: ${e.toString()}');
    }
  }

  Future<void> deleteReminder({
    required int accountId,
    required int reminderId,
  }) async {
    final uri = await _uri('/consultor/lembretes/$reminderId?accountId=$accountId');
    final response = await _deleteJson(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      _throwApiError(response);
    }
  }
}
