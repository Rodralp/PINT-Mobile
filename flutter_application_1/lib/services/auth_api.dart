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
  static const Duration _requestTimeout = Duration(seconds: 60);

  Future<List<Uri>> _candidateUris(String path) async {
    final baseUrls = await BackendConfig.candidateBaseUrls();
    return baseUrls.map((baseUrl) => Uri.parse('$baseUrl$path')).toList(growable: false);
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

  Future<({http.Response response, String baseUrl})> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final uris = await _candidateUris(path);
    Object? lastError;

    for (final uri in uris) {
      try {
        final response = await http
            .post(
              uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);

        await BackendConfig.setBaseUrl('${uri.scheme}://${uri.authority}/api');
        return (response: response, baseUrl: '${uri.scheme}://${uri.authority}/api');
      } on SocketException catch (error) {
        lastError = error;
      } on HttpException catch (error) {
        lastError = error;
      } on TimeoutException catch (error) {
        lastError = error;
      }
    }

    throw AuthApiException(
      'Nao foi possivel ligar ao servidor. Verifique a rede e o endereco da API.',
      responseBody: lastError?.toString(),
    );
  }

  Future<({http.Response response, String baseUrl})> _getJson(
    String path,
  ) async {
    final uris = await _candidateUris(path);
    Object? lastError;

    for (final uri in uris) {
      try {
        final response = await http
            .get(uri, headers: const {'Content-Type': 'application/json'})
            .timeout(_requestTimeout);

        await BackendConfig.setBaseUrl('${uri.scheme}://${uri.authority}/api');
        return (response: response, baseUrl: '${uri.scheme}://${uri.authority}/api');
      } on SocketException catch (error) {
        lastError = error;
      } on HttpException catch (error) {
        lastError = error;
      } on TimeoutException catch (error) {
        lastError = error;
      }
    }

    throw AuthApiException(
      'Nao foi possivel ligar ao servidor. Verifique a rede e o endereco da API.',
      responseBody: lastError?.toString(),
    );
  }

  Future<({http.Response response, String baseUrl})> _putJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final uris = await _candidateUris(path);
    Object? lastError;

    for (final uri in uris) {
      try {
        final response = await http
            .put(
              uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);

        await BackendConfig.setBaseUrl('${uri.scheme}://${uri.authority}/api');
        return (response: response, baseUrl: '${uri.scheme}://${uri.authority}/api');
      } on SocketException catch (error) {
        lastError = error;
      } on HttpException catch (error) {
        lastError = error;
      } on TimeoutException catch (error) {
        lastError = error;
      }
    }

    throw AuthApiException(
      'Nao foi possivel ligar ao servidor. Verifique a rede e o endereco da API.',
      responseBody: lastError?.toString(),
    );
  }

  Future<AuthAccount> login({
    required String email,
    required String senha,
  }) async {
    final attempt = await _postJson('/auth/login', {'email': email, 'senha': senha});
    final response = attempt.response;

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    await BackendConfig.setBaseUrl(attempt.baseUrl);

    return AuthAccount.fromJson(_decodeBody(response));
  }

  Future<AuthAccount> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final attempt = await _postJson('/auth/register', {
      'nome': nome,
      'email': email,
      'senha': senha,
    });
    final response = attempt.response;

    if (response.statusCode != 201) {
      _throwApiError(response);
    }

    await BackendConfig.setBaseUrl(attempt.baseUrl);

    return AuthAccount.fromJson(_decodeBody(response));
  }

  Future<void> changePassword({
    required int accountId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final attempt = await _postJson('/auth/change-password', {
      'accountId': accountId,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    final response = attempt.response;

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    await BackendConfig.setBaseUrl(attempt.baseUrl);
  }

  Future<List<BackendArea>> fetchPreferenceAreas({
    required int accountId,
  }) async {
    final attempt = await _getJson('/consultor/preferencias/areas?accountId=$accountId');
    final response = attempt.response;

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    await BackendConfig.setBaseUrl(attempt.baseUrl);

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
    final attempt = await _putJson('/consultor/preferencias', {
      'accountId': accountId,
      'areaIds': areaIds,
    });
    final response = attempt.response;

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    await BackendConfig.setBaseUrl(attempt.baseUrl);
  }
}
