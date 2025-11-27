class User {
  final String idUsuario;
  final String nombres;
  final String apellidos;
  final String correo;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? sexo;

  User({
    required this.idUsuario,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    this.telefono,
    this.fechaNacimiento,
    this.sexo,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['id_usuario'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'],
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      sexo: json['sexo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'sexo': sexo,
    };
  }

  @override
  String toString() => 'User(id: $idUsuario, nombre: $nombreCompleto)';
}