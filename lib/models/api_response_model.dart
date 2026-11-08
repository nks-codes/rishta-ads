import 'ad_model.dart';

class Pagination {
  const Pagination({
    required this.currentPage,
    required this.perPage,
    required this.totalAds,
    required this.totalPages,
  });

  final int currentPage;
  final int perPage;
  final int totalAds;
  final int totalPages;

  factory Pagination.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return Pagination(
      currentPage: _toInt(map['current_page'], 1),
      perPage: _toInt(map['per_page'], 0),
      totalAds: _toInt(map['total_ads'], 0),
      totalPages: _toInt(map['total_pages'], 0),
    );
  }
}

/// One page of advertisements from GET ads.php.
class AdsPage {
  const AdsPage({required this.ads, required this.pagination});

  final List<Ad> ads;
  final Pagination pagination;

  bool get hasMore => pagination.currentPage < pagination.totalPages;
}

/// Successful response from POST submit.php.
class SubmitResult {
  const SubmitResult({required this.message, this.adId});

  final String message;
  final String? adId;

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final message = json['message'];
    return SubmitResult(
      message: message is String && message.isNotEmpty
          ? message
          : 'Your advertisement has been submitted for review.',
      adId: data is Map ? data['id']?.toString() : null,
    );
  }
}

int _toInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
