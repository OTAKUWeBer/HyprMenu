import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/config_service.dart';
import '../utils/responsive.dart';

class AppLauncherGrid extends StatelessWidget {
  const AppLauncherGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final apps = ConfigService.instance.config['apps'] as List<dynamic>? ?? [];
    final s = Responsive.scale(context);

    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12 * s,
      crossAxisSpacing: 12 * s,
      children: apps.map((app) {
        return _AppTile(
          icon: _getIcon(app['icon'], app['name']),
          color: const Color(0xFF89B4FA),
          cmd: app['command'],
          tooltip: app['name'],
          scale: s,
        );
      }).toList(),
    );
  }

  IconData _getIcon(String iconName, String? appName) {
    // Legacy fix: If config says 'chat' but app is Discord, use Discord icon
    if (iconName == 'chat' && appName?.toLowerCase() == 'discord') {
      return FontAwesomeIcons.discord;
    }
    
    switch (iconName.toLowerCase()) {
      case 'web': return Icons.public;
      case 'firefox': return FontAwesomeIcons.firefox;
      case 'browser': return Icons.public;
      case 'chat': return Icons.chat;
      case 'discord': return FontAwesomeIcons.discord;
      case 'spotify': return FontAwesomeIcons.spotify;
      case 'music_note': return Icons.music_note;
      case 'terminal': return FontAwesomeIcons.terminal;
      case 'kitty': return FontAwesomeIcons.cat; 
      case 'search': return Icons.search;
      case 'code': return Icons.code; 
      default: return Icons.apps;
    }
  }
}

class _AppTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String cmd;
  final String tooltip;
  final double scale;

  const _AppTile({
    required this.icon,
    required this.color,
    required this.cmd,
    required this.tooltip,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          Process.run('bash', ['-c', '$cmd &']);
        },
        borderRadius: BorderRadius.circular(10 * scale),
        child: Container(
          padding: EdgeInsets.all(6 * scale),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E1E2E),
            size: 22 * scale,
          ),
        ),
      ),
    );
  }
}
