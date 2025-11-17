// lib/features/ai/food_recognition_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/local_db_service.dart';
import 'ai_food_service.dart';
import 'nutrition_result_dialog.dart';

class FoodRecognitionScreen extends StatefulWidget {
  final LocalDbService db;

  const FoodRecognitionScreen({super.key, required this.db});

  @override
  State<FoodRecognitionScreen> createState() => _FoodRecognitionScreenState();
}

class _FoodRecognitionScreenState extends State<FoodRecognitionScreen> {
  File? imagen;
  bool cargando = false;
  final ai = AIFoodService();

  Future<void> tomarFoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera);

    if (x != null) {
      setState(() => imagen = File(x.path));
      analizarImagen();
    }
  }

  Future<void> subirFoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);

    if (x != null) {
      setState(() => imagen = File(x.path));
      analizarImagen();
    }
  }

  Future<void> analizarImagen() async {
    if (imagen == null) return;

    setState(() => cargando = true);

    // 1) Detectar alimento
    final detectado = await ai.detectarAlimento(imagen!);

    if (detectado == null) {
      mostrarError("No se pudo identificar el alimento.");
      setState(() => cargando = false);
      return;
    }

    final nombre = detectado["nombre"];

    // 2) Obtener nutrientes
    final nutrientes = await ai.obtenerNutrientes(nombre);

    if (nutrientes == null) {
      mostrarError("No se pudo obtener información nutricional.");
      setState(() => cargando = false);
      return;
    }

    setState(() => cargando = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => NutritionResultDialog(data: nutrientes),
    );
  }

  void mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reconocer alimento")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            imagen != null
                ? Image.file(imagen!, height: 220)
                : Container(
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Text("Sube o toma una foto"),
                  ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      FilledButton.icon(
                        onPressed: tomarFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Tomar foto"),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: subirFoto,
                        icon: const Icon(Icons.photo),
                        label: const Text("Subir foto"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
