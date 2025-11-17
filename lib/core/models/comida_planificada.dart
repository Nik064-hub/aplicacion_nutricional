// lib/core/models/comida_planificada.dart

class ComidaPlanificada {
  final int recetaId;
  final String titulo;
  final String tipoComida;
  final int readyInMinutes;
  final int porciones;
  final String? sourceUrl;
  final String? imageUrl;
  final double calorias;

  ComidaPlanificada({
    required this.recetaId,
    required this.titulo,
    required this.tipoComida,
    required this.readyInMinutes,
    required this.porciones,
    required this.sourceUrl,
    required this.imageUrl,
    required this.calorias,
  });
}
