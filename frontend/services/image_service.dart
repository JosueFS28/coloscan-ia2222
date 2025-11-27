import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../config/constants.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // ==================== SELECCIONAR IMAGEN ====================

 Future<File?> pickImageFromGallery() async {
  try {
    print("🔍 Intentando abrir galería..."); // ← AGREGAR
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    print("🔍 Imagen seleccionada: ${image?.path}"); // ← AGREGAR

    if (image != null) {
      File imageFile = File(image.path);
      
      if (!await _validateImageSize(imageFile)) {
        throw Exception('La imagen es muy grande...');
      }

      print("✅ Imagen validada correctamente"); // ← AGREGAR
      return imageFile;
    }
    
    print("⚠️ No se seleccionó ninguna imagen"); // ← AGREGAR
    return null;
  } catch (e) {
    print("❌ ERROR en pickImageFromGallery: $e"); // ← AGREGAR
    throw Exception('Error al seleccionar imagen: $e');
  }
}

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        File imageFile = File(image.path);
        
        // Validar tamaño
        if (!await _validateImageSize(imageFile)) {
          throw Exception(
            'La imagen es muy grande. Máximo ${AppConstants.maxImageSizeMB}MB'
          );
        }

        return imageFile;
      }
      return null;
    } catch (e) {
      throw Exception('Error al capturar imagen: $e');
    }
  }

  // ==================== VALIDACIONES ====================

  Future<bool> _validateImageSize(File file) async {
    int sizeInBytes = await file.length();
    int sizeInMb = sizeInBytes ~/ (1024 * 1024);
    return sizeInMb <= AppConstants.maxImageSizeMB;
  }

  bool isValidImageType(String path) {
    String extension = path.split('.').last.toLowerCase();
    return AppConstants.allowedImageTypes.contains(extension);
  }

  Future<int> getImageSizeMB(File file) async {
    int sizeInBytes = await file.length();
    return sizeInBytes ~/ (1024 * 1024);
  }
}
