class ImagenSubida {
  final String idImagen;
  final String idUsuario;
  final String rutaImagen; 
  final DateTime? fechaSubida;
  final String? estado; 

  ImagenSubida({
    required this.idImagen,
    required this.idUsuario,
    required this.rutaImagen,
    this.fechaSubida,
    this.estado,
  });

  factory ImagenSubida.fromJson(Map<String, dynamic> json) {
    return ImagenSubida(
      idImagen: json['id_imagen'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      rutaImagen: json['ruta_imagen'] ?? '',
      fechaSubida: json['fecha_subida'] != null
          ? DateTime.parse(json['fecha_subida'])
          : null,
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_imagen': idImagen,
      'id_usuario': idUsuario,
      'ruta_imagen': rutaImagen,
      'fecha_subida': fechaSubida?.toIso8601String(),
      'estado': estado,
    };
  }

  bool get estaCompletado => estado?.toLowerCase() == 'completado';

  @override
  String toString() => 'ImagenSubida(id: $idImagen, estado: $estado)';
}