import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';
import 'wifi_dialog.dart';

class QuickToggles extends StatelessWidget {
  const QuickToggles({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes so icons update!
    final sys = context.watch<SystemState>();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ToggleButton(
            icon: Icons.wifi,
            isActive: context.select<SystemState, bool>((s) => s.wifiEnabled),
            onTap: sys.toggleWifi,
            onLongPress: () => showDialog(context: context, builder: (_) => const WifiDialog()),
            color: const Color(0xFFCBA6F7), // Mauve
          ),
          _ToggleButton(
            icon: Icons.bluetooth,
            isActive: context.select<SystemState, bool>((s) => s.bluetoothEnabled),
            onTap: sys.toggleBluetooth,
             color: const Color(0xFF89B4FA), // Blue
          ),
          _ToggleButton( // DND / Notifications
            icon: sys.dndEnabled ? Icons.notifications_off : Icons.notifications_active,
            isActive: sys.dndEnabled, 
            onTap: sys.toggleDnd, 
            color: const Color(0xFFF9E2AF), // Yellow
          ),
          _ToggleButton( // Mute Speaker
            icon: sys.speakerMuted ? Icons.volume_off : Icons.volume_up, 
            isActive: !sys.speakerMuted, 
             color: const Color(0xFFF38BA8), // Red
            onTap: sys.toggleSpeaker,
          ),
          _ToggleButton( // Mute Mic
            icon: sys.micMuted ? Icons.mic_off : Icons.mic,
            isActive: !sys.micMuted, // Active = Mic ON (not muted) usually. Or if user wants to see "Muted" state?
            // User asked: "if i mute ... the icon doesnt change to see if its on or off"
            // Usually toggle active state implies "FEATURE IS ON".
            // If Mic is ON -> Active (Color). If Muted -> Inactive (Grey)?
            // Or If Mute Toggle -> Active means MUTED?
            // Let's assume Active = Enabled (Mic On).
            // So isActive = !sys.micMuted.
            color: const Color(0xFFF5C2E7), // Pink
            onTap: sys.toggleMic,
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

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.color,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // If active, show color. If not, show dark grey.
    // Dashboard style often keeps them colored but dimmed?
    // Let's go with: Colored background if 'active/available', maybe greyed out if off? 
    // Or just always colored buttons for actions.
    // The user screenshot showed colored squares.
    
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? color : const Color(0xFF45475A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1E1E2E),
          size: 24,
        ),
      ),
    );
  }
}
