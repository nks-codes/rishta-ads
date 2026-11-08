import 'dart:convert';
import 'dart:io' show HttpDate;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the session cookies are kept. A small interface so tests can use an
/// in-memory fake instead of the Android Keystore.
abstract class CookieStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

/// Encrypted storage backed by the Android Keystore (flutter_secure_storage).
class SecureCookieStorage implements CookieStorage {
  SecureCookieStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'rishta_ads_session_cookies_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class _StoredCookie {
  const _StoredCookie(this.value, this.expiresAtMs);

  final String value;
  final int? expiresAtMs;

  bool get isExpired =>
      expiresAtMs != null &&
      expiresAtMs! <= DateTime.now().millisecondsSinceEpoch;
}

/// Keeps the PHP session cookie (and any other cookie the server sets) in
/// memory and in encrypted storage, so the same PHP session is reused across
/// requests and across app restarts.
///
/// Nothing here writes to logs.
class SessionCookieStore {
  SessionCookieStore(this._storage);

  final CookieStorage _storage;
  final Map<String, _StoredCookie> _cookies = {};
  Future<void>? _loadFuture;
  Future<void> _writeChain = Future<void>.value();

  // Splits a combined Set-Cookie header on commas that start a new cookie
  // ("name=") but not on commas inside an Expires date.
  static final RegExp _cookieSeparator = RegExp(r',(?=\s*[^;,=\s]+=)');

  /// Loads stored cookies once. Safe to call from many requests at the same
  /// time: they all wait for the same load.
  Future<void> ensureLoaded() => _loadFuture ??= _load();

  bool get hasCookies {
    _dropExpired();
    return _cookies.isNotEmpty;
  }

  /// Value for the Cookie request header, or null when there are no cookies.
  String? cookieHeader() {
    _dropExpired();
    if (_cookies.isEmpty) return null;
    return _cookies.entries.map((e) => '${e.key}=${e.value.value}').join('; ');
  }

  /// Applies the Set-Cookie header of a response: adds or refreshes cookies
  /// and removes the ones the server expired or deleted.
  Future<void> updateFromSetCookie(String? header) async {
    if (header == null || header.isEmpty) return;
    var changed = false;
    final now = DateTime.now();

    for (final part in header.split(_cookieSeparator)) {
      final segments = part.split(';');
      final pair = segments.first.trim();
      final eq = pair.indexOf('=');
      if (eq <= 0) continue;
      final name = pair.substring(0, eq).trim();
      final value = pair.substring(eq + 1).trim();

      int? maxAge;
      DateTime? expires;
      for (final attribute in segments.skip(1)) {
        final idx = attribute.indexOf('=');
        if (idx <= 0) continue;
        final key = attribute.substring(0, idx).trim().toLowerCase();
        final attrValue = attribute.substring(idx + 1).trim();
        if (key == 'max-age') {
          maxAge = int.tryParse(attrValue);
        } else if (key == 'expires') {
          try {
            expires = HttpDate.parse(attrValue);
          } catch (_) {
            expires = null;
          }
        }
      }

      var remove = value.isEmpty || value == 'deleted';
      int? expiresAtMs;
      if (maxAge != null) {
        if (maxAge <= 0) {
          remove = true;
        } else {
          expiresAtMs = now.millisecondsSinceEpoch + maxAge * 1000;
        }
      } else if (expires != null) {
        if (!expires.isAfter(now)) {
          remove = true;
        } else {
          expiresAtMs = expires.millisecondsSinceEpoch;
        }
      }

      if (remove) {
        if (_cookies.remove(name) != null) changed = true;
      } else {
        final previous = _cookies[name];
        if (previous == null ||
            previous.value != value ||
            previous.expiresAtMs != expiresAtMs) {
          _cookies[name] = _StoredCookie(value, expiresAtMs);
          changed = true;
        }
      }
    }

    if (changed) await _persist();
  }

  /// Forgets the session (memory and storage).
  Future<void> clear() async {
    _cookies.clear();
    await _persist();
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.read();
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        decoded.forEach((name, entry) {
          if (name is String && entry is Map) {
            final value = entry['v'];
            final expires = entry['e'];
            if (value is String && value.isNotEmpty) {
              _cookies[name] = _StoredCookie(
                value,
                expires is int ? expires : null,
              );
            }
          }
        });
      }
      _dropExpired();
    } catch (_) {
      // Unreadable or corrupt storage: start with a clean session.
      _cookies.clear();
      await _storage.delete().catchError((Object _) {});
    }
  }

  void _dropExpired() {
    _cookies.removeWhere((_, cookie) => cookie.isExpired);
  }

  /// Writes are queued so they can never overlap or finish out of order.
  /// Each queued write saves the newest state at the moment it runs.
  Future<void> _persist() {
    _writeChain = _writeChain.then((_) async {
      try {
        if (_cookies.isEmpty) {
          await _storage.delete();
        } else {
          await _storage.write(
            jsonEncode({
              for (final entry in _cookies.entries)
                entry.key: {
                  'v': entry.value.value,
                  if (entry.value.expiresAtMs != null)
                    'e': entry.value.expiresAtMs,
                },
            }),
          );
        }
      } catch (_) {
        // A storage failure must never break API calls.
      }
    });
    return _writeChain;
  }
}
