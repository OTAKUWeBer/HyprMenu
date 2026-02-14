import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/system_state.dart';
import 'wifi_dialog.dart';

class QuickSettingsGrid extends StatelessWidget {
  const QuickSettingsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = context.watch<SystemState>();
    
    return Row(
      children: [
        Expanded(
          child: AspectRatio( // Enforce square or specific ratio logic if needed, but Expanded handles width.
            aspectRatio: 1.6, // Adjust for desired shape
            child: _QuickTile(
              icon: Icons.wifi,
              label: 'Wi-Fi',
              isActive: sys.wifiEnabled,
              onTap: () => sys.toggleWifi(),
              onLongPress: () {
                 _showWifiList(context);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.6, // Same ratio to ensure equal size
            child: _QuickTile(
              icon: Icons.bluetooth,
              label: 'Bluetooth',
              isActive: sys.bluetoothEnabled,
              onTap: () => sys.toggleBluetooth(),
            ),
          ),
        ),
      ],
    );
  }

  void _showWifiList(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const WifiDialog(),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF89B4FA) : const Color(0xFF313244),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1E1E2E) : const Color(0xFFCDD6F4),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? const Color(0xFF1E1E2E) : const Color(0xFFCDD6F4),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
             if (onLongPress != null) ...[
                const SizedBox(height: 4),
                Icon(Icons.more_horiz, size: 12, color: isActive ? Colors.black26 : Colors.white24)
             ]
          ],
        ),
      ),
    );
  }
}
