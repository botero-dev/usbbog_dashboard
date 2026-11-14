import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:usbbog_dashboard/modules/photos/services/immich_service.dart';

import '../../support/fake_immich.dart';

ImmichService buildService(
  http.Client client, {
  DateTime? now,
  String baseUrl = 'https://demo.immich.app',
}) {
  return ImmichService(
    baseUrl: baseUrl,
    apiKey: 'test-key',
    client: client,
    now: () => now ?? DateTime(2026, 11, 16),
  );
}

void main() {
  group('albums()', () {
    test('parses and sorts by name', () async {
      final albums = await buildService(fakeImmich()).albums();

      expect(albums.map((a) => a.name), ['Birthday', 'Empty Album', 'Holiday']);
      expect(albums.last.assetCount, 12);
      expect(albums.last.thumbnailAssetId, 'asset-1');
    });

    test("does not hide empty albums; that is the picker's decision", () async {
      final albums = await buildService(fakeImmich()).albums();

      expect(albums.where((album) => album.isEmpty).map((a) => a.name), [
        'Empty Album',
      ]);
    });

    test('reaches the server with the api key header', () async {
      // The fake answers 401 when requireKey is on and the header is missing.
      final albums = await buildService(fakeImmich(requireKey: true)).albums();
      expect(albums, isNotEmpty);
    });

    test('maps 401 to a readable message', () async {
      expect(
        () => buildService(fakeImmich(status: 401)).albums(),
        throwsA(
          isA<ImmichException>().having(
            (e) => e.message,
            'message',
            contains('clave de API'),
          ),
        ),
      );
    });

    test('maps a server error to a readable message', () async {
      expect(
        () => buildService(fakeImmich(status: 500)).albums(),
        throwsA(
          isA<ImmichException>().having(
            (e) => e.message,
            'message',
            contains('500'),
          ),
        ),
      );
    });
  });

  group('photos()', () {
    test('builds thumbnail and preview urls', () async {
      final photos = await buildService(fakeImmich()).photos();

      expect(photos, hasLength(1));
      expect(
        photos.single.thumbnailUrl,
        'https://demo.immich.app/api/assets/asset-1/thumbnail?size=thumbnail',
      );
      expect(
        photos.single.previewUrl,
        'https://demo.immich.app/api/assets/asset-1/thumbnail?size=preview',
      );
    });

    test('dailyPhoto is stable within a day', () async {
      final service = buildService(fakeImmich());

      final first = await service.dailyPhoto();
      final second = await service.dailyPhoto();

      expect(first.id, second.id);
    });

    test('dailyPhoto surfaces failure as ImmichException', () async {
      expect(
        () => buildService(fakeImmich(status: 500)).dailyPhoto(),
        throwsA(isA<ImmichException>()),
      );
    });
  });

  group('base url', () {
    test('assumes https for a bare public host', () {
      expect(
        ImmichService.normalizeBaseUrl('demo.immich.app/'),
        'https://demo.immich.app',
      );
    });

    test('keeps an explicit scheme', () {
      expect(
        ImmichService.normalizeBaseUrl('http://192.168.1.10:2283'),
        'http://192.168.1.10:2283',
      );
      expect(
        ImmichService.normalizeBaseUrl('https://immich.example.com'),
        'https://immich.example.com',
      );
    });

    test('assumes http for the default Immich port', () {
      expect(
        ImmichService.normalizeBaseUrl('192.168.1.10:2283'),
        'http://192.168.1.10:2283',
      );
      expect(
        ImmichService.normalizeBaseUrl('localhost:2283'),
        'http://localhost:2283',
      );
      expect(
        ImmichService.normalizeBaseUrl('immich.lan:2283/'),
        'http://immich.lan:2283',
      );
    });

    test('assumes http for loopback, .local and private ranges', () {
      for (final host in const [
        'localhost',
        '127.0.0.1',
        'immich.local',
        '10.0.0.5',
        '172.16.4.2',
        '172.31.255.1',
        '192.168.0.20',
      ]) {
        expect(
          ImmichService.normalizeBaseUrl(host),
          'http://$host',
          reason: host,
        );
      }
    });

    test('keeps https for public hosts on 443', () {
      expect(
        ImmichService.normalizeBaseUrl('example.com:443'),
        'https://example.com',
      );
    });

    test('keeps a reverse-proxy path prefix', () {
      expect(
        ImmichService.normalizeBaseUrl('https://example.com/immich/'),
        'https://example.com/immich',
      );
    });

    test('builds thumbnail urls against the LAN base', () async {
      final photos = await buildService(
        fakeImmich(),
        baseUrl: '192.168.1.10:2283',
      ).photos();

      expect(
        photos.single.thumbnailUrl,
        'http://192.168.1.10:2283/api/assets/asset-1/thumbnail?size=thumbnail',
      );
    });

    test('rejects an empty base url', () {
      expect(
        () => ImmichService(baseUrl: '  ', apiKey: 'k'),
        throwsArgumentError,
      );
    });
  });

  group('indexForDate', () {
    test('wraps the day of year into the item count', () {
      expect(indexForDate(DateTime(2026, 1, 1), 5), 0);
      expect(indexForDate(DateTime(2026, 1, 2), 5), 1);
      expect(indexForDate(DateTime(2026, 1, 6), 5), 0);
      expect(indexForDate(DateTime(2026, 11, 16), 5), inInclusiveRange(0, 4));
    });

    test('handles an empty list', () {
      expect(indexForDate(DateTime(2026, 11, 16), 0), 0);
    });
  });
}
