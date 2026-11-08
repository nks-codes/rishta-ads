import 'api_service.dart';

/// Provides the city list for the Browse filter.
///
/// Cities come from the server (cities.php): every distinct city of approved,
/// unexpired advertisements. Nothing is hard-coded in the app. The list is
/// cached for a few minutes and refreshed on pull-to-refresh, so a city
/// appears automatically once an ad using it is approved.
class CityService {
  CityService(this._api);

  final ApiService _api;

  List<String>? _cache;
  DateTime? _fetchedAt;
  Future<List<String>>? _inFlight;

  static const Duration _ttl = Duration(minutes: 5);

  Future<List<String>> loadCities({bool forceRefresh = false}) {
    final cache = _cache;
    final fetchedAt = _fetchedAt;
    final fresh = cache != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _ttl;
    if (!forceRefresh && fresh) return Future.value(cache);
    return _inFlight ??= _refresh().whenComplete(() => _inFlight = null);
  }

  Future<List<String>> _refresh() async {
    try {
      final cities = await _api.fetchCities();
      _cache = cities;
      _fetchedAt = DateTime.now();
      return cities;
    } catch (_) {
      // Keep showing the last known list if a refresh fails.
      final stale = _cache;
      if (stale != null) return stale;
      rethrow;
    }
  }
}
