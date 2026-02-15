import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:provider/provider.dart';
import 'providers/system_state.dart';
import 'providers/media_state.dart';
import 'theme/app_theme.dart';
import 'services/config_service.dart';
import 'screens/menu_screen.dart';

// --- Main Entry ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize configuration
  await ConfigService.instance.init();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Attempt to size and position dynamically based on screen
    try {
      final screenList = await getScreenList();
      if (screenList.isNotEmpty) {
        final screen = screenList.first;
        final frame = screen.visibleFrame;
        
        // Scale window to screen: ~21% width, ~85% height
        final width = (frame.width * 0.21).clamp(320.0, 500.0);
        final height = (frame.height * 0.85).clamp(600.0, 1200.0);
        
        setWindowMinSize(Size(width, height));
        setWindowMaxSize(Size(width, height));
        
        // Position top-right, with some padding
        final left = frame.width - width - 10;
        const top = 10.0;
        setWindowFrame(Rect.fromLTWH(left, top, width, height));
      } else {
        debugPrint("No screens found, defaulting frame");
        setWindowMinSize(const Size(320, 600));
        setWindowMaxSize(const Size(400, 800));
        setWindowFrame(const Rect.fromLTWH(10, 10, 400, 800));
      }
    } catch (e) {
      debugPrint("Failed to get screen info: $e");
      setWindowMinSize(const Size(320, 600));
      setWindowMaxSize(const Size(400, 800));
      setWindowFrame(const Rect.fromLTWH(10, 10, 400, 800));
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SystemState()),
        ChangeNotifierProvider(create: (_) => MediaState()),
      ],
      child: const HyprMenuApp(),
    ),
  );
}

// --- App Widget ---
class HyprMenuApp extends StatelessWidget {
  const HyprMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MenuScreen(),
    );
  }
}