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
    // New larger size
    setWindowMinSize(const Size(400, 910));
    setWindowMaxSize(const Size(400, 910));
    
    // Attempt to position on the right side
    try {
      final screenList = await getScreenList();
      if (screenList.isNotEmpty) {
        final screen = screenList.first; // Primary screen usually
        final frame = screen.visibleFrame;
        // Position top-right, with some padding
        const width = 400.0;
        const height = 800.0;
        final left = frame.width - width - 10; // 10px padding from right
        final top = 10.0; // 10px padding from top
        setWindowFrame(Rect.fromLTWH(left, top, width, height));
      } else {
         debugPrint("No screens found, defaulting frame");
         setWindowFrame(const Rect.fromLTWH(1500, 10, 400, 800));
      }
    } catch (e) {
      debugPrint("Failed to get screen info: $e");
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