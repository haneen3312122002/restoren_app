/// App settings.
class AppConfig {
  const AppConfig._();

  // `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5023`
  
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
    return 'http://$host:5023';
  }

  /// Currency shown next to prices
  static const String currency = 'JD';

  /// How often the order tracking page refreshes:
  static const Duration trackingPollInterval = Duration(seconds: 4);

  /// How often the admin orders list refreshes:
  static const Duration adminOrdersPollInterval = Duration(seconds: 5);
}
