import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/profile_header.dart';
import '../widgets/power_actions.dart';
import '../widgets/app_launchers.dart';
import '../widgets/music_player.dart';
import '../widgets/quick_toggles.dart';

import '../widgets/directory_links.dart';
import '../widgets/system_stats.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0 * s),
          child: Column(
            children: [
              // Top Section: Profile + Power
              SizedBox(
                height: 260 * s,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(16 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181825), // Mantle
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: const ProfileHeader(),
                      ),
                    ),
                    SizedBox(width: 16 * s),
                    Container(
                      width: 80 * s,
                      padding: EdgeInsets.symmetric(vertical: 16 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181825),
                        borderRadius: BorderRadius.circular(16 * s),
                      ),
                      child: const PowerActions(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * s),
              
              // App Launchers
              const AppLauncherGrid(),
              SizedBox(height: 8 * s),
              
              // Music Player
              const MusicPlayerCard(),
              SizedBox(height: 8 * s),

              // Middle Section: Toggles + Volume
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                   color: const Color(0xFF181825),
                   borderRadius: BorderRadius.circular(16 * s),
                ),
                child: const Column(
                  children: [
                    QuickToggles(),
                  ],
                ),
              ),
              
              SizedBox(height: 8 * s),
              
              // Directories
              Container(
                 padding: EdgeInsets.all(12 * s),
                 decoration: BoxDecoration(
                   color: const Color(0xFF181825),
                   borderRadius: BorderRadius.circular(16 * s),
                 ),
                 child: const DirectoryLinks(),
              ),
              
              SizedBox(height: 8 * s),

              // System Stats
               Container(
                 padding: EdgeInsets.all(12 * s),
                 decoration: BoxDecoration(
                   color: const Color(0xFF181825),
                   borderRadius: BorderRadius.circular(16 * s),
                 ),
                 child: const SystemStatsCard(),
               ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
