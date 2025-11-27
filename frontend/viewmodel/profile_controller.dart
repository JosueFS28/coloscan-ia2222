import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==================== CARGAR PERFIL ====================

  Future<bool> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cargar desde storage primero
      _user = await _storage.getUser();

      if (_user != null) {
        // Actualizar desde API
        final response = await _apiService.getUsuario(_user!.idUsuario);
        _user = User.fromJson(response['usuario']);
        await _storage.saveUser(_user!);
      }

      _isLoading = false;
      notifyListeners();

      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== ACTUALIZAR PERFIL ====================

  Future<bool> updateProfile({
    String? nombres,
    String? apellidos,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
  }) async {
    if (_user == null) return false;

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
        _user!.idUsuario,
        data,
      );

      _user = User.fromJson(response['usuario']);
      await _storage.saveUser(_user!);

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

  // ==================== HELPERS ====================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
