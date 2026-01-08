import 'package:dentist_ms/features/settings/bloc/clinic_info_state.dart';
import 'package:dentist_ms/features/settings/data/clinic_info_repository.dart';
import 'package:dentist_ms/features/settings/models/clinic_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClinicInfoCubit extends Cubit<ClinicInfoState> {
  ClinicInfoCubit(this._repository) : super(ClinicInfoState.initial());

  final ClinicInfoRepository _repository;

  Future<void> loadClinicInfo() async {
    emit(state.copyWith(status: ClinicInfoStatus.loading, errorMessage: null));

    try {
      final clinicInfo = await _repository.fetchClinicInfo();
      emit(
        state.copyWith(clinicInfo: clinicInfo, status: ClinicInfoStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClinicInfoStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> saveClinicInfo(ClinicInfo updated) async {
    final previous = state.clinicInfo;

    emit(
      state.copyWith(
        clinicInfo: updated,
        status: ClinicInfoStatus.saving,
        errorMessage: null,
      ),
    );

    try {
      await _repository.saveClinicInfo(updated);
      emit(state.copyWith(status: ClinicInfoStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          clinicInfo: previous,
          status: ClinicInfoStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
