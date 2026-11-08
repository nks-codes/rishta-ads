import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/ad_filters.dart';
import '../models/ad_model.dart';
import '../models/api_response_model.dart';
import '../utils/constants.dart';
import 'cookie_store.dart';

/// Error with a user-friendly message, thrown by [ApiService].
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

/// Talks to the Biah.pk endpoints:
///   GET  ads.php
///   GET  cities.php
///   POST submit.php
///   POST reveal-phone.php
///
/// The PHP session cookie is stored encrypted on the device and sent with
/// every request, so the server-side cooldown and rate limits (which use PHP
/// sessions) keep working across requests and app restarts.
class ApiService {
  ApiService({http.Client? client, SessionCookieStore? cookieStore})
      : _client = client ?? http.Client(),
        _cookies = cookieStore ?? SessionCookieStore(SecureCookieStorage());

  final http.Client _client;
  final SessionCookieStore _cookies;

  /// Set while the very first request (no cookie yet) is in flight, so other
  /// requests wait for its cookie instead of each creating a new PHP session.
  Completer<void>? _sessionBootstrap;

  Future<AdsPage> fetchAds({
    required int page,
    int limit = AppConstants.pageSize,
    AdFilters filters = const AdFilters(),
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      ...filters.toQuery(),
    };
    final json = await _request('GET', 'ads.php', query: query);
    final data = json['data'];
    final ads = data is List
        ? data.whereType<Map<String, dynamic>>().map(Ad.fromJson).toList()
        : <Ad>[];
    return AdsPage(
      ads: ads,
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  /// Distinct cities of approved, unexpired ads (GET cities.php).
  Future<List<String>> fetchCities() async {
    try {
      final json = await _request('GET', 'cities.php');
      final data = json['data'];
      final cities = <String>{};
      if (data is List) {
        for (final item in data) {
          final city = item?.toString().trim() ?? '';
          if (city.isNotEmpty) cities.add(city);
        }
      }
      return cities.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const ApiException(
          'The city list is not available on the server yet.',
          statusCode: 404,
        );
      }
      rethrow;
    }
  }

  /// Asks the backend for the phone number. The backend decides whether it
  /// may be revealed. Throws [ApiException] (404 = unavailable).
  Future<String> revealPhone(String adId) async {
    final json = await _request(
      'POST',
      'reveal-phone.php',
      body: {'ad_id': adId},
    );
    final data = json['data'];
    final phone =
        (data is Map ? data['phone_number'] : null)?.toString().trim() ?? '';
    if (phone.isEmpty) {
      throw const ApiException(
        'Phone number is unavailable for this advertisement.',
        statusCode: 404,
      );
    }
    return phone;
  }

  Future<SubmitResult> submitAd({
    required String adText,
    required String city,
    required String gender,
    required int age,
    required String maritalStatus,
    required String phoneNumber,
    required bool phoneConsent,
    String? contactName,
    String? contactEmail,
  }) async {
    final body = <String, dynamic>{
      'ad_text': adText,
      'city': city,
      'gender': gender,
      'age': age,
      'marital_status': maritalStatus,
      'phone_number': phoneNumber,
      'phone_consent': phoneConsent,
    };
    if (contactName != null && contactName.isNotEmpty) {
      body['contact_name'] = contactName;
    }
    if (contactEmail != null && contactEmail.isNotEmpty) {
      body['contact_email'] = contactEmail;
    }
    final json = await _request('POST', 'submit.php', body: body);
    return SubmitResult.fromJson(json);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    // Stored cookies must be loaded before the first request is sent.
    await _cookies.ensureLoaded();

    // Without a cookie, let one request go first and the others wait for it.
    Completer<void>? leader;
    if (!_cookies.hasCookies) {
      final pending = _sessionBootstrap;
      if (pending != null) {
        await pending.future;
      } else {
        leader = Completer<void>();
        _sessionBootstrap = leader;
      }
    }

    try {
      return await _send(method, endpoint, query: query, body: body);
    } finally {
      if (leader != null) {
        _sessionBootstrap = null;
        leader.complete();
      }
    }
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String endpoint, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    var uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }

    final headers = <String, String>{'Accept': 'application/json'};
    final cookieHeader = _cookies.cookieHeader();
    if (cookieHeader != null) headers['Cookie'] = cookieHeader;

    http.Response response;
    try {
      if (method == 'GET') {
        response = await _client
            .get(uri, headers: headers)
            .timeout(AppConstants.requestTimeout);
      } else {
        headers['Content-Type'] = 'application/json';
        response = await _client
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(AppConstants.requestTimeout);
      }
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please check your internet connection and try again.',
      );
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not reach the server. Please check your connection and try again.',
      );
    }

    // Save a new or refreshed session cookie (also from error responses).
    await _cookies.updateFromSetCookie(response.headers['set-cookie']);

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) json = decoded;
    } on FormatException {
      json = null;
    }

    final httpOk = response.statusCode >= 200 && response.statusCode < 300;
    if (!httpOk || json == null || json['success'] != true) {
      final message = json?['message'];
      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Something went wrong (code ${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
      );
    }
    return json;
  }
}
