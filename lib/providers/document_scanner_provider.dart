import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The scanning workflow may involve multiple asynchronous steps such as
/// launching a camera interface, processing images with an OCR service
/// and returning structured data. To keep the UI responsive we model
/// the scanner as a state notifier with a simple status enum and
/// optional message and data payload. This provider acts as a
/// placeholder for the full Microblink/MLKit integration; in this
/// example it emits dummy data to demonstrate the integration with
/// the citation state machine.

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

/// A state notifier that simulates scanning documents. In a real
/// application these methods would invoke Microblink for driver
/// licenses and registration documents, perform OCR on captured
/// images, and return structured fields. Here we emit fixed data
/// after a short delay to demonstrate integration with the UI.
class DocumentScanner extends StateNotifier<ScannerState> {
  DocumentScanner() : super(const ScannerState());

  /// Simulate scanning a driver's license. Emits a [ScannerState]
  /// with dummy driver data after a delay. In your implementation
  /// replace this with a call to the Microblink SDK and update the
  /// citation providers accordingly.
  Future<void> scanDriverLicense() async {
    state = state.copyWith(
      status: ScannerStatus.scanning,
      message: 'Scanning driver license...',
    );
    await Future.delayed(const Duration(seconds: 1));
    // Dummy driver data extracted from license
    final data = {
      'firstName': 'Jane',
      'lastName': 'Doe',
      'dateOfBirth': '01/15/1985',
      'dlNumber': 'D9876543',
      'dlState': 'CA',
    };
    state = state.copyWith(
      status: ScannerStatus.success,
      message: 'Driver license scanned.',
      data: data,
    );
  }

  /// Simulate scanning a vehicle registration from a captured image
  /// file. Replace this stub with OCR and extraction logic for
  /// registration documents. The [imageFile] parameter represents
  /// the photo taken by the officer.
  Future<void> scanVehicleRegistration(File imageFile) async {
    state = state.copyWith(
      status: ScannerStatus.processing,
      message: 'Scanning vehicle registration...',
    );
    await Future.delayed(const Duration(seconds: 1));
    final data = {
      'licensePlate': '7ABC123',
      'plateState': 'CA',
      'vin': '1HGCM82633A004352',
    };
    state = state.copyWith(
      status: ScannerStatus.success,
      message: 'Vehicle registration scanned.',
      data: data,
    );
  }

  /// Reset the scanner to the idle state. Useful when starting a new
  /// citation or when the scan is cancelled.
  void reset() {
    state = const ScannerState();
  }
}

/// The Riverpod provider for the document scanner. Access the
/// notifier to initiate scans and listen to the state for updates.
final documentScannerProvider = StateNotifierProvider<DocumentScanner, ScannerState>((ref) {
  return DocumentScanner();
});