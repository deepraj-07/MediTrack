import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:meditrack/models/vital_reading.dart';

class PdfExportService {
  static Future<Uint8List> generateHealthReport({
    required String patientName,
    required String patientId,
    required String patientDob,
    required String patientGender,
    required String patientBloodGroup,
    required String patientMobile,
    required String patientEmail,
    required String patientAddress,
    required List<String> conditions,
    required List<String> allergies,
    required List<Map<String, String>> medicines,
    required List<VitalReading> vitals,
    required String generatedDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSectionTitle('Patient Information'),
            pw.SizedBox(height: 8),
            _buildPatientInfo(patientName, patientId, patientDob, patientGender, patientBloodGroup, patientMobile, patientEmail, patientAddress),
            pw.SizedBox(height: 20),
            if (conditions.isNotEmpty) ...[
              _buildSectionTitle('Medical Conditions'),
              pw.SizedBox(height: 8),
              _buildChipList(conditions),
              pw.SizedBox(height: 20),
            ],
            if (allergies.isNotEmpty) ...[
              _buildSectionTitle('Allergies'),
              pw.SizedBox(height: 8),
              _buildChipList(allergies),
              pw.SizedBox(height: 20),
            ],
            if (medicines.isNotEmpty) ...[
              _buildSectionTitle('Current Medications'),
              pw.SizedBox(height: 8),
              _buildMedicinesTable(medicines),
              pw.SizedBox(height: 20),
            ],
            if (vitals.isNotEmpty) ...[
              _buildSectionTitle('Vital Signs History'),
              pw.SizedBox(height: 8),
              _buildVitalsTable(vitals),
              pw.SizedBox(height: 20),
            ],
            _buildFooter(generatedDate),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MediTrack',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF7F56D9),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Health Report',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF7F56D9),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'CONFIDENTIAL',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColor.fromInt(0xFF7F56D9)),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF7F56D9),
      ),
    );
  }

  static pw.Widget _buildPatientInfo(
    String name, String id, String dob, String gender,
    String bloodGroup, String mobile, String email, String address,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8F6FF),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE8E0F7)),
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('Name', name),
          _buildInfoRow('Patient ID', id),
          _buildInfoRow('Date of Birth', dob),
          _buildInfoRow('Gender', gender),
          _buildInfoRow('Blood Group', bloodGroup),
          _buildInfoRow('Mobile', mobile),
          _buildInfoRow('Email', email),
          _buildInfoRow('Address', address),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildChipList(List<String> items) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((item) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF0E6FF),
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Text(
            item,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF5B3E9E),
            ),
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildMedicinesTable(List<Map<String, String>> medicines) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0E0E0)),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF7F56D9)),
          children: ['Medicine', 'Dose', 'Time', 'Instruction'].map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            );
          }).toList(),
        ),
        ...medicines.map((med) {
          return pw.TableRow(
            children: [
              _buildCell(med['name'] ?? ''),
              _buildCell(med['dose'] ?? ''),
              _buildCell(med['time'] ?? ''),
              _buildCell(med['instruction'] ?? ''),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static pw.Widget _buildVitalsTable(List<VitalReading> vitals) {
    final grouped = <String, List<VitalReading>>{};
    for (final v in vitals) {
      grouped.putIfAbsent(v.type, () => []).add(v);
    }

    final typeLabels = {
      'bp': 'Blood Pressure',
      'sugar': 'Blood Sugar',
      'oxygen': 'Oxygen (SpO₂)',
      'temperature': 'Temperature',
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE0E0E0)),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF7F56D9)),
          children: ['Type', 'Value', 'Date', 'Time'].map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            );
          }).toList(),
        ),
        ...vitals.map((v) {
          return pw.TableRow(
            children: [
              _buildCell(typeLabels[v.type] ?? v.type),
              _buildCell(v.value),
              _buildCell(v.date),
              _buildCell(v.time),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildFooter(String generatedDate) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated on $generatedDate from MediTrack App',
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey500,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'This is a computer-generated report. No signature required.',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey400,
          ),
        ),
      ],
    );
  }

  static Future<File> saveToTempFile(Uint8List bytes, String fileName) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }
}
