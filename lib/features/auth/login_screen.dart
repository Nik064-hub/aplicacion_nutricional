// lib/features/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/local_db_service.dart';
import '../../core/services/session_manager.dart';
import '../../core/utils/hash_utils.dart';

class LoginScreen extends StatefulWidget {
  final LocalDbService db;
  final SessionManager sessionManager;

  const LoginScreen({
    super.key,
    required this.db,
    required this.sessionManager,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool cargando = false;

  Future<void> login() async {
    setState(() => cargando = true);

    final correo = correoCtrl.text.trim();
    final passHash = HashUtils.hashPassword(passCtrl.text.trim());

    final datos = await widget.db.login(correo);

    if (datos == null) {
      setState(() => cargando = false);
      _error("Correo no encontrado.");
      return;
    }

    final user = datos['data'];
    final tipo = datos['tipo'];

    if (user['contrasenaHash'] != passHash) {
      setState(() => cargando = false);
      _error("Contraseña incorrecta.");
      return;
    }

    // Guardar sesión
    await widget.sessionManager.guardarSesion(tipo, user['id']);

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      tipo == 'paciente' ? '/home' : '/nutriDashboard',
      arguments: user['id'],
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: correoCtrl,
              decoration: const InputDecoration(
                labelText: "Correo",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator()
                : FilledButton(onPressed: login, child: const Text("Ingresar")),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signupSelector'),
              child: const Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}
