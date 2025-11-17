// lib/core/models/dia_plan_alimenticio.dart

import 'comida_planificada.dart';

class DiaPlanAlimenticio {
  final String nombreDia;
  final DateTime fecha;
  List<ComidaPlanificada> comidas;
  double totalCalorias;

  DiaPlanAlimenticio({
    required this.nombreDia,
    required this.fecha,
    required this.comidas,
    required this.totalCalorias,
  });
}
