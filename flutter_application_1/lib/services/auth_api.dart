import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'backend_config.dart';

class AuthAccount {
  const AuthAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roles,
    required this.status,
    required this.hasPreferences,
  });

  factory AuthAccount.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);

    return AuthAccount(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? (roles.isNotEmpty ? roles.first : ''),
      roles: roles,
      status: json['status']?.toString() ?? '',
      hasPreferences: json['hasPreferences'] == true,
    );
  }

  final int id;
  final String name;
  final String email;
  final String role;
  final List<String> roles;
  final String status;
  final bool hasPreferences;
}

class BackendArea {
  const BackendArea({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceLine,
    required this.badgeCount,
    required this.selected,
  });

  factory BackendArea.fromJson(Map<String, dynamic> json) {
    return BackendArea(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      serviceLine: json['serviceLine']?.toString() ?? '',
      badgeCount: int.tryParse(json['badgeCount']?.toString() ?? '') ?? 0,
      selected: json['selected'] == true,
    );
  }

  final int id;
  final String name;
  final String description;
  final String serviceLine;
  final int badgeCount;
  final bool selected;
}

class AuthApiException implements Exception {
  const AuthApiException(
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

class AuthApi {
  AuthApi._();

  static final AuthApi instance = AuthApi._();
  static const Duration _requestTimeout = Duration(seconds: 8);

  Future<Uri> _uri(String path) async {
    final baseUrl = await BackendConfig.getBaseUrl();
    return Uri.parse('$baseUrl$path');
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
    throw AuthApiException(
      body['message']?.toString() ?? 'Request failed.',
      statusCode: response.statusCode,
      code: body['code']?.toString(),
      responseBody: response.body,
    );
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
      throw AuthApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw AuthApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw AuthApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<http.Response> _getJson(Uri uri) async {
    try {
      return await http
          .get(uri, headers: const {'Content-Type': 'application/json'})
          .timeout(_requestTimeout);
    } on SocketException {
      throw AuthApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw AuthApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw AuthApiException(
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
      throw AuthApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw AuthApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw AuthApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<AuthAccount> login({
    required String email,
    required String senha,
  }) async {
    final uri = await _uri('/auth/login');
    final response = await _postJson(uri, {'email': email, 'senha': senha});

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    return AuthAccount.fromJson(_decodeBody(response));
  }

  Future<AuthAccount> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final uri = await _uri('/auth/register');
    final response = await _postJson(uri, {
      'nome': nome,
      'email': email,
      'senha': senha,
    });

    if (response.statusCode != 201) {
      _throwApiError(response);
    }

    return AuthAccount.fromJson(_decodeBody(response));
  }

  Future<void> changePassword({
    required int accountId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = await _uri('/auth/change-password');
    final response = await _postJson(uri, {
      'accountId': accountId,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    if (response.statusCode != 200) {
      _throwApiError(response);
    }
  }

  Future<List<BackendArea>> fetchPreferenceAreas({
    required int accountId,
  }) async {
    final uri = await _uri(
      '/consultor/preferencias/areas?accountId=$accountId',
    );
    final response = await _getJson(uri);

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BackendArea.fromJson)
        .toList(growable: false);
  }

  Future<void> savePreferences({
    required int accountId,
    required List<int> areaIds,
  }) async {
    final uri = await _uri('/consultor/preferencias');
    final response = await _putJson(uri, {
      'accountId': accountId,
      'areaIds': areaIds,
    });

    if (response.statusCode != 200) {
      _throwApiError(response);
    }
  }
}
