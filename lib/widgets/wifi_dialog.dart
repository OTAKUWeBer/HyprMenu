import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/responsive.dart';

class WifiDialog extends StatefulWidget {
  const WifiDialog({super.key});

  @override
  State<WifiDialog> createState() => _WifiDialogState();
}

class _WifiDialogState extends State<WifiDialog> with SingleTickerProviderStateMixin {
  // ── Color Palette (Catppuccin Mocha) ──
  static const _base = Color(0xFF1E1E2E);
  static const _mantle = Color(0xFF181825);
  static const _surface0 = Color(0xFF313244);
  static const _surface1 = Color(0xFF45475A);
  static const _surface2 = Color(0xFF585B70);
  static const _text = Color(0xFFCDD6F4);
  static const _subtext0 = Color(0xFFA6ADC8);
  static const _subtext1 = Color(0xFFBAC2DE);
  static const _blue = Color(0xFF89B4FA);
  static const _green = Color(0xFFA6E3A1);
  static const _red = Color(0xFFF38BA8);
  static const _overlay0 = Color(0xFF6C7086);

  late TabController _tabController;
  List<_WifiNetwork> _availableNetworks = [];
  List<String> _savedNetworks = [];
  bool _isLoadingAvailable = true;
  bool _isLoadingSaved = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scanWifi();
    _loadSavedNetworks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data Loading ──

  Future<void> _scanWifi() async {
    try {
      final result = await Process.run(
        'bash', ['-c', "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list"],
      );
      final lines = result.stdout.toString().split('\n');
      final seen = <String>{};
      final networks = <_WifiNetwork>[];

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        // nmcli uses \: for literal colons. Split on unescaped ':'
        final parts = line.split(RegExp(r'(?<!\\):'));
        if (parts.isEmpty) continue;
        final ssid = parts[0].replaceAll(r'\:', ':');
        if (ssid.isEmpty || seen.contains(ssid)) continue;
        seen.add(ssid);

        final signal = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        final security = parts.length > 2 ? parts[2] : '';
        if (networks.length < 20) {
          networks.add(_WifiNetwork(ssid: ssid, signal: signal, security: security));
        }
      }

      // Sort by signal strength descending
      networks.sort((a, b) => b.signal.compareTo(a.signal));

      if (mounted) setState(() { _availableNetworks = networks; _isLoadingAvailable = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingAvailable = false);
    }
  }

  Future<void> _loadSavedNetworks() async {
    try {
      final result = await Process.run(
        'bash', ['-c', "nmcli -t -f NAME,TYPE connection show"],
      );
      final lines = result.stdout.toString().split('\n');
      final saved = <String>[];
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(':');
        if (parts.length >= 2 && parts.last.contains('wireless')) {
          final name = parts.sublist(0, parts.length - 1).join(':');
          if (name.isNotEmpty) saved.add(name);
        }
      }
      if (mounted) setState(() { _savedNetworks = saved; _isLoadingSaved = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingSaved = false);
    }
  }

  // ── Actions ──

  Future<void> _connectToNetwork(String ssid) async {
    final password = await _showPasswordDialog(ssid);
    if (password == null) return;
    if (!mounted) return;
    Navigator.pop(context);
    Process.run('nmcli', ['dev', 'wifi', 'connect', ssid, 'password', password]);
  }

  Future<String?> _getStoredPassword(String connectionName) async {
    try {
      final result = await Process.run(
        'bash', ['-c', 'nmcli -s -g 802-11-wireless-security.psk connection show "$connectionName"'],
      );
      final pw = result.stdout.toString().trim();
      return pw.isNotEmpty ? pw : null;
    } catch (_) {
      return null;
    }
  }

  // ── Password Dialog ──

