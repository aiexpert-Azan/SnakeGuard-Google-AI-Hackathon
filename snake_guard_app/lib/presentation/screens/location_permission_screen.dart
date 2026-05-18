import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/glass_card.dart';
import 'snake_scan_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLocationEnabled = false;
  String? _selectedCity;
  final List<String> _cities = ['Lahore', 'Karachi', 'Islamabad', 'Multan'];

  void _enableLocation() {
    setState(() {
      _isLocationEnabled = true;
    });
  }

  void _startScan() {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city first')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SnakeScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed.withOpacity(0.2),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Section
                  const Spacer(),
                  Icon(
                    Icons.emergency,
                    size: 80,
                    color: AppColors.primaryRed,
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .shimmer(color: Colors.white, duration: 2.seconds)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
                  const SizedBox(height: 24),
                  Text(
                    'SnakeGuard AI',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primaryRed,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade().slideY(begin: 0.5, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    'AI-powered emergency snake detection\n& hospital assistance',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.5, end: 0),
                  
                  const Spacer(),

                  // Middle Section (Location Card)
                  GlassCard(
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, size: 48, color: AppColors.textPrimaryDark),
                        const SizedBox(height: 16),
                        Text(
                          _isLocationEnabled ? 'Location Access Granted' : 'Location Required',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLocationEnabled 
                            ? 'Please select your nearest city to find hospitals.'
                            : 'We need your location to find the nearest hospitals with anti-venom.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        if (!_isLocationEnabled)
                          PrimaryButton(
                            text: 'Enable Location',
                            onPressed: _enableLocation,
                          ).animate().fade(delay: 400.ms),
                        if (_isLocationEnabled)
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select City',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            value: _selectedCity,
                            items: _cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            },
                          ).animate().fade().scale(),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const Spacer(flex: 2),

                  // Bottom Section
                  AnimatedOpacity(
                    opacity: _isLocationEnabled ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: PrimaryButton(
                      text: 'Start Emergency Scan',
                      onPressed: _isLocationEnabled ? _startScan : () {},
                      usePulse: _isLocationEnabled,
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.5, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
