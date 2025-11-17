// lib/core/models/diario_comida.dart

class DiarioComida {
  final int id;
  final int pacienteId;
  final DateTime fecha;
  final String comida;
  final double calorias;

  DiarioComida({
    required this.id,
    required this.pacienteId,
    required this.fecha,
    required this.comida,
    required this.calorias,
  });
}
