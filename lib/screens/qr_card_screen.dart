import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/providers/vitals_provider.dart';
import 'package:meditrack/providers/profile_provider.dart';
import 'package:meditrack/theme/app_theme.dart';
import 'package:meditrack/utils/qr_data.dart';
import 'package:meditrack/screens/scan_qr_screen.dart';

class QrCardScreen extends StatelessWidget {
  const QrCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    final profile = context.watch<ProfileProvider>();
    final vitals = context.read<VitalsProvider>().readings;
    final qrData = PatientQrData.fromLocalization(l, vitals, profile);
    final qrString = qrData.encode();

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: c.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.myQrCode,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_rounded, color: c.secondaryText),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQrScreen())),
            tooltip: l.scanQrCode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F56D9), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF7F56D9).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: profile.imagePath != null
                        ? FileImage(File(profile.imagePath!)) as ImageProvider
                        : const AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name.isNotEmpty ? profile.name : l.profileNameEn, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(l.profileId, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text(l.scanToView, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.secondaryText)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEF2FF), width: 2),
                    ),
                    child: QrImageView(
                      data: qrString,
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF7F56D9)),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1D2939)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l.qrValidMessage, style: TextStyle(fontSize: 11, color: c.tertiaryText), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.share_rounded,
                    l.shareQr,
                    const Color(0xFF7F56D9),
                    () {
                      SharePlus.instance.share(ShareParams(text: qrString));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.qr_code_scanner_rounded,
                    l.scanQrCode,
                    const Color(0xFF2E90FA),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanQrScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.primaryText)),
          ],
        ),
      ),
    );
  }
}
