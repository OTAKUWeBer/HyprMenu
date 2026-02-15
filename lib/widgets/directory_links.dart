import 'dart:io';
import '../services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class DirectoryLinks extends StatelessWidget {
  const DirectoryLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final directories = ConfigService.instance.config['directories'] as List<dynamic>? ?? [];
    final s = Responsive.scale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8 * s,
            crossAxisSpacing: 8 * s,
            childAspectRatio: 4,
          ),
          itemCount: directories.length,
          itemBuilder: (context, index) {
            final dir = directories[index];
            final colors = [
              const Color(0xFFF5C2E7), // Pink
              const Color(0xFFA6E3A1), // Green
              const Color(0xFFF9E2AF), // Yellow
              const Color(0xFFCBA6F7), // Mauve
              const Color(0xFFF38BA8), // Red
              const Color(0xFF89B4FA), // Blue
            ];
            final color = colors[index % colors.length];

            return _DirLink(
              icon: _getIcon(dir['icon']),
              label: dir['label'],
              path: dir['path'],
              color: color,
              scale: s,
            );
          },
        ),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'home': return Icons.home;
      case 'download': return Icons.download;
      case 'folder': return Icons.folder;
      case 'image': return Icons.image;
      case 'movie': return Icons.movie;
      case 'music_note': return Icons.music_note;
      case 'insert_drive_file': return Icons.insert_drive_file;
      case 'article': return Icons.article;
      case 'code': return Icons.code;
      default: return Icons.folder;
    }
  }
}

class _DirLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final Color color;
  final double scale;

  const _DirLink({
    required this.icon,
    required this.label,
    required this.path,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String expandedPath = path.replaceAll('~', Platform.environment['HOME'] ?? '');
        Process.run('xdg-open', [expandedPath]);
      },
      borderRadius: BorderRadius.circular(8 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20 * scale),
            SizedBox(width: 8 * scale),
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFFCDD6F4),
                fontWeight: FontWeight.w600,
                fontSize: 14 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
