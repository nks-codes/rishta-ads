import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rishta_ads/services/api_service.dart';
import 'package:rishta_ads/services/cookie_store.dart';

import 'fake_cookie_storage.dart';

http.Response _adsResponse({String? cookie}) {
  return http.Response(
    jsonEncode({
      'success': true,
      'pagination': {
        'current_page': 1,
        'per_page': 20,
        'total_ads': 0,
        'total_pages': 0,
      },
      'data': [],
    }),
    200,
    headers: {
      'content-type': 'application/json',
      if (cookie != null) 'set-cookie': cookie,
    },
  );
}

void main() {
  test('session cookie is sent on GET and POST and survives a restart',
      () async {
    final storage = FakeCookieStorage();
    final seen = <http.Request>[];
    final client = MockClient((request) async {
      seen.add(request);
      if (request.url.path.endsWith('ads.php')) {
        return _adsResponse(cookie: 'PHPSESSID=abc123; path=/; HttpOnly');
      }
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'ad_id': 'RCA-000001', 'phone_number': '0300-0000000'},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = ApiService(
      client: client,
      cookieStore: SessionCookieStore(storage),
    );
    await api.fetchAds(page: 1);
    expect(seen[0].headers['Cookie'], isNull);

    await api.revealPhone('RCA-000001');
    expect(seen[1].method, 'POST');
    expect(seen[1].headers['Cookie'], 'PHPSESSID=abc123');

    // Simulate closing and reopening the app: new objects, same storage.
    final restarted = ApiService(
      client: client,
      cookieStore: SessionCookieStore(storage),
    );
    await restarted.fetchAds(page: 1);
    expect(seen[2].headers['Cookie'], 'PHPSESSID=abc123');
  });

  test('simultaneous first requests share a single session', () async {
    final cookiesSeen = <String?>[];
    final client = MockClient((request) async {
      cookiesSeen.add(request.headers['Cookie']);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return _adsResponse(cookie: 'PHPSESSID=abc123; path=/');
    });
    final api = ApiService(
      client: client,
      cookieStore: SessionCookieStore(FakeCookieStorage()),
    );

    await Future.wait([
      api.fetchAds(page: 1),
      api.fetchAds(page: 1),
      api.fetchAds(page: 1),
    ]);

    expect(cookiesSeen, hasLength(3));
    expect(cookiesSeen.first, isNull);
    expect(cookiesSeen.skip(1), everyElement('PHPSESSID=abc123'));
  });

  test('fetchCities trims, removes duplicates and sorts', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'data': ['lahore', 'Karachi', ' Karachi ', ''],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = ApiService(
      client: client,
      cookieStore: SessionCookieStore(FakeCookieStorage()),
    );
    expect(await api.fetchCities(), ['Karachi', 'lahore']);
  });

  test('fetchCities reports a missing endpoint clearly', () async {
    final client = MockClient((request) async {
      return http.Response('Not found', 404);
    });
    final api = ApiService(
      client: client,
      cookieStore: SessionCookieStore(FakeCookieStorage()),
    );
    expect(api.fetchCities(), throwsA(isA<ApiException>()));
  });
}
