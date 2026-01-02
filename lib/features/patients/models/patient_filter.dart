class PatientFilter {
  final String? status;
  final String? gender;
  final String? bloodType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const PatientFilter({
    this.status,
    this.gender,
    this.bloodType,
    this.dateFrom,
    this.dateTo,
  });

  PatientFilter copyWith({
    String? status,
    String? gender,
    String? bloodType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return PatientFilter(
      status: status ?? this.status,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  PatientFilter clear() {
    return const PatientFilter();
  }

  bool get hasFilters =>
      status != null ||
      gender != null ||
      bloodType != null ||
      dateFrom != null ||
      dateTo != null;
}
