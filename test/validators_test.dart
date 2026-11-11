import 'package:flutter_test/flutter_test.dart';
import 'package:rishta_ads/utils/validators.dart';

void main() {
  test('city is required and limited to 100 bytes', () {
    expect(Validators.city(''), isNotNull);
    expect(Validators.city('  '), isNotNull);
    expect(Validators.city('Lahore'), isNull);
    // 51 Urdu letters = 102 bytes, which the server (strlen) would reject.
    expect(Validators.city('ا' * 51), isNotNull);
    expect(Validators.city('ا' * 50), isNull);
  });

  test('age must be 18 to 100', () {
    expect(Validators.age(''), isNotNull);
    expect(Validators.age('abc'), isNotNull);
    expect(Validators.age('17'), isNotNull);
    expect(Validators.age('18'), isNull);
    expect(Validators.age('100'), isNull);
    expect(Validators.age('101'), isNotNull);
  });

  test('ad text must be 1 to 300 characters', () {
    expect(Validators.adText(''), isNotNull);
    expect(Validators.adText('a' * 300), isNull);
    expect(Validators.adText('a' * 301), isNotNull);
    expect(Validators.adText('😀' * 300), isNull);
    expect(Validators.adText('😀' * 301), isNotNull);
  });

  test('phone follows the server rules', () {
    expect(Validators.phone(''), isNotNull);
    expect(Validators.phone('0300-1234567'), isNull);
    expect(Validators.phone('+92 300 1234567'), isNull);
    expect(Validators.phone('abc'), isNotNull);
    expect(Validators.phone('+++'), isNotNull);
    expect(Validators.phone('1' * 31), isNotNull);
  });

  test('optional name and email', () {
    expect(Validators.contactName(''), isNull);
    expect(Validators.contactName('a' * 101), isNotNull);
    expect(Validators.contactEmail(''), isNull);
    expect(Validators.contactEmail('a@b.co'), isNull);
    expect(Validators.contactEmail('not-an-email'), isNotNull);
  });

  test('gender and marital status must be allowed values', () {
    expect(Validators.gender(null), isNotNull);
    expect(Validators.gender('Male'), isNull);
    expect(Validators.maritalStatus('Divorced'), isNull);
    expect(Validators.maritalStatus('Other'), isNotNull);
  });
}
