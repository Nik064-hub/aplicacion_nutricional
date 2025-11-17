// lib/features/nutrition/weekly_plan_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/paciente.dart';
import '../../core/models/plan_alimenticio.dart';
import '../../core/services/local_db_service.dart';
import '../../core/services/plan_alimenticio_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pdf_plan_service.dart';

class WeeklyPlanScreen extends StatefulWidget {
  final Paciente paciente;
  final LocalDbService db;
  final PlanAlimenticioService planService;
  final NotificationService notificationService;
  final PdfPlanService pdfService;

  const WeeklyPlanScreen({
    super.key,
    required this.paciente,
    required this.db,
    required this.planService,
    required this.notificationService,
    required this.pdfService,
  });

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  bool cargando = true;
  PlanAlimenticio? plan;
  String objetivo = "mantener";

  @override
  void initState() {
    super.initState();
    cargarPlan();
  }

  Future<void> cargarPlan() async {
    final actual = await widget.db.obtenerPlanSemanal(
      widget.paciente.numUsuario,
    );

    if (actual != null) {
      setState(() {
        plan = actual;
        cargando = false;
      });
      return;
    }

    final generado = await widget.planService.generarPlan(
      widget.paciente,
      objetivo,
    );
    await widget.db.guardarPlanSemanal(widget.paciente.numUsuario, generado);

    setState(() {
      plan = generado;
      cargando = false;
    });
  }

  Future<void> exportarPdf() async {
    if (plan == null) return;

    final bytes = await widget.pdfService.generarPdf(plan!);

    // Mostrar print dialog
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> activarRecordatorios() async {
    if (plan == null) return;

    int id = 2000; // base

    for (final dia in plan!.dias) {
      for (final comida in dia.comidas) {
        final hour = _horaSugerida(comida.tipoComida);
        final fecha = DateTime(
          dia.fecha.year,
          dia.fecha.month,
          dia.fecha.day,
          hour,
        );

        await widget.notificationService.scheduleMealReminder(
          id: id++,
          titulo: comida.tipoComida,
          cuerpo: comida.titulo,
          fechaHora: fecha,
        );
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Notificaciones programadas")));
  }

  int _horaSugerida(String tipo) {
    switch (tipo.toLowerCase()) {
      case "desayuno":
        return 8;
      case "almuerzo":
        return 13;
      case "cena":
        return 19;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan semanal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: exportarPdf,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: activarRecordatorios,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: plan!.dias.map(_buildDia).toList(),
      ),
    );
  }

  Widget _buildDia(DiaPlanAlimenticio dia) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        title: Text(
          "${dia.nombreDia} - ${dia.totalCalorias.toStringAsFixed(0)} kcal",
        ),
        children: dia.comidas.map((c) {
          return ListTile(
            leading: c.imageUrl != null
                ? Image.network(c.imageUrl!, width: 50)
                : const Icon(Icons.food_bank),
            title: Text(c.titulo),
            subtitle: Text(
              "${c.tipoComida} - ${c.calorias.toStringAsFixed(0)} kcal",
            ),
          );
        }).toList(),
      ),
    );
  }
}
