import 'package:flutter/material.dart';
import 'dart:io';
import '../models/prediction.dart';
import '../models/imagen.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';

class PredictionController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImageService _imageService = ImageService();
  final StorageService _storage = StorageService();

  File? _selectedImage;
  ImagenSubida? _uploadedImage;
  Prediction? _currentPrediction;
  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  // Getters
  File? get selectedImage => _selectedImage;
  ImagenSubida? get uploadedImage => _uploadedImage;
  Prediction? get currentPrediction => _currentPrediction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  // ==================== SELECCIONAR IMAGEN ====================

Future<bool> pickImageFromGallery() async {
  try {
    print("🔍 PredictionController: Llamando a imageService..."); // ← AGREGAR
    
    _errorMessage = null;
    File? image = await _imageService.pickImageFromGallery();
    
    print("🔍 PredictionController: Imagen recibida: ${image?.path}"); // ← AGREGAR
    
    if (image != null) {
      _selectedImage = image;
      print("✅ PredictionController: Imagen guardada en _selectedImage"); // ← AGREGAR
      notifyListeners();
      return true;
    }
    return false;
  } catch (e) {
    print("❌ ERROR en PredictionController: $e"); // ← AGREGAR
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}

  Future<bool> pickImageFromCamera() async {
    try {
      _errorMessage = null;
      File? image = await _imageService.pickImageFromCamera();
      
      if (image != null) {
        print('✅ Imagen seleccionada: ${image.path}'); // 👈
        _selectedImage = image;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== SUBIR Y PREDECIR ====================

  Future<bool> uploadAndPredict() async {
    if (_selectedImage == null) {
      _errorMessage = 'No hay imagen seleccionada';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // 1. Subir imagen
      _uploadProgress = 0.3;
      notifyListeners();

      final uploadResponse = await _apiService.uploadImage(_selectedImage!);
      print('📤 Respuesta subida: $uploadResponse'); // 👈 Agrega esto
      _uploadedImage = ImagenSubida.fromJson(uploadResponse['imagen']);

      // 2. Hacer predicción
      _uploadProgress = 0.6;
      notifyListeners();

      final predictResponse = await _apiService.predictImage(
        _uploadedImage!.idImagen,
      );
      print('🧠 Respuesta predicción: $predictResponse'); // 👈 Agrega esto
      _currentPrediction = Prediction.fromJson(predictResponse['prediccion']);

      // 3. Completado
      _uploadProgress = 1.0;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  // ==================== OBTENER PREDICCIÓN ====================

  Future<bool> getPrediccion(String idPrediccion) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getPrediccion(idPrediccion);
      _currentPrediction = Prediction.fromJson(response['prediccion']);

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

  // ==================== LIMPIAR ====================

  void clearSelection() {
    _selectedImage = null;
    _uploadedImage = null;
    _currentPrediction = null;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}