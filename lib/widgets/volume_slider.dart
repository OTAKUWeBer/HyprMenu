import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';

class VolumeSlider extends StatelessWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemState>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF313244),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
             sys.volumeLevel == 0 ? Icons.volume_off : Icons.volume_up,
             color: const Color(0xFFA6ADC8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFFF5C2E7),
                inactiveTrackColor: const Color(0xFF45475A),
                thumbColor: const Color(0xFFF5C2E7),
                overlayColor: const Color(0x29F5C2E7),
                trackHeight: 4,
              ),
              child: Slider(
                value: sys.volumeLevel.toDouble(),
                max: 100,
                onChanged: (v) => sys.setVolume(v.toInt()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${sys.volumeLevel}%',
            style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
