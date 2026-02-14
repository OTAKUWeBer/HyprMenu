import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

class MediaState extends ChangeNotifier {
  String title = 'No Media';
  String artist = 'Unknown Artist';
  String artUrl = '';
  bool isPlaying = false;
  Timer? _timer;

  MediaState() {
    _updateMedia();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateMedia());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateMedia() async {
    try {
      // Check status
      final statusRes = await Process.run('playerctl', ['status']);
      final status = statusRes.stdout.toString().trim().toLowerCase();
      isPlaying = status == 'playing';

      if (status.isEmpty || status == 'stopped') {
        title = 'Not Playing';
        artist = '';
        artUrl = '';
        notifyListeners();
        return;
      }

      final metadataRes = await Process.run('playerctl', ['metadata', '--format', '{{title}}||{{artist}}||{{mpris:artUrl}}']);
      final parts = metadataRes.stdout.toString().trim().split('||');
      if (parts.length >= 2) {
        title = parts[0].isEmpty ? 'Unknown Title' : parts[0];
        artist = parts[1].isEmpty ? 'Unknown Artist' : parts[1];
        artUrl = parts.length > 2 ? parts[2] : '';
        notifyListeners();
      }
    } catch (_) {
       // playerctl might not be installed or no players found
       title = 'No Player';
       artist = '';
       notifyListeners();
    }
  }

  Future<void> playPause() async => await Process.run('playerctl', ['play-pause']);
  Future<void> next() async => await Process.run('playerctl', ['next']);
  Future<void> previous() async => await Process.run('playerctl', ['previous']);
}
