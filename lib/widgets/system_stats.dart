import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';
import '../utils/responsive.dart';

class SystemStatsCard extends StatelessWidget {
  const SystemStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemState>();
    final s = Responsive.scale(context);
    
    return Column(
      children: [
        _LinearStat(
          icon: Icons.memory, 
          label: 'CPU', 
          percent: sys.cpuUsage, 
          color: const Color(0xFFF38BA8),
          valueText: '${sys.cpuUsage.toInt()}%',
          scale: s,
        ),
        SizedBox(height: 12 * s),
        _LinearStat(
          icon: Icons.sd_storage,
          label: 'RAM', 
          percent: sys.ramUsage, 
          color: const Color(0xFFF9E2AF),
          valueText: '${(sys.ramUsed / 1024 / 1024).toStringAsFixed(1)}/${(sys.ramTotal / 1024 / 1024).toStringAsFixed(1)} GiB',
          scale: s,
        ),
        SizedBox(height: 12 * s),
         _LinearStat(
          icon: Icons.storage, 
          label: 'Disk', 
          percent: sys.storageUsage, 
          color: const Color(0xFFF5C2E7),
          valueText: '${sys.storageUsage.toInt()}%',
          scale: s,
        ),
      ],
    );
  }
}

class _LinearStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double percent;
  final Color color;
  final String valueText;
  final double scale;

  const _LinearStat({
    required this.icon,
    required this.label,
    required this.percent,
    required this.color,
    required this.valueText,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCDD6F4), size: 20 * scale),
        SizedBox(width: 12 * scale),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4 * scale),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8 * scale,
              backgroundColor: const Color(0xFF45475A),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        SizedBox(width: 12 * scale),
        Text(
          valueText,
          style: GoogleFonts.inter(
            color: const Color(0xFFCDD6F4),
            fontSize: 12 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
