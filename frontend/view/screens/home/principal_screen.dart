import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/prediction_controller.dart';
import '../../../viewmodel/auth_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../prediction/resultados_screen.dart';
import '../historial/historial_screen.dart';
import '../info/informacion_screen.dart';
import '../profile/perfiles_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Limpiar selección previa al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionController>().clearSelection();
    });
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);

    Widget screen;
    switch (index) {
      case 0:
        screen = const PrincipalScreen();
        break;
      case 1:
        screen = const HistorialScreen();
        break;
      case 2:
        screen = const InformacionScreen();
        break;
      case 3:
        screen = const PerfilesScreen();
        break;
      default:
        screen = const PrincipalScreen();
    }

    if (index != 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  Future<void> _handlePickFromGallery() async {
    final controller = context.read<PredictionController>();
    await controller.pickImageFromGallery();
  }

  Future<void> _handlePickFromCamera() async {
    final controller = context.read<PredictionController>();
    await controller.pickImageFromCamera();
  }

  Future<void> _handleAnalyze() async {
    final controller = context.read<PredictionController>();

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analizando imagen...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Subir y predecir
    bool success = await controller.uploadAndPredict();

    if (!mounted) return;

    // Cerrar diálogo
    Navigator.of(context).pop();

    if (success) {
      // Navegar a resultados
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ResultadosScreen()),
      );
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'Error al analizar imagen',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBF4FF), Color(0xFFEDE9FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Header con nombre de usuario
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Column(
                      children: [
                        Text(
                          "Hola, ${authController.currentUser?.nombres ?? 'Usuario'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Análisis de Imagen",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sube una imagen médica para el análisis con IA",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // Instrucciones
                _buildInstructionsCard(),
                const SizedBox(height: 20),

                // Card de subida de imagen
                _buildUploadCard(),
                const SizedBox(height: 20),

                // Advertencia
                _buildWarningCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Instrucciones",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            InstructionItem(
              text: "Imágenes de colonoscopía en formato JPG, PNG o JPEG",
            ),
            InstructionItem(
              text: "Resolución mínima recomendada: 512x512 px",
            ),
            InstructionItem(
              text: "Asegúrate de que la imagen sea clara y bien iluminada",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Consumer<PredictionController>(
      builder: (context, controller, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Subir Imagen Médica",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Selecciona una imagen para el análisis",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // Botones de selección
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isLoading 
                            ? null 
                            : _handlePickFromGallery,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 80),
                          side: const BorderSide(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, color: Colors.blue),
                            SizedBox(height: 6),
                            Text("Subir Archivo"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isLoading 
                            ? null 
                            : _handlePickFromCamera,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 80),
                          side: const BorderSide(
                            color: Colors.purple,
                            width: 1.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.purple),
                            SizedBox(height: 6),
                            Text("Tomar Foto"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Preview de imagen seleccionada
                if (controller.selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      controller.selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Botón de análisis
                  ElevatedButton(
                    onPressed: controller.isLoading ? null : _handleAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text("Iniciar Análisis con IA"),
                  ),
                  const SizedBox(height: 8),
                  
                  // Botón para limpiar selección
                  TextButton(
                    onPressed: controller.isLoading 
                        ? null 
                        : () => controller.clearSelection(),
                    child: const Text("Cancelar"),
                  ),
                ],

                // Mostrar mensaje si no hay imagen
                if (controller.selectedImage == null) ...[
                  const Text(
                    "No hay imagen seleccionada",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: const Color(0xFFFFF7ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orange),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Importante",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Esta herramienta es solo de apoyo diagnóstico. "
                    "Siempre consulta con un profesional médico calificado.",
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable
class InstructionItem extends StatelessWidget {
  final String text;
  const InstructionItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 8, top: 6),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}