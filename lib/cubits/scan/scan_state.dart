import 'package:equatable/equatable.dart';
import 'package:scamshield_app/models/scan_result.dart';

abstract class ScanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final ScanResult result;
  const ScanSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

class ScanError extends ScanState {
  final String message;
  const ScanError({required this.message});

  @override
  List<Object?> get props => [message];
}
