import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Reduced padding for more space
          child: Column(
            children: [
              // Top Section: Profile + Power
              SizedBox(
                height: 260, // Increased to ensure power buttons don't touch
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181825), // Mantle
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const ProfileHeader(), // Need to adjust ProfileHeader to fit centered
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181825),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const PowerActions(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Reduced gap
              
              // App Launchers
              const AppLauncherGrid(),
              const SizedBox(height: 8), // Reduced gap
              
              // Music Player
              const MusicPlayerCard(),
              const SizedBox(height: 8), // Reduced gap

              // Middle Section: Toggles + Volume
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                   color: const Color(0xFF181825),
                   borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const QuickToggles(),
                  ],
                ),
              ),
              
              const SizedBox(height: 8), // Reduced gap
              
              // Directories
              Container(
                 padding: const EdgeInsets.all(12), // Reduced padding
                 decoration: BoxDecoration(
                   color: const Color(0xFF181825),
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: const DirectoryLinks(),
              ),
              
              const SizedBox(height: 8), // Reduced gap

              // System Stats
               Container(
                 padding: const EdgeInsets.all(12), // Reduced padding
                 decoration: BoxDecoration(
                   color: const Color(0xFF181825),
                   borderRadius: BorderRadius.circular(16),
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
