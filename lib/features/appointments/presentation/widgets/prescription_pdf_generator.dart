import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:dentist_ms/features/settings/models/clinicInfo.dart';
import 'dart:typed_data';
import '../models/appointment_model.dart';

class PrescriptionPdfGenerator {
  static String getRouteLabelForPDF(String route) {
    switch (route) {
      case 'oral':
        return 'Oral (par la bouche)';
      case 'topical':
        return 'Topique (local)';
      case 'sublingual':
        return 'Sublingual (sous la langue)';
      case 'injection':
        return 'Injection';
      case 'intravenous':
        return 'Intraveineux (IV)';
      case 'intramuscular':
        return 'Intramusculaire (IM)';
      case 'buccal':
        return 'Buccal (joue)';
      case 'gargle':
        return 'Gargarisme';
      default:
        return route;
    }
  }

  static Future<Uint8List> generatePrescriptionPDF({
    required Map<String, dynamic> prescription,
    required Appointment appointment,
  }) async {
    final pdf = pw.Document();
    final clinicInfo = ClinicInfo.defaultValues();
    
    final items = (prescription['items'] as List<dynamic>?) ?? [];
    final date = prescription['issued_at'] != null
        ? DateFormat('d MMMM yyyy').format(DateTime.parse(prescription['issued_at']))
        : DateFormat('d MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with clinic info
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      clinicInfo.clinicName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Tél: ${clinicInfo.phone}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              'Email: ${clinicInfo.email}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              'Adresse: ${clinicInfo.address}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue200,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            date,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Ordonnance title
              pw.Center(
                child: pw.Text(
                  'ORDONNANCE MéDICALE',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'N° RX-${prescription['id']}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Patient and Doctor Info
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Patient(e):',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                appointment.patientName,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Médecin:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                prescription['doctor'] ?? 'Dr. ${appointment.doctorName}',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (prescription['notes'] != null &&
                        prescription['notes'].toString().isNotEmpty) ...[
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Diagnostic:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        prescription['notes'],
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Medications section
              pw.Text(
                'MéDICAMENTS PRESCRITS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 16),
              
              ...items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value as Map<String, dynamic>;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue200, width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$idx. ${item['medication_name'] ?? ''}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Dosage:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  item['dosage'] ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Fréquence:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  item['frequency'] ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Durée:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  item['duration'] ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Voie:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  getRouteLabelForPDF(item['route'] ?? 'oral'),
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          pw.Expanded(flex: 2, child: pw.SizedBox()),
                        ],
                      ),
                      if (item['instructions'] != null &&
                          item['instructions'].toString().isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Instructions:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          item['instructions'],
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Générêle: ${DateFormat('d MMMM yyyy à HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Signature et cachet du médecin',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
