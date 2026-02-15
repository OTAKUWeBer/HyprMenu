import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';
import '../utils/responsive.dart';
import 'wifi_dialog.dart';

class QuickToggles extends StatelessWidget {
  const QuickToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemState>();
    final s = Responsive.scale(context);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ToggleButton(
            icon: Icons.wifi,
            isActive: context.select<SystemState, bool>((s) => s.wifiEnabled),
            onTap: sys.toggleWifi,
            onLongPress: () => showDialog(context: context, builder: (_) => const WifiDialog()),
            color: const Color(0xFFCBA6F7), // Mauve
            scale: s,
          ),
          _ToggleButton(
            icon: Icons.bluetooth,
            isActive: context.select<SystemState, bool>((s) => s.bluetoothEnabled),
            onTap: sys.toggleBluetooth,
            color: const Color(0xFF89B4FA), // Blue
            scale: s,
          ),
          _ToggleButton(
            icon: sys.dndEnabled ? Icons.notifications_off : Icons.notifications_active,
            isActive: sys.dndEnabled, 
            onTap: sys.toggleDnd, 
            color: const Color(0xFFF9E2AF), // Yellow
            scale: s,
          ),
          _ToggleButton(
            icon: sys.speakerMuted ? Icons.volume_off : Icons.volume_up, 
            isActive: !sys.speakerMuted, 
            color: const Color(0xFFF38BA8), // Red
            onTap: sys.toggleSpeaker,
            scale: s,
          ),
          _ToggleButton(
            icon: sys.micMuted ? Icons.mic_off : Icons.mic,
            isActive: !sys.micMuted,
            color: const Color(0xFFF5C2E7), // Pink
            onTap: sys.toggleMic,
            scale: s,
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color color;
  final double scale;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.color,
    required this.scale,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Container(
        width: 50 * scale,
        height: 50 * scale,
        decoration: BoxDecoration(
          color: isActive ? color : const Color(0xFF45475A),
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1E1E2E),
          size: 24 * scale,
        ),
      ),
    );
  }
}
