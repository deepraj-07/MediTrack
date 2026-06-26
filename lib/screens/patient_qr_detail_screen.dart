import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';
import 'package:meditrack/utils/qr_data.dart';

class PatientQrDetailScreen extends StatelessWidget {
  final PatientQrData qrData;

  const PatientQrDetailScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;

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
          l.patientDetails,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildSection(c, l.personalInfo, [
              _infoRow(Icons.person_outline, l.fullNameLabel, qrData.name),
              _infoRow(Icons.transgender_rounded, l.genderLabel, qrData.gender),
              _infoRow(Icons.phone_outlined, l.mobileLabel, qrData.mobile),
              _infoRow(Icons.email_outlined, l.emailLabel, qrData.email),
              _infoRow(Icons.location_on_outlined, l.addressLabel, qrData.address),
              _infoRow(Icons.bloodtype_outlined, l.bloodGroupLabel, qrData.bloodGroup),
            ]),
            if (qrData.vitals.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(c, l.healthInfo, qrData.vitals.entries.map((e) {
                final labels = {
                  'bp': l.vitalBp,
                  'sugar': l.vitalSugar,
                  'oxygen': l.vitalOxygen,
                  'temperature': l.vitalTemp,
                };
                final label = labels[e.key] ?? e.key;
                return _infoRow(Icons.favorite_outline, label, '${e.value.latest} ${e.value.unit}');
              }).toList()),
            ],
            if (qrData.conditions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildChipSection(l.primaryConditions, qrData.conditions, const Color(0xFFF43F5E)),
            ],
            if (qrData.allergies.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildChipSection(l.allergiesLabel, qrData.allergies, const Color(0xFFF79009)),
            ],
            if (qrData.medicines.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(c, l.regularMedicines, qrData.medicines.map((m) =>
                _infoRow(Icons.medication_outlined, '', m)
              ).toList()),
            ],
            if (qrData.emergencyContacts.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(c, l.emergencyContactsLabel, qrData.emergencyContacts.map((ec) =>
                _infoRow(Icons.phone_outlined, ec.name, ec.phone)
              ).toList()),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          const CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/images/avatar.png')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qrData.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(qrData.nameEn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70)),
                const SizedBox(height: 4),
                Text('${qrData.mobile}  |  ${qrData.bloodGroup}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(AppColors c, String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.primaryText)),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildChipSection(String title, List<String> items, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D2939))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(item, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF7F56D9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF98A2B3))),
                if (label.isNotEmpty) const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D2939))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
