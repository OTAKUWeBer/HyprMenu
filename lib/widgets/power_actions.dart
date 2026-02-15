import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class PowerActions extends StatelessWidget {
  const PowerActions({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _PowerButton(
          icon: Icons.power_settings_new,
          color: const Color(0xFFF38BA8), // Red
          onTap: () async {
            await Process.start('systemctl', ['poweroff']);
            exit(0);
          },
          scale: s,
        ),
        _PowerButton(
          icon: Icons.restart_alt,
          color: const Color(0xFFFAB387), // Orange
          onTap: () async {
            await Process.start('systemctl', ['reboot']);
            exit(0);
          },
          scale: s,
        ),
        _PowerButton(
          icon: Icons.logout,
          color: const Color(0xFFA6E3A1), // Green
          onTap: () async {
            await Process.start('hyprctl', ['dispatch', 'exit']);
            exit(0);
          },
          scale: s,
        ),
        _PowerButton(
          icon: Icons.lock,
          color: const Color(0xFF89DCEB), // Sky
          onTap: () => Process.start('hyprlock', []), // Or swaylock
          scale: s,
        ),
      ],
    );
  }
}

class _PowerButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double scale;

  const _PowerButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Container(
        width: 40 * scale,
        height: 40 * scale,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1E1E2E), // Base
          size: 20 * scale,
        ),
      ),
    );
  }
}
