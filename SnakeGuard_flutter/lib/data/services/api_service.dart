import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  Future<ScanResult> analyzeSnake(XFile image) async {
    final uri = Uri.parse('$baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);
    final Uint8List bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: image.name,
      contentType: MediaType('image', 'jpeg'),
    ));
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        debugPrint('FULL RESPONSE: ${response.body}');

        // Extract nested fields
        final assessment = json['assessment'] ?? {};
        final analysis = assessment['analysis'] ?? {};
        final emergencyInfo = assessment['emergency_info'] ?? {};

        final species = analysis['species'] ?? '';
        final dangerLevel = analysis['danger_level'] ?? '';
        final description = analysis['reasoning'] ?? '';

        // pdf_path is at TOP LEVEL of response
        final pdfPath = (json['pdf_path'] as String?) ?? '';
        debugPrint('PARSED pdf_path: $pdfPath');

        final hospitals = (emergencyInfo['hospitals'] as List?)
                ?.map((e) => Hospital.fromJson(e))
                .toList() ??
            [];

        // logs are at TOP LEVEL of response
        final logs = (json['logs'] as List?)
                ?.map((e) => TraceLog.fromJson(e))
                .toList() ??
            [];
        debugPrint('PARSED logs count: ${logs.length}');

        return ScanResult(
          species: species,
          dangerLevel: dangerLevel,
          description: description,
          hospitals: hospitals,
          traceLogs: logs,
          pdfPath: pdfPath,
        );
      } else {
        throw Exception(
            'Failed to analyze snake. Status Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

  Future<String> downloadPdfReport(ScanResult result) async {
    final encodedPath = Uri.encodeComponent(result.pdfPath ?? '');
    final url = '$baseUrl/download-pdf?pdf_path=$encodedPath';
    debugPrint('PDF download URL: $url');
    if (kIsWeb) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final pdfBytes = response.bodyBytes;
          final blob = html.Blob([pdfBytes], 'application/pdf');
          final objectUrl = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: objectUrl)
            ..setAttribute('download', 'emergency_report.pdf')
            ..click();
          html.Url.revokeObjectUrl(objectUrl);
        } else {
          debugPrint('Failed to download PDF: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error downloading PDF: $e');
      }
    }
    return url;
  }
}
