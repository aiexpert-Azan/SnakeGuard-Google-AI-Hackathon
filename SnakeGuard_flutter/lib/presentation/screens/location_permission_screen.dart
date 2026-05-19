import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/glass_card.dart';
import 'snake_scan_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLocationEnabled = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  Future<void> _enableLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permission permanently denied. Please enable in settings.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isLocationEnabled = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _startScan() {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                        Icon(
                          _isLocationEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          size: 48,
                          color: _isLocationEnabled
                              ? Colors.green
                              : AppColors.textPrimaryDark,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLocationEnabled
                              ? 'Location Access Granted'
                              : 'Location Required',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLocationEnabled
                              ? 'GPS coordinates captured. Ready to scan!'
                              : 'We need your location to find the nearest hospitals with anti-venom.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (_isLocationEnabled && _latitude != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Lat: ${_latitude!.toStringAsFixed(4)}, Lon: ${_longitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        if (!_isLocationEnabled)
                          _isLoadingLocation
                              ? const CircularProgressIndicator()
                              : PrimaryButton(
                                  text: 'Enable Location',
                                  onPressed: _enableLocation,
                                ).animate().fade(delay: 400.ms),
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
