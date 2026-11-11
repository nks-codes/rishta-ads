import 'dart:convert';

import 'constants.dart';

/// Client-side checks that mirror the validation rules in submit.php.
/// The server still validates everything again.
///
/// Note: the server measures city, name, email and phone length in BYTES
/// (PHP strlen) and the advertisement text in characters (mb_strlen), so the
/// same is done here.
class Validators {
  Validators._();

  static final RegExp _phoneChars = RegExp(r'^[0-9+().\-\s]+$');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static int _bytes(String value) => utf8.encode(value).length;

  static String? city(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your city.';
    if (_bytes(text) > 100) return 'City name is too long.';
    return null;
  }

  static String? gender(String? value) {
    if (value == null || !AppConstants.genders.contains(value)) {
      return 'Please select gender.';
    }
    return null;
  }

  static String? maritalStatus(String? value) {
    if (value == null || !AppConstants.maritalStatuses.contains(value)) {
      return 'Please select marital status.';
    }
    return null;
  }

  static String? age(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your age.';
    final age = int.tryParse(text);
    if (age == null || age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Age must be ${AppConstants.minAge}–${AppConstants.maxAge}.';
    }
    return null;
  }

  static String? adText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please write your advertisement.';
    if (text.runes.length > AppConstants.adTextMaxLength) {
      return 'Advertisement must be ${AppConstants.adTextMaxLength} characters or fewer.';
    }
    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your phone number.';
    if (_bytes(text) > 30) return 'Phone number is too long.';
    if (!_phoneChars.hasMatch(text) || !_hasDigit.hasMatch(text)) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  /// Optional field.
  static String? contactName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (_bytes(text) > 100) return 'Name is too long.';
    return null;
  }

  /// Optional field.
  static String? contactEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (_bytes(text) > 190 || !_email.hasMatch(text)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
}
