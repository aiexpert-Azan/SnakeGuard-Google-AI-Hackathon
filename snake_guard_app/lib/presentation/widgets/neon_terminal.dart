import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/scan_result.dart';

class NeonTerminal extends StatelessWidget {
  final List<TraceLog> logs;

  const NeonTerminal({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Agent Trace Logs',
                style: GoogleFonts.firaCode(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            Color stepColor;
            switch (log.step) {
              case 'PLAN':
                stepColor = Colors.purpleAccent;
                break;
              case 'ACT':
                stepColor = Colors.orangeAccent;
                break;
              case 'OBSERVE':
                stepColor = Colors.greenAccent;
                break;
              default:
                stepColor = Colors.white;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '> ${log.step}',
                    style: GoogleFonts.firaCode(
                      color: stepColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      log.message,
                      style: GoogleFonts.firaCode(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: (300 * index).ms).slideX();
          }),
        ],
      ),
    );
  }
}
