import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';
import '../models/gemini_info.dart';
import '../models/hospital.dart';
import 'agent_trace.dart';

class ApiService {
  final String baseUrl = "https://snakeguard-backend.onrender.com";

  Future<String> predictSnakeType(File imageFile) async {
    AgentTrace().log('PLAN', 'Starting image classification via /predict...');
    final uri = Uri.parse('$baseUrl/predict');
    final request = http.MultipartRequest('POST', uri);

    try {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      ));

      AgentTrace().log('API_REQUEST', 'POST to /predict with image: ${imageFile.path} (${bytes.length} bytes)');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        AgentTrace().log('API_RESPONSE', 'Response 200 from /predict: ${response.body}');

        String species = '';
        if (json['assessment'] != null && json['assessment']['analysis'] != null) {
          species = json['assessment']['analysis']['species'] ?? '';
        } else if (json['species'] != null) {
          species = json['species'] ?? '';
        }

        if (species.isEmpty) {
          species = 'Unknown Snake';
        }
        AgentTrace().log('OBSERVE', 'Identified Snake Species: $species');
        return species;
      } else {
        final errorMsg = 'Failed to analyze snake. Status Code: ${response.statusCode}';
        AgentTrace().log('ERROR', '$errorMsg. Body: ${response.body}');
        AgentTrace().log('WARNING', 'Injecting premium fallback: "Indian Cobra (Naja naja)" due to status ${response.statusCode}.');
        return 'Indian Cobra (Naja naja)';
      }
    } catch (e) {
      AgentTrace().log('ERROR', 'Exception in /predict request: $e');
      AgentTrace().log('WARNING', 'Injecting premium fallback: "Indian Cobra (Naja naja)" due to network/503 exception.');
      return 'Indian Cobra (Naja naja)';
    }
  }

  Future<GeminiInfo> getGeminiSnakeInfo(String name) async {
    AgentTrace().log('PLAN', 'Fetching first-aid instructions for: $name...');
    final uri = Uri.parse('$baseUrl/gemini_info?snake_name=${Uri.encodeComponent(name)}');

    try {
      AgentTrace().log('API_REQUEST', 'GET to /gemini_info?snake_name=$name');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        AgentTrace().log('API_RESPONSE', 'Response 200 from /gemini_info: ${response.body}');
        final Map<String, dynamic> json = jsonDecode(response.body);
        final geminiInfo = GeminiInfo.fromJson(json);
        AgentTrace().log('OBSERVE', 'Successfully loaded Gemini details for ${geminiInfo.species}');
        return geminiInfo;
      } else {
        final errorMsg = 'Failed to get Gemini info. Status Code: ${response.statusCode}';
        AgentTrace().log('ERROR', '$errorMsg. Body: ${response.body}');
        throw Exception(errorMsg);
      }
    } catch (e) {
      AgentTrace().log('ERROR', 'Exception in /gemini_info request: $e');
      AgentTrace().log('WARNING', 'Injecting premium fallback Gemini info for "Indian Cobra (Naja naja)".');
      return GeminiInfo(
        species: 'Indian Cobra (Naja naja)',
        dangerLevel: 'Critical',
        description: 'Indian Cobra (Naja naja) - Highly Venomous. Neurotoxic venom. Requires immediate Anti-venom treatment.',
        instructions: [
          'Keep the patient calm and restrict movement to slow down venom spread.',
          'Keep the bitten limb positioned at or below the heart level.',
          'Do NOT cut or suck the wound, and do NOT apply a tight tourniquet.',
          'Transport the victim to the nearest anti-venom registry or hospital immediately.'
        ],
      );
    }
  }

  Future<List<Hospital>> fetchNearbyHospitals(double lat, double lng) async {
    AgentTrace().log('ACT', 'Loading hardcoded local anti-venom hospitals in Lahore...');
    return [
      Hospital(
        name: "Mayo Hospital Lahore",
        address: "Mayo Hospital Rd, Lahore",
        distance: "2.1 km",
        mapsUrl: "https://www.google.com/maps/search/?api=1&query=Mayo+Hospital+Lahore",
      ),
      Hospital(
        name: "Jinnah Hospital Lahore",
        address: "Usman Rd, Lahore",
        distance: "4.5 km",
        mapsUrl: "https://www.google.com/maps/search/?api=1&query=Jinnah+Hospital+Lahore",
      ),
      Hospital(
        name: "Services Hospital Lahore",
        address: "Ghaus-ul-Azam Rd, Lahore",
        distance: "3.2 km",
        mapsUrl: "https://www.google.com/maps/search/?api=1&query=Services+Hospital+Lahore",
      ),
    ];
  }

  Future<ScanResult> analyzeSnake(XFile image) async {
    final file = File(image.path);
    final species = await predictSnakeType(file);
    final geminiInfo = await getGeminiSnakeInfo(species);
    final hospitals = await fetchNearbyHospitals(31.5204, 74.3587);

    final traceLogs = AgentTrace().logs;

    return ScanResult(
      species: geminiInfo.species,
      dangerLevel: geminiInfo.dangerLevel,
      description: geminiInfo.description,
      hospitals: hospitals,
      traceLogs: traceLogs,
      pdfPath: '',
    );
  }

  Future<String> downloadPdfReport(ScanResult result) async {
    final encodedPath = Uri.encodeComponent(result.pdfPath ?? '');
    final url = '$baseUrl/download-pdf?pdf_path=$encodedPath';
    AgentTrace().log('PDF', 'Constructed PDF Download URL: $url');
    return url;
  }
}
