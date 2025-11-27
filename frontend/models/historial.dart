import 'prediction.dart';

class HistorialPrediccion {
  final String idHistorial;
  final String idUsuario;
  final String idPrediccion;
  final DateTime fechaPrediccion;
  
  final Prediction? prediccion;

  HistorialPrediccion({
    required this.idHistorial,
    required this.idUsuario,
    required this.idPrediccion,
    required this.fechaPrediccion,
    this.prediccion,
  });

  factory HistorialPrediccion.fromJson(Map<String, dynamic> json) {
    return HistorialPrediccion(
      idHistorial: json['id_historial'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      idPrediccion: json['id_prediccion'] ?? '',
      fechaPrediccion: json['fecha_prediccion'] != null
          ? DateTime.parse(json['fecha_prediccion'])
          : DateTime.now(),
      prediccion: json['prediccion'] != null
          ? Prediction.fromJson(json['prediccion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_historial': idHistorial,
      'id_usuario': idUsuario,
      'id_prediccion': idPrediccion,
      'fecha_prediccion': fechaPrediccion.toIso8601String(),
      'prediccion': prediccion?.toJson(),
    };
  }

  @override
  String toString() => 'HistorialPrediccion(id: $idHistorial)';
}