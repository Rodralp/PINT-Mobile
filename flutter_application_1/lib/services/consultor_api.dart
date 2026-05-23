import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'backend_config.dart';

class ConsultorApiException implements Exception {
  const ConsultorApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class BackendRequest {
  const BackendRequest({
    required this.id,
    required this.badge,
    required this.level,
    required this.date,
    required this.status,
  });

  factory BackendRequest.fromJson(Map<String, dynamic> json) {
    return BackendRequest(
      id: _readInt(json, ['id', 'pedidoId', 'requestId']) ?? 0,
      badge: _readString(json, ['badge', 'badgeName', 'nome', 'title']) ?? '',
      level: _readString(json, ['level', 'nivel', 'badgeLevel']) ?? '',
      date: _readString(json, ['date', 'data', 'createdAt', 'submittedAt']),
      status: _readString(json, ['status', 'state', 'estado']) ?? '',
    );
  }

  final int id;
  final String badge;
  final String level;
  final String? date;
  final String status;
}

class ProfileSkillItem {
  const ProfileSkillItem({required this.title, required this.subtitle});

  factory ProfileSkillItem.fromJson(Map<String, dynamic> json) {
    return ProfileSkillItem(
      title: _readString(json, ['title', 'name', 'badge']) ?? '',
      subtitle:
          _readString(json, ['subtitle', 'level', 'nivel', 'subtitleKey']) ??
          '',
    );
  }

  final String title;
  final String subtitle;
}

class ServiceLineStat {
  const ServiceLineStat({
    required this.serviceLine,
    required this.badges,
    required this.points,
  });

  factory ServiceLineStat.fromJson(Map<String, dynamic> json) {
    return ServiceLineStat(
      serviceLine:
          _readString(json, ['serviceLine', 'service_line', 'name']) ?? '',
      badges: _readInt(json, ['badges', 'badgeCount', 'count']) ?? 0,
      points: _readInt(json, ['points', 'pontos']) ?? 0,
    );
  }

  final String serviceLine;
  final int badges;
  final int points;
}

class BackendRequirement {
  const BackendRequirement({required this.title, required this.description});

  factory BackendRequirement.fromJson(Map<String, dynamic> json) {
    return BackendRequirement(
      title: _readString(json, ['title', 'titulo', 'name']) ?? '',
      description:
          _readString(json, ['description', 'descricao', 'details']) ?? '',
    );
  }

