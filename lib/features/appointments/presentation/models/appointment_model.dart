import 'package:flutter/material.dart';
import '../utils/appointment_utils.dart';

class AppointmentFile {
  final String id;
  final String fileName;
  final String fileType;
  final DateTime uploadedAt;
  final String uploadedBy;
  final double fileSizeInMB;

  AppointmentFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.fileSizeInMB,
  });

  factory AppointmentFile.fromJson(Map<String, dynamic> json) => AppointmentFile(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        fileType: json['fileType'] as String,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        uploadedBy: json['uploadedBy'] as String,
        fileSizeInMB: (json['fileSizeInMB'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'uploadedAt': uploadedAt.toIso8601String(),
        'uploadedBy': uploadedBy,
        'fileSizeInMB': fileSizeInMB,
      };
}

class Remark {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;

  Remark({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });

  factory Remark.fromJson(Map<String, dynamic> json) => Remark(
        id: json['id'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        createdBy: json['createdBy'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
      };
}

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String status;
  final String receiptNumber;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    required this.receiptNumber,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        paymentDate: DateTime.parse(json['paymentDate'] as String),
        paymentMethod: json['paymentMethod'] as String,
        status: json['status'] as String,
        receiptNumber: json['receiptNumber'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'status': status,
        'receiptNumber': receiptNumber,
      };
}

class Appointment {
  final String id;
  final int? patientId;
  final String patientName;
  final int? doctorId;           // ← NEW: Doctor foreign key
  final String doctorName;       // ← NEW: For display (resolved on load)
  final String procedure;
  final String time;
  final int duration;            // ← Variable duration in minutes
  String status;
  final Color cardColor;
  final DateTime appointmentDate;
  String notes;
  List<AppointmentFile> files;
  List<Remark> remarks;
  List<PaymentRecord> payments;
  double totalCost;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    this.doctorName = 'Unknown Doctor',  // ← Default fallback
    required this.procedure,
    required this.time,
    required this.duration,
    required this.status,
    required this.cardColor,
    required this.appointmentDate,
    this.notes = '',
    this.files = const [],
    this.remarks = const [],
    this.payments = const [],
    this.totalCost = 0.0,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final isSupabaseFormat = json.containsKey('start_datetime');

    final String procedureName = json['diagnosis'] as String? ??
        json['procedure'] as String? ??
        '';

    return Appointment(
      id: json['id'].toString(),
      patientId: json['patient_id'] as int?,
      patientName: json['patientName'] as String? ?? 'Unknown Patient',
      doctorId: json['doctor_id'] as int?,                    // ← NEW
      doctorName: json['doctorName'] as String? ?? 'Unknown Doctor',  // ← NEW
      procedure: procedureName,
      time: isSupabaseFormat
          ? _extractTime(json['start_datetime'])
          : json['time'] as String? ?? '',
      duration: json['duration'] as int? ?? 60,
      status: json['status'] as String? ?? 'pending',
      cardColor: AppointmentUtils.getTreatmentColor(procedureName),
      appointmentDate: isSupabaseFormat
          ? DateTime.parse(json['start_datetime'] as String)
          : DateTime.parse(json['appointmentDate'] as String? ?? DateTime.now().toIso8601String()),
      notes: json['notes'] as String? ?? '',
      files: (json['files'] as List<dynamic>? ?? [])
          .map((e) => AppointmentFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      remarks: (json['remarks'] as List<dynamic>? ?? [])
          .map((e) => Remark.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String _extractTime(String? datetime) {
    if (datetime == null) return '00:00';
    try {
      final dt = DateTime.parse(datetime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'patientName': patientName,
        'doctor_id': doctorId,                // ← NEW
        'doctorName': doctorName,             // ← NEW
        'procedure': procedure,
        'time': time,
        'duration': duration,                 // ← Saved
        'status': status,
        'cardColor': cardColor.value,
        'appointmentDate': appointmentDate.toIso8601String(),
        'notes': notes,
        'files': files.map((e) => e.toJson()).toList(),
        'remarks': remarks.map((e) => e.toJson()).toList(),
        'payments': payments.map((e) => e.toJson()).toList(),
        'totalCost': totalCost,
      };
}