import 'dart:io';
import 'package:flutter/material.dart';

class PowerActions extends StatelessWidget {
  const PowerActions({super.key});

  @override
  Widget build(BuildContext context) {
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
        ),
        _PowerButton(
          icon: Icons.restart_alt,
          color: const Color(0xFFFAB387), // Orange
          onTap: () async {
            await Process.start('systemctl', ['reboot']);
            exit(0);
          },
        ),
        _PowerButton(
          icon: Icons.logout,
          color: const Color(0xFFA6E3A1), // Green
          onTap: () async {
            await Process.start('hyprctl', ['dispatch', 'exit']);
            exit(0);
          },
        ),
        _PowerButton(
          icon: Icons.lock,
          color: const Color(0xFF89DCEB), // Sky
          onTap: () => Process.start('hyprlock', []), // Or swaylock
        ),
      ],
    );
  }
}

class _PowerButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PowerButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1E1E2E), // Base
          size: 20,
        ),
      ),
    );
  }
}
