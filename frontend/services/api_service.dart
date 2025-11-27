import 'package:dio/dio.dart';
import 'dart:io';
import '../config/constants.dart';
import 'storage_service.dart';

class ApiService {
  late Dio _dio;
  final StorageService _storage = StorageService();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para agregar token automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print('❌ Error API: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // ==================== AUTH ====================

  Future<Map<String, dynamic>> login(String correo, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'correo': correo,
          'contraseña': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String nombres,
    required String apellidos,
    required String correo,
    required String password,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: {
          'nombres': nombres,
          'apellidos': apellidos,
          'correo': correo,
          'contraseña': password,
          'telefono': telefono,
          'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
          'sexo': sexo,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== USUARIOS ====================

  Future<Map<String, dynamic>> getUsuario(String idUsuario) async {
    try {
      final response = await _dio.get('${AppConstants.userEndpoint}/$idUsuario');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUsuario(
    String idUsuario,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '${AppConstants.userEndpoint}/$idUsuario',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== IMÁGENES ====================

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'imagen': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        AppConstants.uploadImageEndpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PREDICCIONES ====================

  Future<Map<String, dynamic>> predictImage(String idImagen) async {
    try {
      final response = await _dio.post(
        AppConstants.predictEndpoint,
        data: {'id_imagen': idImagen},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPrediccion(String idPrediccion) async {
    try {
      final response = await _dio.get(
        '${AppConstants.predictEndpoint}/$idPrediccion',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HISTORIAL ====================

  Future<Map<String, dynamic>> getHistorial(String idUsuario) async {
    try {
      final response = await _dio.get(
        '${AppConstants.historialEndpoint}/$idUsuario',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteHistorial(String idHistorial) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.historialEndpoint}/$idHistorial',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== MANEJO DE ERRORES ====================

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Error de conexión: Tiempo de espera agotado';
      
      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          return error.response!.data['message'] ?? 'Error del servidor';
        }
        return 'Error del servidor: ${error.response?.statusCode}';
      
      case DioExceptionType.cancel:
        return 'Solicitud cancelada';
      
      default:
        return 'Error de conexión. Verifica tu internet';
    }
  }
}