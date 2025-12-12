class ApiConstants {
  ApiConstants._();
  
  // Base URL - Update this with your server URL
  // For Android Emulator, use 10.0.2.2 to access host machine's localhost
  // For physical device, use your machine's IP address
  static const String baseUrl = 'http://172.16.41.26:8000';
  // static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'https://volt-wzwo.onrender.com';
  // Auth endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login/json';
  static const String getCurrentUserEndpoint = '/auth/me';
  
  // Transaction endpoints
  static const String transactionsEndpoint = '/transactions';
  static const String transactionsDateRangeEndpoint = '/transactions/date-range';
  
  // OCR endpoints
  static const String ocrImagesToTextEndpoint = '/ocr/images-to-text';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
}

  