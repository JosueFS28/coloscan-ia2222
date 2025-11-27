class Prediction {
  final String idPrediccion;
  final String idImagen;
  final String idUsuario;
  final String resultado;
  final String probabilidad; // String como en tu BD
  final DateTime? fechaPrediccion;

  Prediction({
    required this.idPrediccion,
    required this.idImagen,
    required this.idUsuario,
    required this.resultado,
    required this.probabilidad,
    this.fechaPrediccion,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      idPrediccion: json['id_prediccion'] ?? '',
      idImagen: json['id_imagen'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      resultado: json['resultado'] ?? 'Desconocido',
      probabilidad: json['probabilidad'] ?? '0%',
      fechaPrediccion: json['fecha_prediccion'] != null
          ? DateTime.parse(json['fecha_prediccion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_prediccion': idPrediccion,
      'id_imagen': idImagen,
      'id_usuario': idUsuario,
      'resultado': resultado,
      'probabilidad': probabilidad,
      'fecha_prediccion': fechaPrediccion?.toIso8601String(),
    };
  }

  // Helpers
  bool get esMaligno => resultado.toLowerCase() == 'maligno';
  bool get esBenigno => resultado.toLowerCase() == 'benigno';

  String get confianzaPorcentaje => probabilidad;

  // Convertir probabilidad string a double si necesitas
  double get probabilidadNumero {
    try {
      String numStr = probabilidad.replaceAll('%', '').trim();
      return double.parse(numStr) / 100;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  String toString() => 'Prediction(resultado: $resultado, prob: $probabilidad)';
}