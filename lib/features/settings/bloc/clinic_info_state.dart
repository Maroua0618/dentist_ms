import 'package:dentist_ms/features/settings/models/clinic_info.dart';
import 'package:equatable/equatable.dart';

enum ClinicInfoStatus { initial, loading, loaded, saving, error }

class ClinicInfoState extends Equatable {
  final ClinicInfo clinicInfo;
  final ClinicInfoStatus status;
  final String? errorMessage;

  const ClinicInfoState({
    required this.clinicInfo,
    required this.status,
    this.errorMessage,
  });

  factory ClinicInfoState.initial() => ClinicInfoState(
    clinicInfo: ClinicInfo.defaultValues(),
    status: ClinicInfoStatus.initial,
    errorMessage: null,
  );

  ClinicInfoState copyWith({
    ClinicInfo? clinicInfo,
    ClinicInfoStatus? status,
    String? errorMessage,
  }) {
    return ClinicInfoState(
      clinicInfo: clinicInfo ?? this.clinicInfo,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ClinicInfoStatus.loading;
  bool get isSaving => status == ClinicInfoStatus.saving;

  @override
  List<Object?> get props => [clinicInfo, status, errorMessage];
}
