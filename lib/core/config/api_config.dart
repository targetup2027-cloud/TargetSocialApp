class ApiConfig {
  static const String baseUrl = 'http://192.168.100.133:5224/api';
  static const String wsUrl = 'ws://192.168.100.133:5224/ws';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
