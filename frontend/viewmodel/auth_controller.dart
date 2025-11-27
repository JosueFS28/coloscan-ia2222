import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  // ==================== INICIALIZAR ====================
  
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar si hay token guardado
      bool hasToken = await _storage.hasToken();
      if (hasToken) {
        // Cargar usuario guardado
        _currentUser = await _storage.getUser();
        _isLoggedIn = _currentUser != null;
      }
    } catch (e) {
      print('Error al inicializar: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== LOGIN ====================

  Future<bool> login(String correo, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Llamar API
      final response = await _apiService.login(correo, password);

      // Guardar token
      await _storage.saveToken(response['token']);

      // Crear usuario
      _currentUser = User.fromJson(response['usuario']);
      await _storage.saveUser(_currentUser!);

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== REGISTER ====================

  Future<bool> register({
    required String nombres,
    required String apellidos,
    required String correo,
    required String password,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        password: password,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
        sexo: sexo,
      );

      // Guardar token
      await _storage.saveToken(response['token']);

      // Crear usuario
      _currentUser = User.fromJson(response['usuario']);
      await _storage.saveUser(_currentUser!);

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _storage.clearAll();

    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    _isLoading = false;

    notifyListeners();
  }

  // ==================== ACTUALIZAR PERFIL ====================

  Future<bool> updateProfile({
    String? nombres,
    String? apellidos,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> data = {};
      if (nombres != null) data['nombres'] = nombres;
      if (apellidos != null) data['apellidos'] = apellidos;
      if (telefono != null) data['telefono'] = telefono;
      if (fechaNacimiento != null) {
        data['fecha_nacimiento'] = fechaNacimiento.toIso8601String();
      }
      if (sexo != null) data['sexo'] = sexo;

      final response = await _apiService.updateUsuario(
        _currentUser!.idUsuario,
        data,
      );

      _currentUser = User.fromJson(response['usuario']);
      await _storage.saveUser(_currentUser!);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== LIMPIAR ERROR ====================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}