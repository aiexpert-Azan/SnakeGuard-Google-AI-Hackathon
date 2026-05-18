import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/glass_card.dart';
import '../../data/services/api_service.dart';
import 'analysis_results_screen.dart';

class SnakeScanScreen extends StatefulWidget {
  const SnakeScanScreen({super.key});

  @override
  State<SnakeScanScreen> createState() => _SnakeScanScreenState();
}

class _SnakeScanScreenState extends State<SnakeScanScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selected = await _picker.pickImage(source: source);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  Future<void> _analyzeSnake() async {
    if (_imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _apiService.analyzeSnake(_imageFile!);
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultsScreen(
            scanResult: result,
            imagePath: _imageFile!.path,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Snake Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Card
              Expanded(
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_imageFile != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                             .slideY(begin: -0.1, end: 0.1, duration: 2.seconds),
                            const SizedBox(height: 16),
                            Text(
                              'Tap below to upload or take\na clear picture of the snake',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      
                      // Scanning Effect Overlay
                      if (_isAnalyzing)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: AppColors.primaryRed.withOpacity(0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: Colors.white),
                                const SizedBox(height: 16),
                                const Text(
                                  'Analyzing venom risk...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat())
                                 .shimmer(color: Colors.redAccent, duration: 1.5.seconds),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().fade().scale(delay: 200.ms),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ).animate().fade(delay: 400.ms).slideY(begin: 0.5, end: 0),

              const SizedBox(height: 24),

              // Analyze Button
              PrimaryButton(
                text: 'Analyze Snake',
                onPressed: _imageFile == null ? () {} : _analyzeSnake,
                isLoading: _isAnalyzing,
                usePulse: _imageFile != null && !_isAnalyzing,
              ).animate().fade(delay: 600.ms).slideY(begin: 0.5, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
