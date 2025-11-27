import 'package:flutter/material.dart';
import '../../../models/historial.dart';

class DetalleHistorialScreen extends StatelessWidget {
  final HistorialPrediccion historial;

  const DetalleHistorialScreen({
    super.key,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    final prediccion = historial.prediccion;

    if (prediccion == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text('No hay información disponible'),
        ),
      );
    }

    final isMaligno = prediccion.esMaligno;
    final color = isMaligno ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Análisis'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado
            Card(
              color: color.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: color, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      isMaligno ? Icons.warning : Icons.check_circle,
                      size: 48,
                      color: color,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prediccion.resultado,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confianza: ${prediccion.confianzaPorcentaje}',
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
            ),
            const SizedBox(height: 20),

            // Detalles
            const Text(
              'Información del Análisis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID Historial', historial.idHistorial),
            _buildInfoRow('ID Predicción', prediccion.idPrediccion),
            _buildInfoRow('Fecha', _formatDate(historial.fechaPrediccion)),
            _buildInfoRow('Probabilidad', prediccion.probabilidad),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}