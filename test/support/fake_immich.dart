import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _albumId = 'album-holiday';
const _assetId = 'asset-1';

List<Map<String, dynamic>> get _albumsJson => [
  {
    'id': _albumId,
    'albumName': 'Holiday',
    'assetCount': 12,
    'albumThumbnailAssetId': _assetId,
  },
  {'id': 'album-2', 'albumName': 'Birthday', 'assetCount': 3},
  {'id': 'album-empty', 'albumName': 'Empty Album', 'assetCount': 0},
];

Map<String, dynamic> get _searchJson => {
  'albums': {'total': 0, 'count': 0, 'items': []},
  'assets': {
    'total': 1,
    'count': 1,
    'items': [
      {'id': _assetId, 'type': 'IMAGE', 'width': 4080, 'height': 3072},
    ],
  },
};

/// Serves the three Immich endpoints `ImmichService` uses, with no network.
http.Client fakeImmich({int status = 200, bool requireKey = true}) {
  return MockClient((request) async {
    if (requireKey && request.headers['x-api-key'] == null) {
      return http.Response('{"message":"Unauthorized"}', 401);
    }
    if (status != 200) {
      return http.Response('{"message":"boom"}', status);
    }

    final path = request.url.path;
    if (path.endsWith('/api/albums')) {
      return _json(jsonEncode(_albumsJson));
    }
    if (path.endsWith('/search/metadata')) {
      return _json(jsonEncode(_searchJson));
    }
    return http.Response('{"message":"Not found"}', 404);
  });
}

http.Response _json(String body) =>
    http.Response(body, 200, headers: {'content-type': 'application/json'});
