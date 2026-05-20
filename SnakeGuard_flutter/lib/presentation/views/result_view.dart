import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../data/models/scan_result.dart';
import '../../data/models/gemini_info.dart';
import '../../data/models/hospital.dart';
import '../../data/services/api_service.dart';
import '../../data/services/agent_trace.dart';
import '../widgets/glass_card.dart';
import '../widgets/hospital_card.dart';
import '../widgets/neon_terminal.dart';
import '../widgets/primary_button.dart';

class ResultView extends StatefulWidget {
  final String imagePath;
  final Uint8List imageBytes;

  const ResultView({
    super.key,
    required this.imagePath,
    required this.imageBytes,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final ApiService _apiService = ApiService();
  final AgentTrace _trace = AgentTrace();

  bool _isLoading = true;
  String? _errorMessage;

  String _species = '';
  String _dangerLevel = 'None';
  String _description = '';
  List<String> _instructions = [];
  List<Hospital> _hospitals = [];
  bool _isDownloadingPdf = false;
  final String _pdfPath = '';

  @override
  void initState() {
    super.initState();
    _trace.clear();
    _runFullClassificationFlow();
  }

  void _logEvent(String step, String message) {
    if (mounted) {
      setState(() {
        _trace.log(step, message);
      });
    }
  }

  Future<void> _runFullClassificationFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imageFile = File(widget.imagePath);

      _logEvent('PLAN', 'Initiating deep image classification flow...');
      final species = await _apiService.predictSnakeType(imageFile);

      setState(() {
        _species = species;
      });

      _logEvent('PLAN', 'Classification resolved. Identified Species: "$species". Querying Gemini database for venom profile...');
      final geminiInfo = await _apiService.getGeminiSnakeInfo(species);

      setState(() {
        _dangerLevel = geminiInfo.dangerLevel.isEmpty ? 'High' : geminiInfo.dangerLevel;
        _description = geminiInfo.description;
        _instructions = geminiInfo.instructions;
      });

      _logEvent('ACT', 'Retrieving coordinate payload via GPS hardware...');
      double lat = 31.5204;
      double lng = 74.3587;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        lat = position.latitude;
        lng = position.longitude;
        _logEvent('ACT', 'GPS lock acquired: Lat: $lat, Lng: $lng');
      } catch (e) {
        _logEvent('WARNING', 'GPS sensor offline. Falling back to local offline cache region.');
      }

      _logEvent('ACT', 'Searching spatial databases for nearest anti-venom hospitals...');
      final hospitals = await _apiService.fetchNearbyHospitals(lat, lng);

      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });

      _logEvent('OBSERVE', 'Threat analysis locked. Danger Level: ${_dangerLevel.toUpperCase()}. Nearby Hospitals loaded: ${hospitals.length}');
      _logEvent('DONE', 'FULL STACK SYNCED');
    } catch (e) {
      _logEvent('ERROR', 'Critical process failure: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
      final scanResult = ScanResult(
        species: _species,
        dangerLevel: _dangerLevel,
        hospitals: _hospitals,
        logs: _trace.logs,
        pdfPath: _pdfPath,
      );
      final String url = await _apiService.downloadPdfReport(scanResult);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF Action Plan Downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

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
    final dangerColor = _getDangerColor(_dangerLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isLoading) ...[
                  // Premium Loading Screen state with Trace log terminal in action
                  GlassCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                        ).animate(onPlay: (controller) => controller.repeat())
                         .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
                        const SizedBox(height: 24),
                        Text(
                          'Synchronizing Full-Stack Analysis...',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Resolving AI models, fetching threat descriptors, and scanning local hospital registries.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ).animate().fade().scale(),
                  const SizedBox(height: 24),
                  NeonTerminal(logs: _trace.logs),
                ] else if (_errorMessage != null) ...[
                  // Error State
                  GlassCard(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Synchronization Error',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Retry Synchronization',
                          onPressed: _runFullClassificationFlow,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeonTerminal(logs: _trace.logs),
                ] else ...[
                  // Fully loaded state
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
                                      width: double.infinity,
                                      height: 240,
                                    )
                                  : Image.file(
                                      File(widget.imagePath),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 240,
                                    ),
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
                                  _dangerLevel.toUpperCase(),
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
                              Text(
                                _species,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _description,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[800],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0),

                  if (_instructions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Emergency First Aid Instructions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._instructions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final step = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryRed,
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: (idx * 100).ms).slideX(begin: 0.1, end: 0);
                    }),
                  ],

                  if (_hospitals.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.local_hospital, color: AppColors.primaryRed),
                        const SizedBox(width: 8),
                        Text(
                          'Nearby Anti-Venom Registries',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._hospitals.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final h = entry.value;
                      return InkWell(
                        onTap: () async {
                          final Uri url = Uri.parse(h.mapsUrl);
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            debugPrint('Could not launch $url');
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: HospitalCard(
                          hospital: h,
                        ),
                      ).animate().fade(delay: (idx * 100).ms).slideX(begin: 0.1, end: 0);
                    }),
                  ],

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _isDownloadingPdf ? null : _downloadPdf,
                    icon: _isDownloadingPdf
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(_isDownloadingPdf ? 'Compiling PDF...' : 'Download First-Aid Action Plan PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: AppColors.primaryRed, width: 2),
                      foregroundColor: AppColors.primaryRed,
                    ),
                  ),

                  const SizedBox(height: 32),
                  NeonTerminal(logs: _trace.logs),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

