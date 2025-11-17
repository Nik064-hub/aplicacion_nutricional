// lib/features/auth/signup_paciente_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/paciente.dart';
import '../../core/services/local_db_service.dart';
import '../../core/utils/hash_utils.dart';

class SignUpPacienteScreen extends StatefulWidget {
  final LocalDbService db;

  const SignUpPacienteScreen({super.key, required this.db});

  @override
  State<SignUpPacienteScreen> createState() => _SignUpPacienteScreenState();
}

class _SignUpPacienteScreenState extends State<SignUpPacienteScreen> {
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final edadCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();

  bool cargando = false;

  Future<void> registrar() async {
    setState(() => cargando = true);

    final p = Paciente(
      numUsuario: DateTime.now().millisecondsSinceEpoch,
      nombre: nombreCtrl.text.trim(),
      correo: correoCtrl.text.trim(),
      contrasena: '',
      edad: int.parse(edadCtrl.text),
      pesoInicial: double.parse(pesoCtrl.text),
      altura: double.parse(alturaCtrl.text),
      historialClinico: "",
    );

    final hash = HashUtils.hashPassword(passCtrl.text);

    await widget.db.registrarPaciente(p, hash);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cuenta creada")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Paciente")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _campo("Nombre", nombreCtrl),
          _campo("Correo", correoCtrl),
          _campo("Contraseña", passCtrl, pass: true),
          _campo("Edad", edadCtrl),
          _campo("Peso inicial (kg)", pesoCtrl),
          _campo("Altura (m)", alturaCtrl),
          const SizedBox(height: 20),
          cargando
              ? const Center(child: CircularProgressIndicator())
              : FilledButton(
                  onPressed: registrar,
                  child: const Text("Crear Cuenta"),
                ),
        ],
      ),
    );
  }

  Widget _campo(String label, TextEditingController c, {bool pass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: pass,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
