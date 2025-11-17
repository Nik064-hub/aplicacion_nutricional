// lib/features/nutrition/nutritionist_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/nutricionista.dart';
import '../../core/models/paciente.dart';
import '../../core/services/local_db_service.dart';
import 'edit_weekly_plan_screen.dart';

class NutritionistDashboardScreen extends StatelessWidget {
  final Nutricionista nutricionista;
  final List<Paciente> pacientes;
  final LocalDbService db;

  const NutritionistDashboardScreen({
    super.key,
    required this.nutricionista,
    required this.pacientes,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel de ${nutricionista.nombre}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: pacientes.map(_tilePaciente(context)).toList(),
      ),
    );
  }

  Widget Function(Paciente) _tilePaciente(BuildContext context) {
    return (p) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.person),
          title: Text(p.nombre),
          subtitle: Text("Edad: ${p.edad} — ${p.pesoInicial} kg"),
          trailing: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditWeeklyPlanScreen(paciente: p, db: db),
                ),
              );
            },
            child: const Text("Editar plan"),
          ),
        ),
      );
    };
  }
}
