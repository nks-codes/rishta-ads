/// Filters supported by ads.php:
/// city, gender, marital_status, min_age, max_age.
class AdFilters {
  const AdFilters({
    this.city,
    this.gender,
    this.maritalStatus,
    this.minAge,
    this.maxAge,
  });

  final String? city;
  final String? gender;
  final String? maritalStatus;
  final int? minAge;
  final int? maxAge;

  int get activeCount =>
      [city, gender, maritalStatus, minAge, maxAge].where((v) => v != null).length;

  bool get isActive => activeCount > 0;

  /// Query parameters using the exact names expected by the API.
  Map<String, String> toQuery() {
    final query = <String, String>{};
    if (city != null && city!.isNotEmpty) query['city'] = city!;
    if (gender != null) query['gender'] = gender!;
    if (maritalStatus != null) query['marital_status'] = maritalStatus!;
    if (minAge != null) query['min_age'] = minAge.toString();
    if (maxAge != null) query['max_age'] = maxAge.toString();
    return query;
  }
}
