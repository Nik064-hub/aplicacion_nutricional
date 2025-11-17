// lib/core/services/plan_alimenticio_service.dart

import '../models/paciente.dart';
import '../models/plan_alimenticio.dart';
import '../models/dia_plan_alimenticio.dart';
import '../models/comida_planificada.dart';
import 'spoonacular_api.dart';
import 'dart:math';

class PlanAlimenticioService {
  final SpoonacularApi api;

  PlanAlimenticioService({required this.api});

  Future<PlanAlimenticio> generarPlan(
    Paciente paciente,
    String objetivo,
  ) async {
    final now = DateTime.now();
    final dias = List.generate(7, (i) {
      final fecha = now.add(Duration(days: i));

      return DiaPlanAlimenticio(
        nombreDia: _nombreDia(fecha.weekday),
        fecha: fecha,
        comidas: [],
        totalCalorias: 0,
      );
    });

    for (final dia in dias) {
      dia.comidas = await _generarComidasDiarias(objetivo);
      dia.totalCalorias = dia.comidas.fold(0, (sum, c) => sum + c.calorias);
    }

    return PlanAlimenticio(
      fechaInicio: now,
      fechaFin: now.add(const Duration(days: 6)),
      dias: dias,
    );
  }

  // ---------------------------------------------------------------------------
  // 📌 Comidas diarias automáticas
  // ---------------------------------------------------------------------------
  Future<List<ComidaPlanificada>> _generarComidasDiarias(
    String objetivo,
  ) async {
    const comidas = ["desayuno", "almuerzo", "cena"];

    List<ComidaPlanificada> lista = [];

    for (final tipo in comidas) {
      final resultados = await api.buscarRecetas(tipo);

      if (resultados.isEmpty) continue;

      final receta = resultados[Random().nextInt(resultados.length)];

      lista.add(
        ComidaPlanificada(
          recetaId: receta['id'],
          titulo: receta['title'] ?? "Comida",
          tipoComida: tipo,
          readyInMinutes: receta['readyInMinutes'] ?? 20,
          porciones: receta['servings'] ?? 1,
          sourceUrl: receta['sourceUrl'],
          imageUrl: receta['image'],
          calorias:
              receta["nutrition"]?["nutrients"]?[0]?["amount"]?.toDouble() ??
              300,
        ),
      );
    }

    return lista;
  }

  String _nombreDia(int weekday) {
    switch (weekday) {
      case 1:
        return "Lunes";
      case 2:
        return "Martes";
      case 3:
        return "Miércoles";
      case 4:
        return "Jueves";
      case 5:
        return "Viernes";
      case 6:
        return "Sábado";
      default:
        return "Domingo";
    }
  }
}
