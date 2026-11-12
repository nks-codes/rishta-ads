class AppConstants {
  AppConstants._();

  static const String appName = 'Rishta Ads';
  static const String poweredBy = 'Powered by Biah.pk';

  static const String apiBaseUrl = 'https://biah.pk/ads/api/v1/';
  static const String websiteUrl = 'https://biah.pk';
  static const String contactUrl = 'https://biah.pk/contact';

  /// Link added when sharing the app. Replace with the official app-store link
  /// when one exists; until then the Biah.pk website is shared.
  static const String appShareUrl = websiteUrl;

  static const Duration requestTimeout = Duration(seconds: 20);
  static const int pageSize = 20;

  // Values below mirror the validation rules in the existing PHP API.
  static const int adTextMaxLength = 300;
  static const int minAge = 18;
  static const int maxAge = 100;
  static const List<String> genders = ['Male', 'Female'];
  static const List<String> maritalStatuses = [
    'Never Married',
    'Divorced',
    'Widowed',
  ];
}
