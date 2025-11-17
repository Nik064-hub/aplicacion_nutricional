// lib/features/nutrition/patient_progress_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/paciente.dart';
import '../../core/services/local_db_service.dart';

class PatientProgressScreen extends StatefulWidget {
  final Paciente paciente;
  final LocalDbService db;

  const PatientProgressScreen({
    super.key,
    required this.paciente,
    required this.db,
  });

  @override
  State<PatientProgressScreen> createState() => _PatientProgressScreenState();
}

class _PatientProgressScreenState extends State<PatientProgressScreen> {
  List<Map<String, dynamic>> progresos = [];
  final pesoCtrl = TextEditingController();
  final notasCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    final rows = await widget.db.obtenerSeguimientos(
      widget.paciente.numUsuario,
    );
    setState(() => progresos = rows);
  }

  Future<void> guardar() async {
    final peso = double.tryParse(pesoCtrl.text);
    if (peso == null) return;

    await widget.db.guardarSeguimiento(
      widget.paciente.numUsuario,
      peso,
      notasCtrl.text,
    );

    pesoCtrl.clear();
    notasCtrl.clear();

    await cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Progreso")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Añadir registro",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: pesoCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Peso (kg)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notasCtrl,
            decoration: const InputDecoration(
              labelText: "Notas",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: guardar,
            child: const Text("Guardar registro"),
          ),
          const SizedBox(height: 20),
          const Text(
            "Historial",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...progresos.map((p) {
            final fecha = DateTime.parse(p['fecha']);
            return Card(
              child: ListTile(
                title: Text("Peso: ${p['peso']} kg"),
                subtitle: Text("Fecha: $fecha\nNotas: ${p['notas']}"),
              ),
            );
          }),
        ],
      ),
    );
  }
}
