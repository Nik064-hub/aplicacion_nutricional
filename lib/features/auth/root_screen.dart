// lib/features/auth/root_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/session_manager.dart';
import '../../core/services/local_db_service.dart';

class RootScreen extends StatefulWidget {
  final SessionManager sessionManager;
  final LocalDbService db;

  const RootScreen({super.key, required this.sessionManager, required this.db});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    final sesion = await widget.sessionManager.cargarSesion();

    if (sesion == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final tipo = sesion['tipo'];
    final id = sesion['id'];

    if (tipo == 'paciente') {
      Navigator.pushReplacementNamed(context, '/home', arguments: id);
    } else {
      Navigator.pushReplacementNamed(context, '/nutriDashboard', arguments: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
