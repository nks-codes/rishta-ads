import '../services/api_service.dart';
import '../services/city_service.dart';

/// App-wide service instances. One ApiService is shared so that PHP session
/// cookies are kept for the whole app session (needed for server-side limits).
final ApiService apiService = ApiService();
final CityService cityService = CityService(apiService);
