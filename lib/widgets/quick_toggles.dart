import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';
import '../utils/responsive.dart';
import 'wifi_dialog.dart';

class QuickToggles extends StatelessWidget {
  const QuickToggles({super.key});

  static const _base = Color(0xFF1E1E2E);
  static const _surface1 = Color(0xFF45475A);

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemState>();
    final s = Responsive.scale(context);
    final wifiActive = context.select<SystemState, bool>((s) => s.wifiEnabled);
    const wifiColor = Color(0xFFCBA6F7); // Mauve

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── WiFi: two-part button (toggle + expand arrow) ──
          Container(
            height: 50 * s,
            decoration: BoxDecoration(
              color: wifiActive ? wifiColor : _surface1,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left: toggle WiFi on/off
                InkWell(
                  onTap: sys.toggleWifi,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12 * s),
                  ),
                  child: SizedBox(
                    width: 46 * s,
                    height: 50 * s,
                    child: Icon(Icons.wifi, color: _base, size: 24 * s),
                  ),
                ),
                // Divider line
                Container(
                  width: 1,
                  height: 26 * s,
                  color: _base.withValues(alpha: 0.2),
                ),
                // Right: open WiFi dialog
                InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const WifiDialog(),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(12 * s),
                  ),
                  child: SizedBox(
                    width: 28 * s,
                    height: 50 * s,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: _base,
                      size: 18 * s,
                    ),
                  ),
                ),
              ],
            ),
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
  final Color color;
  final double scale;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
