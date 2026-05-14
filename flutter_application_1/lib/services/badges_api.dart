import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'backend_config.dart';

class BackendBadge {
  const BackendBadge({
    required this.id,
    required this.title,
    required this.level,
    required this.points,
    required this.status,
    required this.owned,
    required this.date,
    required this.area,
    required this.levelKey,
    required this.stateId,
  });

  factory BackendBadge.fromJson(Map<String, dynamic> json) {
    final area = _readString(json, ['area', 'areaName', 'categoria']);
    final levelKey = _readString(json, ['levelKey', 'nivelKey', 'badgeLevel', 'badge_level']);
    final level = _normalizeLevel(
      _readString(json, ['level', 'nivel', 'tier']),
      levelKey,
    );
    final points = _readInt(json, ['points', 'pontos', 'score']) ?? 0;
    final stateId = _readString(json, ['stateId', 'state_id', 'status', 'estado']);
    final status = _readString(json, ['status', 'state', 'estado']) ?? stateId;
    final owned = _readBool(json, [
          'owned',
          'isOwned',
          'obtained',
          'ownedByUser',
          'conquistado'
        ]) ??
        false;
    final date = _readString(json, [
      'date',
      'data',
      'validUntil',
      'expireAt',
      'expiresAt',
      'expiraEm'
    ]);
    final title = _readString(json, ['title', 'nome', 'name']) ?? area ?? '';

    return BackendBadge(
      id: _readInt(json, ['id', 'badgeId']) ?? 0,
      title: title,
      level: level,
      points: points,
      status: status,
      owned: owned,
      date: date,
      area: area,
      levelKey: levelKey,
      stateId: stateId,
    );
  }

  final int id;
  final String title;
  final String level;
  final int points;
  final String? status;
  final bool owned;
  final String? date;
  final String? area;
  final String? levelKey;
  final String? stateId;

  static String _normalizeLevel(String? level, String? levelKey) {
    final cleanedLevel = level?.trim();
    if (cleanedLevel != null && cleanedLevel.isNotEmpty) {
      return cleanedLevel;
    }
    switch (levelKey?.toLowerCase()) {
      case 'badge_level_junior':
        return 'Junior';
      case 'badge_level_intermediate':
        return 'Intermedio';
      case 'badge_level_senior':
        return 'Senior';
      case 'badge_level_specialist':
        return 'Especialista';
      case 'badge_level_knowledge_lead':
        return 'Lider de conhecimento';
      default:
        return levelKey ?? '';
    }
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value == null) {
        continue;
      }
      final text = value.toString().toLowerCase();
      if (text == 'true' || text == '1' || text == 'sim') {
        return true;
      }
      if (text == 'false' || text == '0' || text == 'nao' || text == 'não') {
        return false;
      }
    }
    return null;
  }
}

class BadgesApiException implements Exception {
  const BadgesApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

String? _readStringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

class BackendBadgeRequirement {
  const BackendBadgeRequirement({required this.text});

  factory BackendBadgeRequirement.fromJson(dynamic json) {
    if (json is String) {
      return BackendBadgeRequirement(text: json.trim());
    }
    if (json is Map<String, dynamic>) {
      final text = _readStringValue(json, [
            'text',
            'descricao',
            'description',
            'requirement',
            'requisito',
            'nome',
            'title'
          ]) ??
          json.toString();
      return BackendBadgeRequirement(text: text.trim());
    }
    return BackendBadgeRequirement(text: json.toString().trim());
  }

  final String text;
}

class BadgesApi {
  BadgesApi._();

  static final BadgesApi instance = BadgesApi._();
  static const Duration _requestTimeout = Duration(seconds: 8);

  Future<Uri> _uri(String path) async {
    final baseUrl = await BackendConfig.getBaseUrl();
    return Uri.parse('$baseUrl$path');
  }

  bool _looksLikeHtml(String body) {
    final trimmed = body.trimLeft();
    return trimmed.startsWith('<!DOCTYPE html') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<head') ||
        trimmed.startsWith('<body');
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }

    if (_looksLikeHtml(response.body)) {
      return const <String, dynamic>{
        'message': 'O servidor devolveu HTML em vez de JSON.'
      };
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'data': decoded};
    } on FormatException {
      return const <String, dynamic>{};
    }
  }

  Never _throwApiError(http.Response response) {
    final body = _decodeBody(response);
    throw BadgesApiException(
      body['message']?.toString() ?? 'Request failed.',
      statusCode: response.statusCode,
      code: body['code']?.toString(),
    );
  }

  Future<http.Response> _getJson(Uri uri) async {
    try {
      return await http
          .get(uri, headers: const {'Content-Type': 'application/json'})
          .timeout(_requestTimeout);
    } on SocketException {
      throw BadgesApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw BadgesApiException('Falha de comunicacao com o servidor ($uri).');
    } on TimeoutException {
      throw BadgesApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<Uri> _getUri(String path) async {
    final baseUrl = await BackendConfig.getBaseUrl();
    return Uri.parse('$baseUrl$path');
  }

  Future<List<BackendBadge>> fetchCatalog() async {
    final uri = await _uri('/consultor/catalog-badges');
    final response = await _getJson(uri);

    if (_looksLikeHtml(response.body)) {
      throw BadgesApiException(
        'A resposta do servidor nao e JSON ($uri). Verifique se a rota /consultor/catalog-badges existe no backend.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    try {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(BackendBadge.fromJson)
          .toList(growable: false);
    } on FormatException {
      throw BadgesApiException(
        'Falha ao interpretar a resposta do servidor ($uri).',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<BackendBadge>> fetchMyBadges({required int accountId}) async {
    final uri = await _uri('/consultor/meus-badges?accountId=$accountId');
    final response = await _getJson(uri);

    if (_looksLikeHtml(response.body)) {
      throw BadgesApiException(
        'A resposta do servidor nao e JSON ($uri). Verifique se a rota /consultor/meus-badges existe no backend.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    try {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(BackendBadge.fromJson)
          .toList(growable: false);
    } on FormatException {
      throw BadgesApiException(
        'Falha ao interpretar a resposta do servidor ($uri).',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<BackendBadgeRequirement>> fetchBadgeRequirements({
    required int badgeId,
  }) async {
    final uri = await _uri('/consultor/badge/$badgeId/requirements');
    final response = await _getJson(uri);

    if (_looksLikeHtml(response.body)) {
      throw BadgesApiException(
        'A resposta do servidor nao e JSON ($uri). Verifique se a rota /consultor/badge/{id}/requirements existe no backend.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    if (data is! List) {
      return const [];
    }

    return data
        .map(BackendBadgeRequirement.fromJson)
        .where((item) => item.text.isNotEmpty)
        .toList(growable: false);
  }
}
