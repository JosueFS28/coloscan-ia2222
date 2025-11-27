class AppConstants {
  // Backend URL
  static const String baseUrl = 'http://localhost:8000';
  
  // Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String uploadImageEndpoint = '/api/imagenes/upload';
  static const String predictEndpoint = '/api/predicciones/predict';
  static const String historialEndpoint = '/api/historial';
  static const String userEndpoint = '/api/usuarios';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  
  // Validaciones
  static const int maxImageSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Estados de imagen
  static const String estadoProcesando = 'procesando';
  static const String estadoCompletado = 'completado';
  static const String estadoError = 'error';
}