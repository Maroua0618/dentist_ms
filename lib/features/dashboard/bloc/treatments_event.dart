import 'package:equatable/equatable.dart';

abstract class TreatmentsEvent extends Equatable {
  const TreatmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTreatmentsChart extends TreatmentsEvent {
  final int year;
  const LoadTreatmentsChart({required this.year});

  @override
  List<Object?> get props => [year];
}

class RefreshTreatmentsChart extends TreatmentsEvent {
  final int year;
  const RefreshTreatmentsChart({required this.year});

  @override
  List<Object?> get props => [year];
}
