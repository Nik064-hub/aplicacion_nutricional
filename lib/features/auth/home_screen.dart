// lib/features/nutrition/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/paciente.dart';
import '../../core/services/local_db_service.dart';
import '../../core/services/plan_alimenticio_service.dart';

class HomeScreen extends StatelessWidget {
  final Paciente paciente;
  final LocalDbService db;
  final PlanAlimenticioService planService;

  const HomeScreen({
    super.key,
    required this.paciente,
    required this.db,
    required this.planService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hola, ${paciente.nombre} 👋")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _opcion(
            context,
            titulo: "Mi plan semanal",
            icono: Icons.calendar_month,
            ruta: '/weeklyPlan',
          ),
          const SizedBox(height: 12),
          _opcion(
            context,
            titulo: "Mi progreso",
            icono: Icons.show_chart,
            ruta: '/patientProgress',
          ),
        ],
      ),
    );
  }

  Widget _opcion(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required String ruta,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icono, size: 28),
        title: Text(titulo),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, ruta, arguments: paciente.numUsuario);
        },
      ),
    );
  }
}