  Future<String?> _showPasswordDialog(String ssid) async {
    final controller = TextEditingController();
    bool obscure = true;

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final s = Responsive.scale(ctx);
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 340 * s,
                  padding: EdgeInsets.all(24 * s),
                  decoration: BoxDecoration(
                    color: _surface0,
                    borderRadius: BorderRadius.circular(24 * s),
                    border: Border.all(color: _surface2.withValues(alpha: 0.4), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header icon ──
                      Container(
                        width: 52 * s,
                        height: 52 * s,
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.wifi_lock_rounded, color: _blue, size: 26 * s),
                      ),
                      SizedBox(height: 14 * s),
                      Text(
                        'Connect to',
                        style: GoogleFonts.inter(color: _subtext0, fontSize: 13 * s),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        ssid,
                        style: GoogleFonts.inter(
                          color: _text, fontSize: 18 * s, fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 20 * s),

                      // ── Password field ──
                      Container(
                        decoration: BoxDecoration(
                          color: _mantle,
                          borderRadius: BorderRadius.circular(14 * s),
                          border: Border.all(color: _surface2.withValues(alpha: 0.5), width: 1),
                        ),
                        child: TextField(
                          controller: controller,
                          obscureText: obscure,
                          style: GoogleFonts.inter(color: _text, fontSize: 14 * s),
                          cursorColor: _blue,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            hintStyle: GoogleFonts.inter(color: _overlay0, fontSize: 14 * s),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 14 * s, right: 10 * s),
                              child: Icon(Icons.lock_outline_rounded, color: _subtext0, size: 20 * s),
                            ),
                            prefixIconConstraints: BoxConstraints(minWidth: 44 * s),
                            suffixIcon: GestureDetector(
                              onTap: () => setLocalState(() => obscure = !obscure),
                              child: Padding(
                                padding: EdgeInsets.only(right: 10 * s),
                                child: Icon(
                                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: _subtext0,
                                  size: 20 * s,
                                ),
                              ),
                            ),
                            suffixIconConstraints: BoxConstraints(minWidth: 40 * s),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14 * s),
                          ),
                        ),
                      ),
                      SizedBox(height: 22 * s),

                      // ── Connect button ──
                      SizedBox(
                        width: double.infinity,
                        height: 46 * s,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_blue, Color(0xFF74C7EC)],
                            ),
                            borderRadius: BorderRadius.circular(14 * s),
                            boxShadow: [
                              BoxShadow(
                                color: _blue.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, controller.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14 * s),
                              ),
                            ),
                            child: Text(
                              'Connect',
                              style: GoogleFonts.inter(
                                color: _base, fontSize: 15 * s, fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * s),

                      // ── Cancel button ──
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(color: _subtext0, fontSize: 13 * s),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Share Dialog (QR + Password) ──

  Future<void> _showShareDialog(String networkName) async {
    final s = Responsive.scale(context);
    final password = await _getStoredPassword(networkName);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final qrData = 'WIFI:T:WPA;S:$networkName;P:${password ?? ''};;';
        bool showPw = false;

        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 340 * s,
                  padding: EdgeInsets.all(24 * s),
                  decoration: BoxDecoration(
                    color: _surface0,
                    borderRadius: BorderRadius.circular(24 * s),
                    border: Border.all(color: _surface2.withValues(alpha: 0.4), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Title ──
                      Text(
                        'Share WiFi',
                        style: GoogleFonts.inter(
                          color: _text, fontSize: 18 * s, fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        networkName,
                        style: GoogleFonts.inter(color: _subtext0, fontSize: 13 * s),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20 * s),

                      // ── QR Code ──
                      Container(
                        padding: EdgeInsets.all(16 * s),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 180 * s,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1E1E2E),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1E1E2E),
                          ),
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        'Scan with your phone camera',
                        style: GoogleFonts.inter(color: _overlay0, fontSize: 11 * s),
                      ),
                      SizedBox(height: 18 * s),

                      // ── Password section ──
                      if (password != null && password.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
                          decoration: BoxDecoration(
                            color: _mantle,
                            borderRadius: BorderRadius.circular(12 * s),
                            border: Border.all(color: _surface2.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, color: _subtext0, size: 18 * s),
                              SizedBox(width: 10 * s),
                              Expanded(
                                child: Text(
                                  showPw ? password : '•' * password.length.clamp(6, 20),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: _text, fontSize: 13 * s,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _IconBtn(
                                icon: showPw ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 20 * s,
                                color: _subtext0,
                                onTap: () => setLocalState(() => showPw = !showPw),
                              ),
                              SizedBox(width: 4 * s),
                              _IconBtn(
                                icon: Icons.copy_rounded,
                                size: 18 * s,
                                color: _subtext0,
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: password));
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text('Password copied', style: GoogleFonts.inter(color: _text)),
                                      backgroundColor: _surface1,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18 * s),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
                          decoration: BoxDecoration(
                            color: _mantle,
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline_rounded, color: _overlay0, size: 16 * s),
                              SizedBox(width: 8 * s),
                              Text(
                                'Open network (no password)',
                                style: GoogleFonts.inter(color: _overlay0, fontSize: 12 * s),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18 * s),
                      ],

                      // ── Close ──
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Done',
                          style: GoogleFonts.inter(color: _blue, fontSize: 14 * s, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Signal Icon Helper ──

  IconData _signalIcon(int signal) {
    if (signal >= 70) return Icons.signal_wifi_4_bar_rounded;
    if (signal >= 50) return Icons.network_wifi_3_bar_rounded;
    if (signal >= 30) return Icons.network_wifi_2_bar_rounded;
    return Icons.network_wifi_1_bar_rounded;
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final s = Responsive.scale(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(24 * s),
      child: Container(
        width: 380 * s,
        height: 520 * s,
        decoration: BoxDecoration(
          color: _base,
          borderRadius: BorderRadius.circular(24 * s),
          border: Border.all(color: _surface1.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 12 * s, 0),
              child: Row(
                children: [
                  Container(
                    width: 38 * s,
                    height: 38 * s,
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.wifi_rounded, color: _blue, size: 20 * s),
                  ),
                  SizedBox(width: 12 * s),
                  Text(
                    'WiFi',
                    style: GoogleFonts.inter(
                      color: _text, fontSize: 20 * s, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Refresh
                  _IconBtn(
                    icon: Icons.refresh_rounded,
                    size: 22 * s,
                    color: _subtext0,
                    onTap: () {
                      setState(() { _isLoadingAvailable = true; _isLoadingSaved = true; });
                      _scanWifi();
                      _loadSavedNetworks();
                    },
                  ),
                  // Close
                  _IconBtn(
                    icon: Icons.close_rounded,
                    size: 22 * s,
                    color: _subtext0,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * s),

            // ── Tab Bar ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * s),
              child: Container(
                height: 40 * s,
                decoration: BoxDecoration(
                  color: _surface0,
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: _base,
                  unselectedLabelColor: _subtext0,
                  labelStyle: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w500),
                  indicatorPadding: EdgeInsets.all(3 * s),
                  tabs: const [
                    Tab(text: 'Available'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12 * s),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableTab(s),
                  _buildSavedTab(s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Available Networks Tab ──

  Widget _buildAvailableTab(double s) {
    if (_isLoadingAvailable) {
      return _buildLoadingShimmer(s);
    }
    if (_availableNetworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: _overlay0, size: 40 * s),
            SizedBox(height: 10 * s),
            Text('No networks found', style: GoogleFonts.inter(color: _overlay0, fontSize: 14 * s)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      itemCount: _availableNetworks.length,
      separatorBuilder: (_, __) => Divider(color: _surface1.withValues(alpha: 0.4), height: 1),
      itemBuilder: (ctx, i) {
        final net = _availableNetworks[i];
        final isSaved = _savedNetworks.contains(net.ssid);
        return InkWell(
          onTap: () => _connectToNetwork(net.ssid),
          borderRadius: BorderRadius.circular(12 * s),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10 * s, horizontal: 4 * s),
            child: Row(
              children: [
                // Signal icon
                Container(
                  width: 36 * s,
                  height: 36 * s,
                  decoration: BoxDecoration(
                    color: _surface0,
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                  child: Icon(
                    _signalIcon(net.signal),
                    color: net.signal >= 50 ? _green : _subtext0,
                    size: 18 * s,
                  ),
                ),
                SizedBox(width: 12 * s),
                // Name + security
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        net.ssid,
                        style: GoogleFonts.inter(
                          color: _text, fontSize: 14 * s, fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2 * s),
                      Row(
                        children: [
                          if (net.security.isNotEmpty) ...[
                            Icon(Icons.lock_outline_rounded, color: _overlay0, size: 11 * s),
                            SizedBox(width: 4 * s),
                            Text(
                              net.security,
                              style: GoogleFonts.inter(color: _overlay0, fontSize: 11 * s),
                            ),
                          ] else
                            Text('Open', style: GoogleFonts.inter(color: _overlay0, fontSize: 11 * s)),
                          if (isSaved) ...[
                            SizedBox(width: 8 * s),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 1 * s),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4 * s),
                              ),
                              child: Text(
                                'Saved',
                                style: GoogleFonts.inter(
                                  color: _green, fontSize: 10 * s, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Connect arrow
                Icon(Icons.chevron_right_rounded, color: _surface2, size: 22 * s),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Saved Networks Tab ──

  Widget _buildSavedTab(double s) {
    if (_isLoadingSaved) {
      return _buildLoadingShimmer(s);
    }
    if (_savedNetworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded, color: _overlay0, size: 40 * s),
            SizedBox(height: 10 * s),
            Text('No saved networks', style: GoogleFonts.inter(color: _overlay0, fontSize: 14 * s)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      itemCount: _savedNetworks.length,
      separatorBuilder: (_, __) => Divider(color: _surface1.withValues(alpha: 0.4), height: 1),
      itemBuilder: (ctx, i) {
        final name = _savedNetworks[i];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8 * s, horizontal: 4 * s),
          child: Row(
            children: [
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: _surface0,
                  borderRadius: BorderRadius.circular(10 * s),
                ),
                child: Icon(Icons.wifi_rounded, color: _blue, size: 18 * s),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    color: _text, fontSize: 14 * s, fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Share button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showShareDialog(name),
                  borderRadius: BorderRadius.circular(10 * s),
                  child: Container(
                    width: 36 * s,
                    height: 36 * s,
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10 * s),
                    ),
                    child: Icon(Icons.qr_code_2_rounded, color: _blue, size: 18 * s),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Loading Shimmer ──

  Widget _buildLoadingShimmer(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Column(
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * s),
            child: Row(
              children: [
                Container(
                  width: 36 * s, height: 36 * s,
                  decoration: BoxDecoration(
                    color: _surface0.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: (80 + i * 20) * s,
                        height: 14 * s,
                        decoration: BoxDecoration(
                          color: _surface0.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6 * s),
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      Container(
                        width: 50 * s,
                        height: 10 * s,
                        decoration: BoxDecoration(
                          color: _surface0.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4 * s),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Data Model ──

class _WifiNetwork {
  final String ssid;
  final int signal;
  final String security;

  _WifiNetwork({required this.ssid, required this.signal, required this.security});
}

// ── Reusable small icon button ──

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
