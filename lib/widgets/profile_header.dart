import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _pickImage() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png', 'jpeg'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', file.path);
      setState(() {
        _profileImagePath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);
    
    // Attempting to get user name
    String username = Platform.environment['USER'] ?? 'User';
    String capitalized = username.isNotEmpty 
        ? username[0].toUpperCase() + username.substring(1) 
        : 'User';

    ImageProvider? imageProvider;
    if (_profileImagePath != null) {
      final file = File(_profileImagePath!);
      if (file.existsSync()) {
        imageProvider = FileImage(file);
      }
    }
    
    // Fallback if no local image or file missing
    imageProvider ??= const NetworkImage('https://ui-avatars.com/api/?name=User&background=random');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(30 * s),
            child: Container(
              width: 60 * s,
              height: 60 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF45475A), // Surface1
                border: Border.all(color: const Color(0xFF89B4FA), width: 2 * s),
                image: DecorationImage(
                   image: imageProvider,
                   fit: BoxFit.cover,
                   onError: (exception, stackTrace) {}, 
                ),
              ),
              child: null,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            capitalized,
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          // Optional: Wifi/Battery status icon row here if needed
        ],
      ),
    );
  }
}
