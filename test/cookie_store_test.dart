import 'package:flutter_test/flutter_test.dart';
import 'package:rishta_ads/services/cookie_store.dart';

import 'fake_cookie_storage.dart';

void main() {
  test('parses several cookies without splitting Expires dates', () async {
    final store = SessionCookieStore(FakeCookieStorage());
    await store.ensureLoaded();
    await store.updateFromSetCookie(
      'PHPSESSID=abc123; path=/; HttpOnly, '
      'theme=dark; Expires=Wed, 21 Oct 2037 07:28:00 GMT; Path=/',
    );
    expect(store.cookieHeader(), 'PHPSESSID=abc123; theme=dark');
  });

  test('cookie survives an app restart', () async {
    final storage = FakeCookieStorage();
    final first = SessionCookieStore(storage);
    await first.ensureLoaded();
    await first.updateFromSetCookie('PHPSESSID=abc123; path=/');

    final second = SessionCookieStore(storage);
    await second.ensureLoaded();
    expect(second.cookieHeader(), 'PHPSESSID=abc123');
  });

  test('a refreshed session id replaces the old one', () async {
    final storage = FakeCookieStorage();
    final store = SessionCookieStore(storage);
    await store.ensureLoaded();
    await store.updateFromSetCookie('PHPSESSID=old; path=/');
    await store.updateFromSetCookie('PHPSESSID=new; path=/');
    expect(store.cookieHeader(), 'PHPSESSID=new');

    final restarted = SessionCookieStore(storage);
    await restarted.ensureLoaded();
    expect(restarted.cookieHeader(), 'PHPSESSID=new');
  });

  test('a cookie deleted by the server is removed from storage', () async {
    final storage = FakeCookieStorage();
    final store = SessionCookieStore(storage);
    await store.ensureLoaded();
    await store.updateFromSetCookie('PHPSESSID=abc123; path=/');
    await store.updateFromSetCookie(
      'PHPSESSID=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; Max-Age=0',
    );
    expect(store.hasCookies, isFalse);
    expect(storage.value, isNull);
  });

  test('corrupt stored data starts a clean session', () async {
    final storage = FakeCookieStorage()..value = 'not json';
    final store = SessionCookieStore(storage);
    await store.ensureLoaded();
    expect(store.hasCookies, isFalse);
    expect(storage.value, isNull);
  });

  test('expired stored cookies are dropped on load', () async {
    final storage = FakeCookieStorage()
      ..value = '{"PHPSESSID":{"v":"old","e":1}}';
    final store = SessionCookieStore(storage);
    await store.ensureLoaded();
    expect(store.hasCookies, isFalse);
  });
}
