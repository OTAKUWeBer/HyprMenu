import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/media_state.dart';
import '../utils/responsive.dart';

class MusicPlayerCard extends StatelessWidget {
  const MusicPlayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final media = context.watch<MediaState>();
    final s = Responsive.scale(context);

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
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF313244),
        borderRadius: BorderRadius.circular(20 * s),
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
                width: 60 * s,
                height: 60 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * s),
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
                  ? Icon(Icons.music_note, color: Colors.white24, size: 30 * s)
                  : null,
              ),
              SizedBox(width: 16 * s),
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
                        fontSize: 16 * s,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      media.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA6ADC8),
                        fontSize: 13 * s,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: media.previous,
                iconSize: 24 * s,
                icon: Icon(Icons.skip_previous, color: Colors.white, size: 24 * s),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF89B4FA),
                ),
                child: IconButton(
                  onPressed: media.playPause,
                  iconSize: 24 * s,
                  icon: Icon(media.isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFF1E1E2E), size: 24 * s),
                ),
              ),
              IconButton(
                onPressed: media.next,
                iconSize: 24 * s,
                icon: Icon(Icons.skip_next, color: Colors.white, size: 24 * s),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
