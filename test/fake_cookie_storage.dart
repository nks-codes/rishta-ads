import 'package:rishta_ads/services/cookie_store.dart';

/// In-memory stand-in for the encrypted storage, used only in tests.
class FakeCookieStorage implements CookieStorage {
  String? value;

  @override
  Future<String?> read() async {
    return value;
  }

  @override
  Future<void> write(String newValue) async {
    value = newValue;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}
