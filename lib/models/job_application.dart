import 'package:flutter/cupertino.dart';
import '../theme/apple_colors.dart';

enum JobStatus {
  applied,
  screening,
  technical,
  interview,
  offering,
  rejected;

  String get label {
    switch (this) {
      case JobStatus.applied:
        return 'Terkirim';
      case JobStatus.screening:
        return 'HR Screening';
      case JobStatus.technical:
        return 'Technical Test';
      case JobStatus.interview:
        return 'User Interview';
      case JobStatus.offering:
        return 'Offering 🏆';
      case JobStatus.rejected:
        return 'Ditolak / Arsip';
    }
  }

  Color get color {
    switch (this) {
      case JobStatus.applied:
        return AppleColors.systemBlue;
      case JobStatus.screening:
        return AppleColors.systemOrange;
      case JobStatus.technical:
        return AppleColors.systemPurple;
      case JobStatus.interview:
        return AppleColors.systemIndigo;
      case JobStatus.offering:
        return AppleColors.systemGreen;
      case JobStatus.rejected:
        return const Color(0xFF8E8E93);
    }
  }
}

class JobApplication {
  final String id;
  final String company;
  final String position;
  final String workSystem; // 'Remote', 'Hybrid', 'On-site'
  final String salaryExpectation;
  final String cvVersion;
  final JobStatus status;
  final DateTime appliedDate;
  final DateTime? followUpDate;
  final String? notes;
  final String? hrContact;

  JobApplication({
    required this.id,
    required this.company,
    required this.position,
    this.workSystem = 'Hybrid',
    this.salaryExpectation = '',
    this.cvVersion = 'CV_Terbaru_Hasan.pdf',
    this.status = JobStatus.applied,
    required this.appliedDate,
    this.followUpDate,
    this.notes,
    this.hrContact,
  });

  JobApplication copyWith({
    String? id,
    String? company,
    String? position,
    String? workSystem,
    String? salaryExpectation,
    String? cvVersion,
    JobStatus? status,
    DateTime? appliedDate,
    DateTime? followUpDate,
    String? notes,
    String? hrContact,
  }) {
    return JobApplication(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      workSystem: workSystem ?? this.workSystem,
      salaryExpectation: salaryExpectation ?? this.salaryExpectation,
      cvVersion: cvVersion ?? this.cvVersion,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      hrContact: hrContact ?? this.hrContact,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'position': position,
        'workSystem': workSystem,
        'salaryExpectation': salaryExpectation,
        'cvVersion': cvVersion,
        'status': status.name,
        'appliedDate': appliedDate.toIso8601String(),
        'followUpDate': followUpDate?.toIso8601String(),
        'notes': notes,
        'hrContact': hrContact,
      };

  factory JobApplication.fromJson(Map<String, dynamic> json) => JobApplication(
        id: json['id'] as String,
        company: json['company'] as String,
        position: json['position'] as String,
        workSystem: json['workSystem'] as String? ?? 'Hybrid',
        salaryExpectation: json['salaryExpectation'] as String? ?? '',
        cvVersion: json['cvVersion'] as String? ?? 'CV_Terbaru_Hasan.pdf',
        status: JobStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => JobStatus.applied,
        ),
        appliedDate: DateTime.parse(json['appliedDate'] as String),
        followUpDate: json['followUpDate'] != null
            ? DateTime.parse(json['followUpDate'] as String)
            : null,
        notes: json['notes'] as String?,
        hrContact: json['hrContact'] as String?,
      );
}
