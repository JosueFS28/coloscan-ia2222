import 'package:flutter/material.dart';
import '../models/historial.dart';
import '../models/historial_list.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class HistorialController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  HistorialList? _historialList;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _filtroInicio;
  DateTime? _filtroFin;

  // Getters
  HistorialList? get historialList => _historialList;
  List<HistorialPrediccion> get historial => _historialList?.historial ?? [];
  List<HistorialPrediccion> get historialOrdenado => 
      _historialList?.ordenadoPorFecha ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get total => _historialList?.total ?? 0;
  int get totalMalignos => _historialList?.totalMalignos ?? 0;
  int get totalBenignos => _historialList?.totalBenignos ?? 0;

  // ==================== CARGAR HISTORIAL ====================

  Future<bool> loadHistorial() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Obtener ID del usuario actual
      String? userId = await _storage.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Llamar API
      final response = await _apiService.getHistorial(userId);
      _historialList = HistorialList.fromJson(response);

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

  // ==================== ELIMINAR REGISTRO ====================

  Future<bool> deleteHistorial(String idHistorial) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteHistorial(idHistorial);

      // Recargar historial
      await loadHistorial();

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

  // ==================== FILTROS ====================

  void setFiltroFechas(DateTime? inicio, DateTime? fin) {
    _filtroInicio = inicio;
    _filtroFin = fin;
    notifyListeners();
  }

  List<HistorialPrediccion> get historialFiltrado {
    if (_filtroInicio == null || _filtroFin == null || _historialList == null) {
      return historialOrdenado;
    }

    return _historialList!.filtrarPorFechas(_filtroInicio!, _filtroFin!);
  }

  void clearFiltros() {
    _filtroInicio = null;
    _filtroFin = null;
    notifyListeners();
  }

  // ==================== BUSCAR POR ID ====================

  HistorialPrediccion? getHistorialById(String idHistorial) {
    if (_historialList == null) return null;

    try {
      return _historialList!.historial.firstWhere(
        (h) => h.idHistorial == idHistorial,
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== REFRESCAR ====================

  Future<bool> refresh() async {
    return await loadHistorial();
  }

  // ==================== LIMPIAR ====================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _historialList = null;
    _errorMessage = null;
    _filtroInicio = null;
    _filtroFin = null;
    notifyListeners();
  }
}