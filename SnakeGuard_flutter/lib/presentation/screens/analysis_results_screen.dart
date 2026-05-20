import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../data/models/scan_result.dart';
import '../../data/services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/hospital_card.dart';
import '../widgets/neon_terminal.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final ScanResult scanResult;
  final String imagePath;
  final Uint8List imageBytes;
  final File? imageFile;

  const AnalysisResultsScreen({
    super.key,
    required this.scanResult,
    required this.imagePath,
    required this.imageBytes,
    this.imageFile,
  });

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  bool _isDownloadingPdf = false;
  final ApiService _apiService = ApiService();

  Color _getDangerColor(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
        return AppColors.statusCritical;
      case 'moderate':
        return AppColors.statusModerate;
      case 'low':
        return AppColors.statusLow;
      default:
        return AppColors.statusCritical;
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloadingPdf = true);
    
    try {
      debugPrint('pdfPath before download: ${widget.scanResult.pdfPath}');
      if (widget.scanResult.pdfPath == null || widget.scanResult.pdfPath!.isEmpty) {
        throw Exception('PDF path is empty. The backend may not have returned a pdf_path.');
      }
      final String url = await _apiService.downloadPdfReport(widget.scanResult);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF Report Downloaded Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Open the PDF in browser
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dangerColor = _getDangerColor(widget.scanResult.dangerLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AI Result Card
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: widget.imageBytes.isNotEmpty
                                ? Image.memory(
                                    widget.imageBytes,
                                    fit: BoxFit.cover,
                                  )
                                : widget.imageFile != null
                                    ? Image.file(
                                        widget.imageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: dangerColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: dangerColor.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.scanResult.dangerLevel.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.scanResult.species,
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '98% Match',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.scanResult.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 32),

              // Hospitals Section
              Row(
                children: [
                  const Icon(Icons.local_hospital, color: AppColors.primaryRed),
                  const SizedBox(width: 8),
                  Text(
                    'Nearby Hospitals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 16),
              ...widget.scanResult.hospitals.asMap().entries.map((entry) {
                return HospitalCard(hospital: entry.value)
                    .animate()
                    .fade(delay: (300 + (entry.key * 100)).ms)
                    .slideX(begin: 0.2, end: 0);
              }),

              const SizedBox(height: 24),

              // PDF Download Button
              OutlinedButton.icon(
                onPressed: _isDownloadingPdf ? null : _downloadPdf,
                icon: _isDownloadingPdf 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isDownloadingPdf ? 'Downloading...' : 'Download Emergency PDF Report'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.primaryRed, width: 2),
                  foregroundColor: AppColors.primaryRed,
                ),
              ).animate().fade(delay: 600.ms),

              const SizedBox(height: 32),

              // Agent Trace Logs Section
              NeonTerminal(logs: widget.scanResult.traceLogs)
                  .animate()
                  .fade(delay: 800.ms)
                  .slideY(begin: 0.2, end: 0),
                  
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
