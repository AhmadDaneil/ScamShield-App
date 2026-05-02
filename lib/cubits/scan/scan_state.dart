import 'package:equatable/equatable.dart';
import '../../models/scan_result.dart';

// Distinguishes error causes so the UI can respond differently.
enum ScanErrorType {
  offline,   // SocketException / no network
  timeout,   // Request took too long
  server,    // HTTP error or unexpected API response
  input,     // Validation failure (client-side)
}

abstract class ScanState extends Equatable {
  const ScanState();

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
  final ScanErrorType errorType;

  const ScanError({
    required this.message,
    this.errorType = ScanErrorType.server,
  });

  @override
  List<Object?> get props => [message, errorType];
}