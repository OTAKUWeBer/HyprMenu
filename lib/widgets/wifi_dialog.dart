import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WifiDialog extends StatefulWidget {
  const WifiDialog({super.key});

  @override
  State<WifiDialog> createState() => _WifiDialogState();
}

class _WifiDialogState extends State<WifiDialog> {
  List<String> networks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanWifi();
  }

  Future<void> _scanWifi() async {
    try {
      // Run nmcli to list networks
      // Format: SSID|SIGNAL
      final result = await Process.run('bash', ['-c', "nmcli -t -f SSID,SIGNAL dev wifi list"]);
      final lines = result.stdout.toString().split('\n');
      final uniqueNetworks = <String>{}; // Use set to de-dupe
      
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(':'); 
        
        final ssid = parts[0];
        if (ssid.isNotEmpty && uniqueNetworks.length < 15) {
          uniqueNetworks.add(ssid.replaceAll(r'\\:', ':')); // Basic unescape attempt
        }
      }
      
      if (mounted) {
        setState(() {
          networks = uniqueNetworks.toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _connect(String ssid) async {
    final passwordController = TextEditingController();
    final shouldConnect = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF313244),
        title: Text('Connect to $ssid', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );

    if (shouldConnect == true) {
      if (!mounted) return;
      Navigator.pop(context); // Close Wifi list
      // Show connecting snaccbar?
      // Run connection command
      Process.run('nmcli', ['dev', 'wifi', 'connect', ssid, 'password', passwordController.text]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
       backgroundColor: const Color(0xFF1E1E2E),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
       child: Container(
         padding: const EdgeInsets.all(16),
         height: 400,
         width: 300,
         child: Column(
           children: [
             Text('Available Networks', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             Expanded(
               child: isLoading 
                 ? const Center(child: CircularProgressIndicator()) 
                 : ListView.builder(
                     itemCount: networks.length,
                     itemBuilder: (ctx, i) {
                       final net = networks[i];
                       return ListTile(
                         leading: const Icon(Icons.wifi, color: Colors.white70),
                         title: Text(net, style: const TextStyle(color: Colors.white)),
                         onTap: () => _connect(net),
                       );
                     },
                   ),
             ),
             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
           ],
         ),
       ),
    );
  }
}
