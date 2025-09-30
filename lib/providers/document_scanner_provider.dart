import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/blinkid_service.dart';
import '../services/ocr_service.dart';
import 'citation_provider.dart';
import 'dart:io';

part 'document_scanner_provider.g.dart';

// Provider for BlinkID service
@riverpod
BlinkIdService blinkIdService(BlinkIdServiceRef ref) {
  return BlinkIdService();
}

// Scanner state
enum ScannerStatus { idle, scanning, processing, success, error }

@immutable
class ScannerState {
  final ScannerStatus status;
  final String? message;
  final Map<String, dynamic>? data;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.message,
    this.data,
  });

  ScannerState copyWith({
    ScannerStatus? status,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return ScannerState(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

// Document scanner provider
@riverpod
class DocumentScanner extends _$DocumentScanner {
  @override
  ScannerState build() => const ScannerState();

  Future<void> scanDriverLicense() async {
    state = state.copyWith(
      status: ScannerStatus.scanning,
      message: 'Opening scanner...',
    );

    try {
      final blinkIdService = ref.read(blinkIdServiceProvider);
      final result = await blinkIdService.scanDriverLicense();

      if (result != null) {
        state = state.copyWith(
          status: ScannerStatus.processing,
          message: 'Processing license data...',
        );

        final extractedData = blinkIdService.extractDriverData(result);

        // Update citation with driver data
        ref.read(currentCitationProvider.notifier).updateDriver(extractedData);

        state = state.copyWith(
          status: ScannerStatus.success,
          message: blinkIdService.formatDriverLicenseInfo(extractedData),
          data: extractedData,
        );
      } else {
        state = state.copyWith(
          status: ScannerStatus.idle,
          message: 'Scan cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<void> scanVehicleRegistration(File imageFile) async {
    state = state.copyWith(
      status: ScannerStatus.processing,
      message: 'Scanning vehicle registration...',
    );

    try {
      final vehicleData =
          await OCRService.processVehicleRegistration(imageFile);

      // Update citation with vehicle data
      ref.read(currentCitationProvider.notifier).updateVehicle(vehicleData);

      final formattedInfo = _formatVehicleInfo(vehicleData);

      state = state.copyWith(
        status: ScannerStatus.success,
        message: formattedInfo,
        data: vehicleData,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        message: 'Error processing registration: ${e.toString()}',
      );
    }
  }

  String _formatVehicleInfo(Map<String, dynamic> data) {
    final buffer = StringBuffer('Vehicle Registration Information:\n\n');

    if (data['licensePlate'] != null) {
      buffer.writeln('• License Plate: ${data['licensePlate']}');
    }
    if (data['vin'] != null) {
      buffer.writeln('• VIN: ${data['vin']}');
    }
    if (data['year'] != null) {
      buffer.writeln('• Year: ${data['year']}');
    }
    if (data['make'] != null) {
      buffer.writeln('• Make: ${data['make']}');
    }
    if (data['model'] != null) {
      buffer.writeln('• Model: ${data['model']}');
    }
    if (data['color'] != null) {
      buffer.writeln('• Color: ${data['color']}');
    }

    return buffer.toString();
  }

  void reset() {
    state = const ScannerState();
  }
}
