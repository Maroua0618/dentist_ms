import 'dart:convert';
import 'dart:io';
import 'package:dentist_ms/features/patients/models/patient.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PatientExportService {
  static String _getDownloadsPath() {
    if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads';
    } else if (Platform.isMacOS || Platform.isLinux) {
      return '${Platform.environment['HOME']}/Downloads';
    }
    return '';
  }

  static String _generateFileName(String extension) {
    final date = DateTime.now().toIso8601String().split('T').first;
    return 'patients_$date.$extension';
  }

  // Export to CSV
  static Future<String> exportToCSV(List<Patient> patients) async {
    String csv = 'ID,Nom,Prénom,Genre,Date de naissance,Téléphone,Email,Adresse,Statut,Groupe sanguin,Date d\'enregistrement\n';

    for (final patient in patients) {
      csv += '${patient.id ??  ""},'
          '"${patient.firstName ?? ""}",'
          '"${patient. lastName ?? ""}",'
          '"${patient.gender ?? ""}",'
          '"${patient.dateOfBirth?. toIso8601String().split('T').first ?? ""}",'
          '"${patient.phone1 ?? ""}",'
          '"${patient.email ?? ""}",'
          '"${patient.address ?? ""}",'
          '"${patient.status ?? ""}",'
          '"${patient. bloodType ?? ""}",'
          '"${patient.createdAt?. toIso8601String().split('T').first ?? ""}"\n';
    }

    final downloadsPath = _getDownloadsPath();
    final fileName = _generateFileName('csv');
    final filePath = '$downloadsPath${Platform.pathSeparator}$fileName';
    final file = File(filePath);

    await file.writeAsString(csv, encoding: utf8);

    return filePath;
  }

  // Export to Excel
  static Future<String> exportToExcel(List<Patient> patients) async {
    final excel = Excel. createExcel();
    final sheet = excel['Patients'];

    // Headers with French translation
    final headers = [
      TextCellValue('ID'),
      TextCellValue('Nom'),
      TextCellValue('Prénom'),
      TextCellValue('Genre'),
      TextCellValue('Date de naissance'),
      TextCellValue('Téléphone'),
      TextCellValue('Email'),
      TextCellValue('Adresse'),
      TextCellValue('Statut'),
      TextCellValue('Groupe sanguin'),
      TextCellValue('Date d\'enregistrement'),
    ];
    
    sheet.appendRow(headers);

    // Style header row
    for (int col = 0; col < 11; col++) {
      final cell = sheet.cell(
        CellIndex. indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4F7EFF'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }

    // Add data rows
    for (final patient in patients) {
      final row = [
        TextCellValue(patient.id?. toString() ?? ''),
        TextCellValue(patient.firstName ??  ''),
        TextCellValue(patient.lastName ?? ''),
        TextCellValue(patient. gender ?? ''),
        TextCellValue(patient.dateOfBirth?.toIso8601String().split('T').first ?? ''),
        TextCellValue(patient.phone1 ?? ''),
        TextCellValue(patient.email ?? ''),
        TextCellValue(patient.address ??  ''),
        TextCellValue(patient.status ?? ''),
        TextCellValue(patient. bloodType ?? ''),
        TextCellValue(patient.createdAt?.toIso8601String().split('T').first ?? ''),
      ];
      sheet.appendRow(row);
    }

    // Auto-size columns
    for (int col = 0; col < 11; col++) {
      sheet.setColumnWidth(col, 20);
    }

    final downloadsPath = _getDownloadsPath();
    final fileName = _generateFileName('xlsx');
    final filePath = '$downloadsPath${Platform.pathSeparator}$fileName';
    final file = File(filePath);

    final bytes = excel.encode();
    if (bytes != null) {
      await file. writeAsBytes(bytes);
    }

    return filePath;
  }

  // Export to PDF
  static Future<String> exportToPDF(List<Patient> patients) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Liste des Patients',
              style: pw. TextStyle(
                fontSize: 24,
                fontWeight: pw. FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Généré le: ${DateTime.now().toIso8601String().split('T').first}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Total:  ${patients.length} patients',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          pw.Table. fromTextArray(
            headers: [
              'ID',
              'Nom Complet',
              'Genre',
              'Téléphone',
              'Email',
              'Statut',
            ],
            data: patients.map((p) => [
              p.id?. toString() ?? '',
              '${p.firstName ?? ''} ${p.lastName ?? ''}'. trim(),
              p.gender ?? '',
              p.phone1 ?? '',
              p. email ?? '',
              p.status ?? '',
            ]).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blue,
            ),
            cellAlignment: pw. Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ],
      ),
    );

    final downloadsPath = _getDownloadsPath();
    final fileName = _generateFileName('pdf');
    final filePath = '$downloadsPath${Platform.pathSeparator}$fileName';
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Open file in explorer (Windows only)
  static Future<void> openFileInExplorer(String filePath) async {
    if (Platform.isWindows) {
      await Process.run('explorer', ['/select,', filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [File(filePath).parent.path]);
    }
  }
}