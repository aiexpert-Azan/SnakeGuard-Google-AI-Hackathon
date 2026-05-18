import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/scan_result.dart';

class ApiService {
  // Simulate an API call with a realistic delay and mock JSON response
  Future<ScanResult> analyzeSnake(XFile image) async {
    // Simulated network delay
    await Future.delayed(const Duration(seconds: 4));

    final String mockResponse = '''
    {
      "species": "Russell Viper",
      "danger_level": "Critical",
      "description": "Highly venomous snake requiring immediate medical attention. Keep the patient calm and immobilize the bitten limb.",
      "hospitals": [
        {
          "name": "City Hospital Lahore",
          "address": "Main Boulevard Lahore",
          "maps_url": "https://maps.google.com/?q=City+Hospital+Lahore",
          "distance_km": 1.2
        },
        {
          "name": "General Hospital",
          "address": "Ferozepur Road",
          "maps_url": "https://maps.google.com/?q=General+Hospital+Lahore",
          "distance_km": 3.5
        },
        {
          "name": "Mayo Hospital",
          "address": "Hospital Road",
          "maps_url": "https://maps.google.com/?q=Mayo+Hospital+Lahore",
          "distance_km": 5.0
        }
      ],
      "trace_logs": [
        {
          "step": "PLAN",
          "message": "Preparing image preprocessing pipeline"
        },
        {
          "step": "ACT",
          "message": "Running venom classification model"
        },
        {
          "step": "OBSERVE",
          "message": "Detected high-risk venomous species"
        }
      ]
    }
    ''';

    final Map<String, dynamic> json = jsonDecode(mockResponse);
    return ScanResult.fromJson(json);
  }

  Future<String> downloadPdfReport(ScanResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('SnakeGuard AI - Emergency Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Species: ${result.species}', style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Danger Level: ${result.dangerLevel}',
                  style: pw.TextStyle(fontSize: 18, color: result.dangerLevel == 'Critical' ? PdfColors.red : PdfColors.black)),
              pw.SizedBox(height: 10),
              pw.Text('Description:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(result.description),
              pw.SizedBox(height: 20),
              pw.Text('Nearby Hospitals:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...result.hospitals.map((h) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(h.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(h.address),
                      pw.Text('${h.distanceKm} km away'),
                      pw.SizedBox(height: 10),
                    ],
                  )),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/emergency_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
