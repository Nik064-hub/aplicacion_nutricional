// lib/core/models/plan_alimenticio.dart

import 'dia_plan_alimenticio.dart';

class PlanAlimenticio {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<DiaPlanAlimenticio> dias;

  PlanAlimenticio({
    required this.fechaInicio,
    required this.fechaFin,
    required this.dias,
  });
}
