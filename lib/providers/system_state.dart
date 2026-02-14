import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

class SystemState extends ChangeNotifier {
  bool wifiEnabled = false;
  bool bluetoothEnabled = false;
  bool micMuted = false;
  bool speakerMuted = false;
  bool dndEnabled = false; // Mako do-not-disturb mode
  int volumeLevel = 50;
  double cpuUsage = 0.0;
  double ramUsage = 0.0;
  int ramTotal = 0; // in kB
  int ramUsed = 0;  // in kB
  double storageUsage = 0.0;
  Timer? _timer;

  bool _isUpdating = false;

  SystemState() {
    _init();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _updateStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    await checkWifi();
    await checkBluetooth();
    await checkVolume();
    await checkSpeaker();
    await checkMic();
    await checkDnd();
    await _updateStats();
  }

  Future<void> _updateStats() async {
    if (_isUpdating) return;
    _isUpdating = true;
    try {
      await _updateCpu();
      await _updateRam();
      await _updateStorage();
      notifyListeners();
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> checkWifi() async {
    try {
      final result = await Process.run('nmcli', ['radio', 'wifi']);
      wifiEnabled = result.stdout.toString().trim() == 'enabled';
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleWifi() async {
    try {
      await Process.run('nmcli', ['radio', 'wifi', wifiEnabled ? 'off' : 'on']);
      await checkWifi();
    } catch (_) {}
  }

  Future<void> checkBluetooth() async {
      // Simplistic check
      try {
        final result = await Process.run('bluetoothctl', ['show']);
        bluetoothEnabled = result.stdout.toString().contains('Powered: yes');
        notifyListeners();
      } catch (_) {}
  }

  Future<void> toggleBluetooth() async {
    try {
      await Process.run('bluetoothctl', ['power', bluetoothEnabled ? 'off' : 'on']);
      await checkBluetooth();
    } catch (_) {}
  }

  Future<void> checkVolume() async {
    try {
      final result = await Process.run('pactl', ['get-sink-volume', '@DEFAULT_SINK@']);
      final match = RegExp(r'(\d+)%').firstMatch(result.stdout.toString());
      if (match != null) {
        volumeLevel = int.parse(match.group(1)!);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setVolume(int level) async {
    try {
      await Process.run('pactl', ['set-sink-volume', '@DEFAULT_SINK@', '$level%']);
      volumeLevel = level;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> checkSpeaker() async {
    try {
      final result = await Process.run('pactl', ['get-sink-mute', '@DEFAULT_SINK@']);
      speakerMuted = result.stdout.toString().contains('yes'); // "Mute: yes"
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleSpeaker() async {
    try {
      await Process.run('pactl', ['set-sink-mute', '@DEFAULT_SINK@', 'toggle']);
      await checkSpeaker();
    } catch (_) {}
  }

  Future<void> checkMic() async {
    try {
      final result = await Process.run('pactl', ['get-source-mute', '@DEFAULT_SOURCE@']);
      micMuted = result.stdout.toString().contains('yes'); // "Mute: yes"
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleMic() async {
    try {
      await Process.run('pactl', ['set-source-mute', '@DEFAULT_SOURCE@', 'toggle']);
      await checkMic();
    } catch (_) {}
  }

  Future<void> checkDnd() async {
    try {
      // Check if 'do-not-disturb' mode is active in Mako
      final result = await Process.run('makoctl', ['mode']);
      final modes = result.stdout.toString().split('\n');
      dndEnabled = modes.contains('do-not-disturb');
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleDnd() async {
    try {
      if (dndEnabled) {
         await Process.run('makoctl', ['mode', '-r', 'do-not-disturb']);
      } else {
         await Process.run('makoctl', ['mode', '-a', 'do-not-disturb']);
      }
      await checkDnd();
    } catch (_) {}
  }

  Future<void> _updateCpu() async {
    try {
      final result = await Process.run('bash', ['-c', "top -bn2 -d 0.5 | grep '^%Cpu' | tail -n1 | awk '{print \$2}'"]);
      cpuUsage = double.tryParse(result.stdout.toString().trim()) ?? 0.0;
    } catch (_) {}
  }

  Future<void> _updateRam() async {
    try {
      final file = File('/proc/meminfo');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        int total = 0;
        int available = 0;

        for (final line in lines) {
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length < 2) continue;
          
          if (line.startsWith('MemTotal:')) {
            total = int.tryParse(parts[1]) ?? 0;
          } else if (line.startsWith('MemAvailable:')) {
            available = int.tryParse(parts[1]) ?? 0;
          }
        }

        if (total > 0) {
          ramTotal = total;
          ramUsed = total - available;
          ramUsage = (ramUsed / total) * 100;
        }
      }
    } catch (_) {}
  }

  Future<void> _updateStorage() async {
    try {
      final result = await Process.run('bash', ['-c', "df -h / | tail -n1 | awk '{print \$5}' | sed 's/%//'"]);
      storageUsage = double.tryParse(result.stdout.toString().trim()) ?? 0.0;
    } catch (_) {}
  }
}
