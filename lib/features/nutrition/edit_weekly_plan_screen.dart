// lib/features/nutrition/edit_weekly_plan_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/paciente.dart';
import '../../core/models/plan_alimenticio.dart';
import '../../core/models/dia_plan_alimenticio.dart';
import '../../core/models/comida_planificada.dart';
import '../../core/services/local_db_service.dart';

class EditWeeklyPlanScreen extends StatefulWidget {
  final Paciente paciente;
  final LocalDbService db;

  const EditWeeklyPlanScreen({
    super.key,
    required this.paciente,
    required this.db,
  });

  @override
  State<EditWeeklyPlanScreen> createState() => _EditWeeklyPlanScreenState();
}

class _EditWeeklyPlanScreenState extends State<EditWeeklyPlanScreen> {
  bool cargando = true;
  PlanAlimenticio? plan;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    final p = await widget.db.obtenerPlanSemanal(widget.paciente.numUsuario);

    setState(() {
      plan = p;
      cargando = false;
    });
  }

  void editarComida(DiaPlanAlimenticio dia, ComidaPlanificada comida) {
    final nombreCtrl = TextEditingController(text: comida.titulo);
    final tipoCtrl = TextEditingController(text: comida.tipoComida);
    final calCtrl = TextEditingController(text: comida.calorias.toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar comida"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: tipoCtrl,
                decoration: const InputDecoration(labelText: "Tipo"),
              ),
              TextField(
                controller: calCtrl,
                decoration: const InputDecoration(labelText: "Calorías"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                final idxDia = plan!.dias.indexOf(dia);
                final idxComida = plan!.dias[idxDia].comidas.indexOf(comida);

                plan!.dias[idxDia].comidas[idxComida] = ComidaPlanificada(
                  recetaId: comida.recetaId,
                  titulo: nombreCtrl.text,
                  tipoComida: tipoCtrl.text,
                  readyInMinutes: comida.readyInMinutes,
                  porciones: comida.porciones,
                  sourceUrl: comida.sourceUrl,
                  imageUrl: comida.imageUrl,
                  calorias: double.tryParse(calCtrl.text) ?? comida.calorias,
                );

                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> guardarPlan() async {
    if (plan == null) return;

    await widget.db.reemplazarPlanSemanal(widget.paciente.numUsuario, plan!);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Plan actualizado")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Editar Plan")),
        body: const Center(child: Text("No hay plan generado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar plan • ${widget.paciente.nombre}"),
        actions: [
          IconButton(onPressed: guardarPlan, icon: const Icon(Icons.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: plan!.dias.map((dia) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                "${dia.nombreDia} • ${dia.totalCalorias.toStringAsFixed(0)} kcal",
              ),
              children: dia.comidas.map((c) {
                return ListTile(
                  title: Text(c.titulo),
                  subtitle: Text(
                    "${c.tipoComida} - ${c.calorias.toStringAsFixed(0)} kcal",
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => editarComida(dia, c),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
