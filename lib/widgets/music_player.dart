import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/media_state.dart';

class MusicPlayerCard extends StatelessWidget {
  const MusicPlayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final media = context.watch<MediaState>();

    ImageProvider? imageProvider;
    if (media.artUrl.isNotEmpty) {
      if (media.artUrl.startsWith('file://')) {
        final path = media.artUrl.replaceFirst('file://', '');
        final file = File(path);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      } else {
        imageProvider = NetworkImage(media.artUrl);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF313244),
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
           colors: [Color(0xFF313244), Color(0xFF45475A)],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
        )
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black26, 
                  image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                    : null,
                ),
                child: imageProvider == null
                  ? const Icon(Icons.music_note, color: Colors.white24, size: 30)
                  : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      media.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA6ADC8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: media.previous, icon: const Icon(Icons.skip_previous, color: Colors.white)),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF89B4FA),
                ),
                child: IconButton(
                  onPressed: media.playPause,
                  icon: Icon(media.isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFF1E1E2E)),
                ),
              ),
              IconButton(onPressed: media.next, icon: const Icon(Icons.skip_next, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
