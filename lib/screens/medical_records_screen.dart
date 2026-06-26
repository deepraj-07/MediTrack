import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';
import 'package:meditrack/providers/vitals_provider.dart';
import 'package:meditrack/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/services/pdf_export_service.dart';
import 'package:intl/intl.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  String _selectedFilter = 'all';

  List<_Record> get _records {
    final l = AppLocalizations.of(context)!;
    return [
      _Record(
        title: l.recordHealthCheckup,
        doctor: l.recordDocGupta,
        date: '20 ${l.monthJun} 2026',
        type: l.recordTypeBlood,
        icon: Icons.science_rounded,
        color: const Color(0xFF7F56D9),
        summary: l.recordSummaryHealthCheckup,
      ),
      _Record(
        title: l.recordHeartCheckup,
        doctor: l.recordDocSharma,
        date: '15 ${l.monthMayLabel} 2026',
        type: l.recordTypeECG,
        icon: Icons.favorite_rounded,
        color: const Color(0xFFF43F5E),
        summary: l.recordSummaryHeartCheckup,
      ),
      _Record(
        title: l.recordDiabetesCheckup,
        doctor: l.recordDocVerma,
        date: '10 ${l.monthMayLabel} 2026',
        type: l.recordTypeHba1c,
        icon: Icons.bloodtype_rounded,
        color: const Color(0xFF3B82F6),
        summary: l.recordSummaryDiabetesCheckup,
      ),
      _Record(
        title: l.recordXray,
        doctor: l.recordDocPatel,
        date: '2 ${l.monthApr} 2026',
        type: l.recordTypeXray,
        icon: Icons.visibility_rounded,
        color: const Color(0xFF12B76A),
        summary: l.recordSummaryXray,
      ),
      _Record(
        title: l.recordAnnualCheckup,
        doctor: l.recordDocGupta,
        date: '15 ${l.monthMar} 2026',
        type: l.recordTypeFullBody,
        icon: Icons.assignment_rounded,
        color: const Color(0xFFF59E0B),
        summary: l.recordSummaryAnnualCheckup,
      ),
    ];
  }

  List<_Record> get _filteredRecords {
    final l = AppLocalizations.of(context)!;
    if (_selectedFilter == 'reports') {
      return _records.where((r) => r.type == l.recordTypeBlood || r.type == l.recordTypeFullBody || r.type == l.recordTypeHba1c).toList();
    } else if (_selectedFilter == 'scans') {
      return _records.where((r) => r.type == l.recordTypeECG || r.type == l.recordTypeXray).toList();
    }
    return _records;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
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
          AppLocalizations.of(context)!.quickRecords.replaceAll('\n', ' '),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.primaryText),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _buildSummaryCard(Icons.description_rounded, '${_records.length}', AppLocalizations.of(context)!.all, const Color(0xFF7F56D9)),
                const SizedBox(width: 12),
                _buildSummaryCard(Icons.calendar_today_rounded, '2026', AppLocalizations.of(context)!.thisYear, const Color(0xFF12B76A)),
              ],
            ),
          ),
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFilterTabs(),
          ),
          const SizedBox(height: 16),
          // Records list
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 56, color: c.tertiaryText),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.noRecords,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.secondaryText),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (_, i) => _buildRecordCard(_filteredRecords[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String value, String label, Color color) {
    final c = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.primaryText)),
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.secondaryText)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.divider,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildFilterTab('all', AppLocalizations.of(context)!.filterAll),
          _buildFilterTab('reports', AppLocalizations.of(context)!.filterReports),
          _buildFilterTab('scans', AppLocalizations.of(context)!.filterScans),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, String label) {
    final c = context.appColors;
    bool isActive = _selectedFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = filter),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF7F56D9) : c.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(_Record record) {
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: record.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(record.icon, color: record.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _showRecordDetail(record),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.primaryText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${record.doctor} • ${record.date}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.secondaryText),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: record.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.type,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: record.color),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final l = AppLocalizations.of(context)!;
                  final profile = context.read<ProfileProvider>();
                  final vitals = context.read<VitalsProvider>().readings;
                  final now = DateTime.now();
                  final dateStr = DateFormat('dd-MM-yyyy').format(now);
                  final pdfBytes = await PdfExportService.generateHealthReport(
                    patientName: profile.name.isNotEmpty ? profile.name : l.profileNameEn,
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
                  final file = await PdfExportService.saveToTempFile(pdfBytes, 'MediTrack_${record.title}_$dateStr.pdf');
                  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F56D9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download_rounded, color: Color(0xFF7F56D9), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showRecordDetail(record),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.scaffoldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize_rounded, size: 14, color: c.secondaryText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.summary,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.secondaryText),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: c.tertiaryText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(_Record record) {
    final c = context.appColors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48, height: 5,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: record.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(record.icon, color: record.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText)),
                      const SizedBox(height: 4),
                      Text('${record.doctor} • ${record.date}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.secondaryText)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Color(0xFF7F56D9)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final l = AppLocalizations.of(context)!;
                    final profile = context.read<ProfileProvider>();
                    final vitals = context.read<VitalsProvider>().readings;
                    final now = DateTime.now();
                    final dateStr = DateFormat('dd/MM/yyyy').format(now);
                    final pdfBytes = await PdfExportService.generateHealthReport(
                      patientName: profile.name.isNotEmpty ? profile.name : l.profileNameEn,
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
                    final file = await PdfExportService.saveToTempFile(pdfBytes, 'MediTrack_Report_$dateStr.pdf');
                    await SharePlus.instance.share(
                      ShareParams(files: [XFile(file.path)]),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(ctx)!.reportSummary, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.secondaryText)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.scaffoldBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                record.summary,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.primaryText, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F56D9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(ctx)!.close, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Record {
  final String title;
  final String doctor;
  final String date;
  final String type;
  final IconData icon;
  final Color color;
  final String summary;

  const _Record({
    required this.title,
    required this.doctor,
    required this.date,
    required this.type,
    required this.icon,
    required this.color,
    required this.summary,
  });
}