  final String title;
  final String description;
}

class BackendLevel {
  const BackendLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.levelKey,
    required this.points,
    required this.badgeImage,
    required this.badgeDbId,
    required this.requestId,
    required this.requirements,
    required this.status,
    required this.isSpecial,
  });

  factory BackendLevel.fromJson(Map<String, dynamic> json) {
    final requirements = (json['requirements'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendRequirement.fromJson)
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);

    return BackendLevel(
      id: _readString(json, ['id', 'levelId']) ?? '',
      title: _readString(json, ['title', 'name', 'nivel']) ?? '',
      subtitle: _readString(json, ['subtitle', 'subtitulo']) ?? '',
      levelKey: _readString(json, ['levelKey', 'level_key']) ?? '',
      points: _readInt(json, ['points', 'pontos']) ?? 0,
      badgeImage: _readString(json, ['badgeImage', 'badge_image', 'image']),
      badgeDbId: _readInt(json, ['badgeDbId', 'badgeId', 'nbadge']),
      requestId: _readInt(json, ['requestId', 'pedidoId', 'npedido']),
      requirements: requirements,
      status: _readString(json, ['status', 'state', 'estado']) ?? 'visualizar',
      isSpecial: json['isSpecial'] == true,
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String levelKey;
  final int points;
  final String? badgeImage;
  final int? badgeDbId;
  final int? requestId;
  final List<BackendRequirement> requirements;
  final String status;
  final bool isSpecial;
}

class BackendArea {
  const BackendArea({
    required this.id,
    required this.name,
    required this.description,
    required this.levels,
  });

  factory BackendArea.fromJson(Map<String, dynamic> json) {
    final levels = (json['levels'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendLevel.fromJson)
        .toList(growable: false);

    return BackendArea(
      id: _readString(json, ['id', 'areaId']) ?? '',
      name: _readString(json, ['name', 'area']) ?? '',
      description: _readString(json, ['description', 'descricao']) ?? '',
      levels: levels,
    );
  }

  final String id;
  final String name;
  final String description;
  final List<BackendLevel> levels;
}

class BackendServiceLine {
  const BackendServiceLine({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.areas,
  });

  factory BackendServiceLine.fromJson(Map<String, dynamic> json) {
    final areas = (json['areas'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendArea.fromJson)
        .toList(growable: false);

    return BackendServiceLine(
      id: _readString(json, ['id', 'serviceLineId']) ?? '',
      name: _readString(json, ['name', 'serviceLine', 'sline']) ?? '',
      description: _readString(json, ['description', 'descricao']) ?? '',
      image: _readString(json, ['image', 'imagem']),
      areas: areas,
    );
  }

  final String id;
  final String name;
  final String description;
  final String? image;
  final List<BackendArea> areas;
}

class BackendLearningPath {
  const BackendLearningPath({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceLines,
  });

  factory BackendLearningPath.fromJson(Map<String, dynamic> json) {
    final serviceLines = (json['serviceLines'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendServiceLine.fromJson)
        .toList(growable: false);

    return BackendLearningPath(
      id: _readString(json, ['id', 'learningPathId']) ?? '',
      name: _readString(json, ['name', 'learningPath', 'lpath']) ?? '',
      description: _readString(json, ['description', 'lp_desc']) ?? '',
      serviceLines: serviceLines,
    );
  }

  final String id;
  final String name;
  final String description;
  final List<BackendServiceLine> serviceLines;
}

class BackendProfile {
  const BackendProfile({
    required this.name,
    required this.email,
    required this.location,
    required this.joined,
    required this.avatar,
    required this.points,
    required this.ranking,
    required this.badges,
    required this.skillsItems,
    required this.certificationsItems,
    required this.serviceLineStats,
  });

  factory BackendProfile.fromJson(Map<String, dynamic> json) {
    final skills = (json['skillsItems'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProfileSkillItem.fromJson)
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);

    final certifications =
        (json['certificationsItems'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ProfileSkillItem.fromJson)
            .where((item) => item.title.isNotEmpty)
            .toList(growable: false);

    final serviceLineStats =
        (json['serviceLineStats'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ServiceLineStat.fromJson)
            .where((item) => item.serviceLine.isNotEmpty)
            .toList(growable: false);

    return BackendProfile(
      name: _readString(json, ['name', 'nome']) ?? '',
      email: _readString(json, ['email']) ?? '',
      location: _readString(json, ['location', 'localizacao']) ?? '',
      joined: _readString(json, ['joined', 'membroDesde', 'memberSince']) ?? '',
      avatar: _readString(json, ['avatar', 'photoUrl', 'photo']) ?? '',
      points: _readInt(json, ['points', 'pontos']),
      ranking: _readInt(json, ['ranking', 'rank']),
      badges: _readInt(json, ['badges', 'badgeCount', 'totalBadges']),
      skillsItems: skills,
      certificationsItems: certifications,
      serviceLineStats: serviceLineStats,
    );
  }

  final String name;
  final String email;
  final String location;
  final String joined;
  final String avatar;
  final int? points;
  final int? ranking;
  final int? badges;
  final List<ProfileSkillItem> skillsItems;
  final List<ProfileSkillItem> certificationsItems;
  final List<ServiceLineStat> serviceLineStats;
}

class BackendDashboardStat {
  const BackendDashboardStat({
    required this.titleKey,
    required this.value,
    required this.noteKey,
    required this.iconKey,
    required this.tone,
  });

  factory BackendDashboardStat.fromJson(Map<String, dynamic> json) {
    return BackendDashboardStat(
      titleKey: _readString(json, ['titleKey']) ?? '',
      value: _readString(json, ['value']) ?? '0',
      noteKey: _readString(json, ['noteKey']) ?? '',
      iconKey: _readString(json, ['iconKey']) ?? '',
      tone: _readString(json, ['tone']) ?? 'gold',
    );
  }

  final String titleKey;
  final String value;
  final String noteKey;
  final String iconKey;
  final String tone;
}

class BackendSuggestionItem {
  const BackendSuggestionItem({
    required this.title,
    required this.subtitleKey,
    required this.accent,
    required this.badgeDbId,
  });

  factory BackendSuggestionItem.fromJson(Map<String, dynamic> json) {
    return BackendSuggestionItem(
      title: _readString(json, ['title', 'name', 'area']) ?? '',
      subtitleKey:
          _readString(json, ['subtitleKey', 'subtitle_key', 'levelKey']) ?? '',
      accent: _readString(json, ['accent', 'tone']) ?? 'success',
      badgeDbId: _readInt(json, ['badgeDbId', 'badgeId', 'nbadge']) ?? 0,
    );
  }

  final String title;
  final String subtitleKey;
  final String accent;
  final int badgeDbId;
}

class BackendConsultorDashboard {
  const BackendConsultorDashboard({
    required this.timelineValues,
    required this.stats,
    required this.suggestionItems,
  });

  factory BackendConsultorDashboard.fromJson(Map<String, dynamic> json) {
    final timelineValues =
        (json['timelineValues'] as List<dynamic>? ?? const [])
            .map((value) => int.tryParse(value.toString()) ?? 0)
            .toList(growable: false);

    final stats = (json['stats'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BackendDashboardStat.fromJson)
        .toList(growable: false);

    final suggestionItems =
        (json['suggestionItems'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BackendSuggestionItem.fromJson)
            .where((item) => item.title.isNotEmpty)
            .toList(growable: false);

    return BackendConsultorDashboard(
      timelineValues: timelineValues,
      stats: stats,
      suggestionItems: suggestionItems,
    );
  }

  final List<int> timelineValues;
  final List<BackendDashboardStat> stats;
  final List<BackendSuggestionItem> suggestionItems;
}

class BackendRankingConsultant {
  const BackendRankingConsultant({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.badges,
    required this.serviceLine,
    required this.avatar,
  });

  factory BackendRankingConsultant.fromJson(Map<String, dynamic> json) {
    return BackendRankingConsultant(
      id: _readInt(json, ['id', 'consultorId', 'userId']) ?? 0,
      name: _readString(json, ['name', 'nome']) ?? '',
      email: _readString(json, ['email']) ?? '',
      points: _readInt(json, ['points', 'pontos']) ?? 0,
      badges: _readInt(json, ['badges', 'badgeCount', 'totalBadges']) ?? 0,
      serviceLine:
          _readString(json, ['serviceLine', 'service_line', 'area']) ?? '',
      avatar: _readString(json, ['avatar', 'photo', 'photoUrl']),
    );
  }

  final int id;
  final String name;
  final String email;
  final int points;
  final int badges;
  final String serviceLine;
  final String? avatar;
}

class ConsultorApi {
  ConsultorApi._();

  static final ConsultorApi instance = ConsultorApi._();
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
    throw ConsultorApiException(
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
      throw ConsultorApiException(
        'Nao foi possivel ligar ao servidor ($uri). Verifique a rede e o endereco da API.',
      );
    } on HttpException {
      throw ConsultorApiException(
        'Falha de comunicacao com o servidor ($uri).',
      );
    } on TimeoutException {
      throw ConsultorApiException(
        'O servidor demorou demasiado tempo a responder ($uri).',
      );
    }
  }

  Future<List<BackendRequest>> fetchMyRequests({required int accountId}) async {
    final uri = await _uri('/consultor/meus-pedidos?accountId=$accountId');
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
        .map(BackendRequest.fromJson)
        .toList(growable: false);
  }

  Future<BackendProfile> fetchProfile({int? accountId}) async {
    final path = accountId == null
        ? '/consultor/profile'
        : '/consultor/profile?accountId=$accountId';
    final uri = await _uri(path);
    final response = await _getJson(uri);

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return BackendProfile.fromJson(data);
      }
      return BackendProfile.fromJson(decoded);
    }

    return const BackendProfile(
      name: '',
      email: '',
      location: '',
      joined: '',
      avatar: '',
      points: null,
      ranking: null,
      badges: null,
      skillsItems: [],
      certificationsItems: [],
      serviceLineStats: [],
    );
  }

  Future<BackendConsultorDashboard> fetchConsultorDashboard({
    int? accountId,
  }) async {
    final path = accountId == null
        ? '/dashboard/consultor'
        : '/dashboard/consultor?accountId=$accountId';
    final uri = await _uri(path);
    final response = await _getJson(uri);

    if (response.statusCode != 200) {
      _throwApiError(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return BackendConsultorDashboard.fromJson(data);
      }
      return BackendConsultorDashboard.fromJson(decoded);
    }

    return const BackendConsultorDashboard(
      timelineValues: [],
      stats: [],
      suggestionItems: [],
    );
  }

  Future<List<BackendRankingConsultant>> fetchRankingConsultores() async {
    final uri = await _uri('/consultor/ranking');
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
        .map(BackendRankingConsultant.fromJson)
        .toList(growable: false);
  }

  Future<List<BackendLearningPath>> fetchLearningPaths({
    required int accountId,
  }) async {
    final uri = await _uri('/consultor/learning-paths?accountId=$accountId');
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
        .map(BackendLearningPath.fromJson)
        .toList(growable: false);
  }
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
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

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }
    final text = value.toString().trim();
    final parsed = int.tryParse(text);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}
