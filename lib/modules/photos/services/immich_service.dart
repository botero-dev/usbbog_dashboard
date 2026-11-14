import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/album.dart';
import '../models/photo.dart';

/// Failure already translated into something the UI can show as-is.
class ImmichException implements Exception {
  const ImmichException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Immich REST API. Owns the HTTP calls, the `x-api-key` header and the
/// failure modes — nothing above this class sees a status code.
class ImmichService {
  ImmichService({
    required String baseUrl,
    required this.apiKey,
    http.Client? client,
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 15),
  }) : baseUrl = normalizeBaseUrl(baseUrl),
       _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  final String baseUrl;
  final String apiKey;
  final Duration timeout;

  final http.Client _client;
  final DateTime Function() _now;

  /// Headers required to fetch thumbnails through `Image.network`.
  Map<String, String> get imageHeaders => {'x-api-key': apiKey};

  /// Turns user input into a usable base URL.
  ///
  /// `192.168.1.10:2283` → `http://192.168.1.10:2283`, because a self-hosted
  /// Immich listens on plain HTTP by default. Public hosts and anything with an
  /// explicit `https://` keep TLS.
  static String normalizeBaseUrl(String url) {
    var value = url.trim();
    if (value.isEmpty) {
      throw ArgumentError.value(url, 'baseUrl', 'La URL de Immich está vacía');
    }

    if (!value.contains('://')) {
      value = '${_schemeFor(value)}://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) {
      throw ArgumentError.value(
        url,
        'baseUrl',
        'La URL de Immich no es válida',
      );
    }

    var normalized = uri.toString();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// HTTPS, unless the target looks like a self-hosted LAN server.
  static String _schemeFor(String input) {
    final authority = input.split('/').first;
    final host = authority.split(':').first.toLowerCase();
    final hasPort = authority.contains(':');

    final isLoopback =
        host == 'localhost' || host == '127.0.0.1' || host == '::1';
    if (isLoopback || host.endsWith('.local') || _isPrivateIpv4(host)) {
      return 'http';
    }
    // An explicit non-443 port almost always means a local instance.
    if (hasPort && !authority.endsWith(':443')) {
      return 'http';
    }
    return 'https';
  }

  static bool _isPrivateIpv4(String host) {
    final parts = host.split('.');
    if (parts.length != 4) {
      return false;
    }

    final octets = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) {
        return false;
      }
      octets.add(value);
    }

    return octets[0] == 10 ||
        (octets[0] == 192 && octets[1] == 168) ||
        (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) ||
        (octets[0] == 169 && octets[1] == 254);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$baseUrl/api$path');
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  String thumbnailUrl(String assetId) =>
      _uri('/assets/$assetId/thumbnail', {'size': 'thumbnail'}).toString();

  String previewUrl(String assetId) =>
      _uri('/assets/$assetId/thumbnail', {'size': 'preview'}).toString();

  Future<List<Album>> albums() async {
    final decoded = await _send('GET', '/albums');

    final items = decoded is List ? decoded : const [];
    return [
      for (final item in items)
        Album.fromJson((item as Map).cast<String, dynamic>()),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Assets of [albumId], or of the whole library when it is null/empty.
  Future<List<Photo>> photos({String? albumId, int limit = 20}) async {
    final decoded = await _send(
      'POST',
      '/search/metadata',
      body: {
        'size': limit,
        'page': 1,
        'type': 'IMAGE',
        if (albumId != null && albumId.isNotEmpty) 'albumIds': [albumId],
      },
    );

    final assets = ((decoded as Map?)?['assets'] as Map?)?['items'] as List?;
    if (assets == null) {
      return const [];
    }

    return [
      for (final asset in assets)
        if ((asset as Map)['type'] == 'IMAGE' || (asset)['type'] == null)
          Photo(
            id: asset['id'] as String? ?? '',
            thumbnailUrl: thumbnailUrl(asset['id'] as String? ?? ''),
            previewUrl: previewUrl(asset['id'] as String? ?? ''),
          ),
    ];
  }

  /// A photo that changes once a day and is stable within the day.
  Future<Photo> dailyPhoto({String? albumId}) async {
    final available = await photos(albumId: albumId);
    if (available.isEmpty) {
      throw const ImmichException('La galería está vacía');
    }

    return available[indexForDate(_now(), available.length)];
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    try {
      final uri = _uri(path, query);
      final headers = {
        'x-api-key': apiKey,
        'accept': 'application/json',
        if (body != null) 'content-type': 'application/json',
      };

      final response =
          await (method == 'POST'
                  ? _client.post(uri, headers: headers, body: jsonEncode(body))
                  : _client.get(uri, headers: headers))
              .timeout(timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ImmichException('La clave de API de Immich no es válida');
      }
      if (response.statusCode == 404) {
        throw const ImmichException('No se encontró en Immich');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ImmichException('Immich respondió ${response.statusCode}');
      }

      if (response.bodyBytes.isEmpty) {
        return null;
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ImmichException {
      rethrow;
    } on TimeoutException {
      throw const ImmichException('Immich tardó demasiado en responder');
    } on FormatException {
      throw const ImmichException('Respuesta inesperada de Immich');
    } catch (_) {
      throw const ImmichException('No se pudo conectar con Immich');
    }
  }

  void close() => _client.close();
}

/// Day of year, 0-based, wrapped into [count] items.
int indexForDate(DateTime date, int count) {
  if (count <= 0) {
    return 0;
  }
  final dayOfYear = date.difference(DateTime(date.year)).inDays;
  return dayOfYear % count;
}
