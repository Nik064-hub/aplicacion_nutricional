// lib/core/services/spoonacular_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SpoonacularApi {
  final String apiKey;

  SpoonacularApi(this.apiKey);

  // ---------------------------------------------------------------------------
  // 📌 Reconocer alimento por imagen
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> reconocerComida(File imagen) async {
    final uri = Uri.parse(
      "https://api.spoonacular.com/food/images/analyze?apiKey=$apiKey",
    );

    final request = http.MultipartRequest("POST", uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode != 200) return null;

    return jsonDecode(respStr);
  }

  // ---------------------------------------------------------------------------
  // 📌 Encontrar recetas por nombre de comida detectada
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> buscarRecetas(String query) async {
    final url =
        "https://api.spoonacular.com/recipes/complexSearch?query=$query&number=10&addRecipeNutrition=true&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body);
    return json['results'] ?? [];
  }

  // ---------------------------------------------------------------------------
  // 📌 Obtener receta completa
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> obtenerReceta(int recetaId) async {
    final url =
        "https://api.spoonacular.com/recipes/$recetaId/information?includeNutrition=true&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return null;

    return jsonDecode(response.body);
  }
}
