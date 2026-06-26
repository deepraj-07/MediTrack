import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';
import 'package:meditrack/providers/vitals_provider.dart';
import 'package:meditrack/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/services/pdf_export_service.dart';
import 'package:intl/intl.dart';

class HealthReportScreen extends StatelessWidget {
  const HealthReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    
    final vitals = context.watch<VitalsProvider>();
    final bpReadings = vitals.getReadingsByType('bp');
    final sugarReadings = vitals.getReadingsByType('sugar');
    final oxygenReadings = vitals.getReadingsByType('oxygen');
    final tempReadings = vitals.getReadingsByType('temperature');
    
    final String latestBp = bpReadings.isNotEmpty ? bpReadings.last.value : '120/80';
    final String latestSugar = sugarReadings.isNotEmpty ? sugarReadings.last.value : '98';
    final String latestOxygen = oxygenReadings.isNotEmpty ? oxygenReadings.last.value : '98%';
    final String latestTemp = tempReadings.isNotEmpty ? tempReadings.last.value : '98.6°F';

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.primaryText, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.quickReport.replaceAll('\n', ' '),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.primaryText),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF7F56D9)),
            onPressed: () async {
              final l = AppLocalizations.of(context)!;
              final profile = context.read<ProfileProvider>();
              final vitals = context.read<VitalsProvider>().readings;
              final now = DateTime.now();
              final dateStr = DateFormat('dd/MM/yyyy').format(now);
              final pdfBytes = await PdfExportService.generateHealthReport(
                patientName: profile.name.isNotEmpty ? profile.name : l.userName,
                patientId: l.profileId,
                patientDob: l.userDob,
                patientGender: l.userGender,
                patientBloodGroup: l.userBloodGroup,
                patientMobile: l.userMobile,
                patientEmail: l.userEmail,
                patientAddress: l.userAddress,
                conditions: [l.condHypertension, l.condDiabetes, l.condArthritis],
                allergies: [l.allergyDust, l.allergyPenicillin],
                medicines: [
                  {'name': l.medAmlodipine, 'dose': l.medAmlodipineDose, 'time': '08:00 AM', 'instruction': l.instAfterBreakfast},
                  {'name': l.medMetformin, 'dose': l.dose1Pill, 'time': '01:00 PM', 'instruction': l.instAfterLunch},
                ],
                vitals: vitals,
                generatedDate: dateStr,
              );
              final file = await PdfExportService.saveToTempFile(pdfBytes, 'MediTrack_Health_Report_$dateStr.pdf');
              await SharePlus.instance.share(
                ShareParams(files: [XFile(file.path)]),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: c.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF7F56D9)),
                  const SizedBox(width: 10),
                  Text(
                    '${l.monthJun} 2026',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.primaryText),
                  ),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down_rounded, color: c.tertiaryText),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F56D9), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7F56D9).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l.yourHealthReport,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.healthy,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF86EFAC)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.allVitalsNormal,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(l.healthParameters, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText)),
            const SizedBox(height: 12),
            _buildParamGrid(l, c, latestBp, latestSugar, latestOxygen, latestTemp),
            const SizedBox(height: 20),
            Text(l.recommendations, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText)),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              Icons.wb_sunny_rounded,
              l.recVitaminD,
              l.recVitaminDDesc,
              const Color(0xFFF59E0B),
              c,
            ),
            const SizedBox(height: 10),
            _buildRecommendationCard(
              Icons.directions_walk_rounded,
              l.recExercise,
              l.recExerciseDesc,
              const Color(0xFF12B76A),
              c,
            ),
            const SizedBox(height: 10),
            _buildRecommendationCard(
              Icons.water_drop_rounded,
              l.recWater,
              l.recWaterDesc,
              const Color(0xFF2E82FF),
              c,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamGrid(
    AppLocalizations l,
    AppColors c,
    String latestBp,
    String latestSugar,
    String latestOxygen,
    String latestTemp,
  ) {
    final params = [
      _HealthParam(l.bp, latestBp, 'mmHg', const Color(0xFFF43F5E), Icons.favorite_rounded, true),
      _HealthParam(l.sugar, latestSugar, 'mg/dL', const Color(0xFF3B82F6), Icons.water_drop_rounded, true),
      _HealthParam(l.oxygen, latestOxygen, '', const Color(0xFF8B5CF6), Icons.circle, true),
      _HealthParam(l.temperature, latestTemp, '', const Color(0xFFF97316), Icons.thermostat_rounded, true),
      _HealthParam(l.tipCholesterol, '180', 'mg/dL', const Color(0xFFEC4899), Icons.opacity_rounded, true),
      _HealthParam(l.recordTypeHba1c, '6.2', l.unitPercent, const Color(0xFF7F56D9), Icons.bloodtype_rounded, true),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: params.length,
      itemBuilder: (_, i) => _buildParamCard(params[i], l, c),
    );
  }

  Widget _buildParamCard(_HealthParam param, AppLocalizations l, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: param.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(param.icon, color: param.color, size: 12),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(param.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.secondaryText)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                param.value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText),
              ),
              if (param.unit.isNotEmpty)
                Text(param.unit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.secondaryText)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7ED),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(l.normal, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF12B76A))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(IconData icon, String title, String desc, Color color, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.primaryText)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.secondaryText)),
              ],
            ),
          ),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded, color: color, size: 16),
          ),
        ],
      ),
    );
  }
}

class _HealthParam {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final bool isNormal;

  const _HealthParam(this.label, this.value, this.unit, this.color, this.icon, this.isNormal);
}
