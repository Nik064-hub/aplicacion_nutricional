// lib/features/auth/signup_nutricionista_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/nutricionista.dart';
import '../../core/services/local_db_service.dart';
import '../../core/utils/hash_utils.dart';

class SignUpNutricionistaScreen extends StatefulWidget {
  final LocalDbService db;

  const SignUpNutricionistaScreen({super.key, required this.db});

  @override
  State<SignUpNutricionistaScreen> createState() =>
      _SignUpNutricionistaScreenState();
}

class _SignUpNutricionistaScreenState extends State<SignUpNutricionistaScreen> {
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final especialidadCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();

  bool cargando = false;

  Future<void> registrar() async {
    setState(() => cargando = true);

    final n = Nutricionista(
      numUsuario: DateTime.now().millisecondsSinceEpoch,
      nombre: nombreCtrl.text.trim(),
      correo: correoCtrl.text.trim(),
      contrasena: '',
      especialidad: especialidadCtrl.text.trim(),
      cedulaProfesional: int.parse(cedulaCtrl.text),
    );

    final hash = HashUtils.hashPassword(passCtrl.text);

    await widget.db.registrarNutricionista(n, hash);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Nutricionista registrado")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Nutricionista")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _campo("Nombre", nombreCtrl),
          _campo("Correo", correoCtrl),
          _campo("Contraseña", passCtrl, pass: true),
          _campo("Especialidad", especialidadCtrl),
          _campo("Cédula Profesional", cedulaCtrl),
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
