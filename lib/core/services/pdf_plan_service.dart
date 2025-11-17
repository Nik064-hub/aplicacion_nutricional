// lib/core/services/pdf_plan_service.dart

import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import '../models/plan_alimenticio.dart';

class PdfPlanService {
  Future<Uint8List> generarPdf(PlanAlimenticio plan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            "Plan Alimenticio Semanal",
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          ...plan.dias.map(
            (dia) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Divider(),
                pw.Text(
                  dia.nombreDia,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Calorías totales: ${dia.totalCalorias.toStringAsFixed(0)}",
                ),
                pw.SizedBox(height: 5),
                ...dia.comidas.map(
                  (c) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("• ${c.titulo} (${c.tipoComida})"),
                      pw.Text("  ${c.calorias.toStringAsFixed(0)} kcal"),
                      pw.SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
