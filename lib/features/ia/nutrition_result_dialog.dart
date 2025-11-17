// lib/features/ai/nutrition_result_dialog.dart

import 'package:flutter/material.dart';

class NutritionResultDialog extends StatelessWidget {
  final Map<String, dynamic> data;

  const NutritionResultDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Resultado: ${data['nombre']}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Calorías: ${data['calorias']} kcal"),
          const SizedBox(height: 6),
          Text("Proteína: ${data['proteina']} g"),
          Text("Carbohidratos: ${data['carbs']} g"),
          Text("Grasas: ${data['grasas']} g"),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
