import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/prediction_controller.dart';
import '../../../models/prediction.dart';
import '../home/principal_screen.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultado del Análisis"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PrincipalScreen()),
              (route) => false,
            );
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<PredictionController>(
        builder: (context, controller, child) {
          // Si no hay predicción, mostrar mensaje
          if (controller.currentPrediction == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay resultados disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final prediction = controller.currentPrediction!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estado
                _buildStatusCard(prediction),
                const SizedBox(height: 20),

                // Detalles del diagnóstico
                _buildDetailsCard(prediction),
                const SizedBox(height: 20),

                // Imagen analizada
                _buildImageCard(controller),
                const SizedBox(height: 20),

                // Recomendaciones
                _buildRecommendationsCard(prediction),
                const SizedBox(height: 20),

                // Botones de acción
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Prediction prediction) {
    final isMaligno = prediction.esMaligno;
    final color = isMaligno ? Colors.red : Colors.green;
    final icon = isMaligno ? Icons.warning : Icons.check_circle;
    final titulo = isMaligno ? "Lesión Detectada" : "Sin Lesiones Detectadas";

    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confianza: ${prediction.confianzaPorcentaje}',
                    style: TextStyle(
                      fontSize: 16,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Prediction prediction) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detalles del Análisis",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // Diagnóstico
            _buildDetailRow(
              icon: Icons.health_and_safety,
              label: "Diagnóstico",
              value: prediction.resultado,
              valueColor: prediction.esMaligno ? Colors.red : Colors.green,
            ),
            const Divider(height: 24),

            // Confianza
            _buildDetailRow(
              icon: Icons.analytics,
              label: "Nivel de Confianza",
              value: prediction.confianzaPorcentaje,
            ),
            const Divider(height: 24),

            // Fecha
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: "Fecha del Análisis",
              value: _formatDate(prediction.fechaPrediccion),
            ),
            const Divider(height: 24),

            // ID
            _buildDetailRow(
              icon: Icons.fingerprint,
              label: "ID de Análisis",
              value: prediction.idPrediccion,
              valueStyle: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(PredictionController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Imagen Analizada",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          if (controller.selectedImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.file(
                controller.selectedImage!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "Imagen no disponible",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(Prediction prediction) {
    final isMaligno = prediction.esMaligno;

    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Recomendaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isMaligno) ...[
              _buildRecommendationItem(
                "Consulta inmediata con un gastroenterólogo",
              ),
              _buildRecommendationItem(
                "Realiza estudios complementarios según indicación médica",
              ),
              _buildRecommendationItem(
                "Mantén un registro de tus síntomas",
              ),
            ] else ...[
              _buildRecommendationItem(
                "Mantén chequeos periódicos preventivos",
              ),
              _buildRecommendationItem(
                "Sigue una dieta saludable rica en fibra",
              ),
              _buildRecommendationItem(
                "Realiza actividad física regular",
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Esta herramienta es de apoyo diagnóstico. "
                      "Siempre consulta con un profesional médico.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botón: Nuevo análisis
        ElevatedButton.icon(
          onPressed: () {
            // Limpiar y volver a principal
            context.read<PredictionController>().clearSelection();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PrincipalScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.add_a_photo),
          label: const Text("Realizar Nuevo Análisis"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),

        // Botón: Guardar en historial (opcional)
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resultado guardado en el historial'),
                backgroundColor: Colors.green,
              ),
            );
          },
          icon: const Icon(Icons.save),
          label: const Text("Guardar Resultado"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}