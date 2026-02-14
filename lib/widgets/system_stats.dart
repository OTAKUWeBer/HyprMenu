import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';

class SystemStatsCard extends StatelessWidget {
  const SystemStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemState>();
    
    return Column(
      children: [
        _LinearStat(
          icon: Icons.memory, 
          label: 'CPU', 
          percent: sys.cpuUsage, 
          color: const Color(0xFFF38BA8),
          valueText: '${sys.cpuUsage.toInt()}%',
        ),
        const SizedBox(height: 12),
        _LinearStat(
          icon: Icons.sd_storage, // RAM icon? speed?
          label: 'RAM', 
          percent: sys.ramUsage, 
          color: const Color(0xFFF9E2AF),
          valueText: '${(sys.ramUsed / 1024 / 1024).toStringAsFixed(1)}/${(sys.ramTotal / 1024 / 1024).toStringAsFixed(1)} GiB',
        ),
        const SizedBox(height: 12),
         _LinearStat(
          icon: Icons.storage, 
          label: 'Disk', 
          percent: sys.storageUsage, 
          color: const Color(0xFFF5C2E7),
          valueText: '${sys.storageUsage.toInt()}%',
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

  const _LinearStat({
    required this.icon,
    required this.label,
    required this.percent,
    required this.color,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCDD6F4), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFF45475A),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          valueText,
          style: GoogleFonts.inter(
            color: const Color(0xFFCDD6F4),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
