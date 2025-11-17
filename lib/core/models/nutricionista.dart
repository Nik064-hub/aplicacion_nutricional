// lib/core/models/nutricionista.dart

class Nutricionista {
  final int numUsuario;
  final String nombre;
  final String correo;
  final String contrasena; // No se guarda hash aquí
  final String especialidad;
  final int cedulaProfesional;

  Nutricionista({
    required this.numUsuario,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.especialidad,
    required this.cedulaProfesional,
  });
}
