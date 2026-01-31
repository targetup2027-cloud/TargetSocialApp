enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool useRemoteData;
  final bool enableAnalytics;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.useRemoteData = false,
    this.enableAnalytics = false,
  });

  static const AppConfig dev = AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: 'http://192.168.100.133:5224',
    useRemoteData: true,
  );

  static const AppConfig prod = AppConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.u-axis.com',
    useRemoteData: true,
  );
}

final currentConfig = AppConfig.dev;
