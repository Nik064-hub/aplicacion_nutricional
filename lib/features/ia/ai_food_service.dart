// lib/features/ai/ai_food_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIFoodService {
  static const String apiKey =
      "816b1c7a4c1b4fd2ac9d5bd43323d721"; // AQUÍ VA TU API KEY

  // Identificar alimento por foto
  Future<Map<String, dynamic>?> detectarAlimento(File imagen) async {
    final url = Uri.parse(
      "https://api.spoonacular.com/food/images/analyze?apiKey=$apiKey",
    );

    final request = http.MultipartRequest("POST", url)
      ..files.add(await http.MultipartFile.fromPath("file", imagen.path));

    final response = await request.send();

    if (response.statusCode != 200) return null;

    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    return {
      "nombre": data["category"] ?? "Desconocido",
      "probabilidad": data["confidence"] ?? 0.0,
    };
  }

  // Obtener nutrientes del alimento detectado
  Future<Map<String, dynamic>?> obtenerNutrientes(String nombre) async {
    final url = Uri.parse(
      "https://api.spoonacular.com/food/ingredients/search?query=$nombre&number=1&apiKey=$apiKey",
    );

    final res = await http.get(url);

    if (res.statusCode != 200) return null;

    final json = jsonDecode(res.body);

    if (json["results"].isEmpty) return null;

    final id = json["results"][0]["id"];

    final infoUrl = Uri.parse(
      "https://api.spoonacular.com/food/ingredients/$id/information?amount=100&unit=gram&apiKey=$apiKey",
    );

    final infoRes = await http.get(infoUrl);

    if (infoRes.statusCode != 200) return null;

    final ing = jsonDecode(infoRes.body);

    return {
      "id": id,
      "nombre": ing["name"],
      "calorias":
          ing["nutrition"]["nutrients"]?.firstWhere(
            (n) => n["name"] == "Calories",
            orElse: () => {"amount": 0},
          )["amount"] ??
          0,
      "proteina":
          ing["nutrition"]["nutrients"]?.firstWhere(
            (n) => n["name"] == "Protein",
            orElse: () => {"amount": 0},
          )["amount"] ??
          0,
      "carbs":
          ing["nutrition"]["nutrients"]?.firstWhere(
            (n) => n["name"] == "Carbohydrates",
            orElse: () => {"amount": 0},
          )["amount"] ??
          0,
      "grasas":
          ing["nutrition"]["nutrients"]?.firstWhere(
            (n) => n["name"] == "Fat",
            orElse: () => {"amount": 0},
          )["amount"] ??
          0,
    };
  }
}
