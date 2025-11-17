// lib/core/models/paciente.dart

class Paciente {
  final int numUsuario;
  final String nombre;
  final String correo;
  final String contrasena; // No se guarda el hash aquí
  final int edad;
  final double pesoInicial;
  final double altura;
  final String historialClinico;

  Paciente({
    required this.numUsuario,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.edad,
    required this.pesoInicial,
    required this.altura,
    required this.historialClinico,
  });
}
