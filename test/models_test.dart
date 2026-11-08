import 'package:flutter_test/flutter_test.dart';
import 'package:rishta_ads/models/ad_filters.dart';
import 'package:rishta_ads/models/ad_model.dart';
import 'package:rishta_ads/models/api_response_model.dart';

void main() {
  test('Ad.fromJson maps API fields and tolerates missing ones', () {
    final ad = Ad.fromJson({
      'id': 'RCA-000123',
      'text': 'Test text',
      'city': 'Lahore',
      'gender': 'Female',
      'age': 25,
      'marital_status': 'Never Married',
      'days_left': 6,
    });
    expect(ad.id, 'RCA-000123');
    expect(ad.age, 25);
    expect(ad.maritalStatus, 'Never Married');
    expect(ad.daysLeft, 6);

    final sparse = Ad.fromJson({'id': 'RCA-000001'});
    expect(sparse.text, '');
    expect(sparse.daysLeft, isNull);
  });

  test('AdFilters builds the exact API query parameters', () {
    const filters = AdFilters(
      city: 'Lahore',
      gender: 'Male',
      maritalStatus: 'Divorced',
      minAge: 20,
      maxAge: 30,
    );
    expect(filters.activeCount, 5);
    expect(filters.toQuery(), {
      'city': 'Lahore',
      'gender': 'Male',
      'marital_status': 'Divorced',
      'min_age': '20',
      'max_age': '30',
    });
    expect(const AdFilters().toQuery(), isEmpty);
  });

  test('Pagination.hasMore follows total_pages', () {
    final page = AdsPage(
      ads: const [],
      pagination: Pagination.fromJson({
        'current_page': 1,
        'per_page': 20,
        'total_ads': 45,
        'total_pages': 3,
      }),
    );
    expect(page.hasMore, isTrue);
  });
}
