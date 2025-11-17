// lib/features/auth/signup_selector_screen.dart

import 'package:flutter/material.dart';

class SignUpSelectorScreen extends StatelessWidget {
  const SignUpSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Selecciona tu tipo de usuario:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/signupPaciente'),
              child: const Text("Soy Paciente"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/signupNutricionista'),
              child: const Text("Soy Nutricionista"),
            ),
          ],
        ),
      ),
    );
  }
}
