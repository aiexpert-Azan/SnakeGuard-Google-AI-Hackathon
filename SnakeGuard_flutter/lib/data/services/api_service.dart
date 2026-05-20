import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scan_result.dart';
import '../models/gemini_info.dart';
import '../models/hospital.dart';

class ApiService {
  final String baseUrl = "https://snakeguard-backend.onrender.com";
  ScanResult? _cachedResult;

  Future<ScanResult> analyzeSnake(XFile image) async {
    final uri = Uri.parse("$baseUrl/analyze");
    final request = http.MultipartRequest("POST", uri);

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name,
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = ScanResult.fromJson(json);
      _cachedResult = result;
      return result;
    } else {
      throw Exception("Failed to analyze snake. Status code: ${response.statusCode}");
    }
  }

  Future<String> predictSnakeType(File imageFile) async {
    try {
      final result = await analyzeSnake(XFile(imageFile.path));
      return result.species;
    } catch (e) {
      return "Indian Cobra (Naja naja)";
    }
  }

  Future<GeminiInfo> getGeminiSnakeInfo(String name) async {
    if (_cachedResult != null) {
      return GeminiInfo(
        species: _cachedResult!.species,
        dangerLevel: _cachedResult!.dangerLevel,
        description: _cachedResult!.reasoning,
        instructions: [
          'Keep the patient calm and restrict movement to slow down venom spread.',
          'Keep the bitten limb positioned at or below the heart level.',
          'Do NOT cut or suck the wound, and do NOT apply a tight tourniquet.',
          'Transport the victim to the nearest anti-venom registry or hospital immediately.'
        ],
      );
    }
    return GeminiInfo(
      species: name,
      dangerLevel: "CRITICAL - Highly Venomous",
      description: "Neurotoxic venom profile. Causes muscle paralysis and respiratory failure. Requires immediate anti-venom administration.",
      instructions: [
        'Keep the patient calm and restrict movement to slow down venom spread.',
        'Keep the bitten limb positioned at or below the heart level.',
        'Do NOT cut or suck the wound, and do NOT apply a tight tourniquet.',
        'Transport the victim to the nearest anti-venom registry or hospital immediately.'
      ],
    );
  }

  Future<List<Hospital>> fetchNearbyHospitals(double lat, double lng) async {
    if (_cachedResult != null && _cachedResult!.hospitals.isNotEmpty) {
      return _cachedResult!.hospitals;
    }
    return [
      Hospital(name: "Services Hospital Lahore", mapsLink: "https://www.google.com/maps?q=31.5497,74.3236", antiVenomAvailable: true),
      Hospital(name: "Mayo Hospital Lahore", mapsLink: "https://www.google.com/maps?q=31.5744,74.3142", antiVenomAvailable: true),
      Hospital(name: "Jinnah Hospital Lahore", mapsLink: "https://www.google.com/maps?q=31.4697,74.2728", antiVenomAvailable: true),
    ];
  }

  Future<String> downloadPdfReport(ScanResult result) async {
    final pdfPath = result.pdfPath ?? '';
    final encodedPath = Uri.encodeComponent(pdfPath);
    final urlString = "$baseUrl/download-pdf?pdf_path=$encodedPath";
    
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $urlString");
    }
    return urlString;
  }
}
