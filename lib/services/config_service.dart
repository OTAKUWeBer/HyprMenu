import 'dart:convert';
import 'dart:io';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  static ConfigService get instance => _instance;

  ConfigService._internal();

  Map<String, dynamic> _config = {};

  Map<String, dynamic> get config => _config;

  Future<void> init() async {
    final home = Platform.environment['HOME'];
    if (home == null) return;

    final configDir = Directory('$home/.config/hyprmenu');
    final configFile = File('${configDir.path}/config.json');

    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }

    if (!await configFile.exists()) {
      await _createDefaultConfig(configFile);
    }

    try {
      final jsonString = await configFile.readAsString();
      _config = json.decode(jsonString);
    } catch (e) {
      // print('Error loading config: $e');
      // Fallback to defaults if load fails
      _config = _getDefaultConfig();
    }
  }

  Future<void> _createDefaultConfig(File file) async {
    final defaultConfig = _getDefaultConfig();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(defaultConfig));
  }

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'theme': {
        'primaryColor': '#F38BA8',
        'backgroundColor': '#1E1E2E',
      },
      'window': {
        'width': 400,
        'height': 1000,
      },
      'directories': [
        {'label': 'Home', 'path': '~/', 'icon': 'home'},
        {'label': 'Downloads', 'path': '~/Downloads', 'icon': 'download'},
        {'label': 'Documents', 'path': '~/Documents', 'icon': 'folder'},
        {'label': 'Pictures', 'path': '~/Pictures', 'icon': 'image'},
        {'label': 'Videos', 'path': '~/Videos', 'icon': 'movie'},
      ],
      'apps': [
        {'name': 'Browser', 'command': 'firefox', 'icon': 'firefox'},
        {'name': 'Discord', 'command': 'discord', 'icon': 'discord'},
        {'name': 'Spotify', 'command': 'spotify', 'icon': 'spotify'},
        {'name': 'Terminal', 'command': 'kitty', 'icon': 'terminal'},
      ]
    };
  }
}
