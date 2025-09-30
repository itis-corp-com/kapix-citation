import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../services/pdf_service.dart';
import 'citation_provider.dart';

part 'pdf_provider.g.dart';

enum PDFStatus { idle, generating, success, error }

@immutable
class PDFState {
  final PDFStatus status;
  final String? message;
  final File? generatedPDF;
  final Map<String, String>? formFields;

  const PDFState({
    this.status = PDFStatus.idle,
    this.message,
    this.generatedPDF,
    this.formFields,
  });

  PDFState copyWith({
    PDFStatus? status,
    String? message,
    File? generatedPDF,
    Map<String, String>? formFields,
  }) {
    return PDFState(
      status: status ?? this.status,
      message: message ?? this.message,
      generatedPDF: generatedPDF ?? this.generatedPDF,
      formFields: formFields ?? this.formFields,
    );
  }
}

@riverpod
class PDFGenerator extends _$PDFGenerator {
  @override
  PDFState build() => const PDFState();

  /// Generate a citation PDF from the current citation data
  Future<void> generateCitationPDF() async {
    state = state.copyWith(
      status: PDFStatus.generating,
      message: 'Generating citation PDF...',
    );

    try {
      // Get the current citation data
      final citation = ref.read(currentCitationProvider);
      
      // Convert citation to map for PDF service
      final Map<String, dynamic> citationData = {
        // Driver information
        'firstName': citation.firstName,
        'lastName': citation.lastName,
        'fullName': '${citation.firstName ?? ''} ${citation.lastName ?? ''}'.trim(),
        'dlNumber': citation.dlNumber,
        'dlState': citation.dlState,
        'address': citation.address,
        'city': citation.city,
        'state': citation.state,
        'zip': citation.zip,
        'dateOfBirth': citation.dateOfBirth,
        
        // Vehicle information
        'vehicleLicense': citation.vehicleLicense,
        'vehicleState': citation.vehicleState,
        'vin': citation.vin,
        'vehicleYear': citation.vehicleYear,
        'vehicleMake': citation.vehicleMake,
        'vehicleModel': citation.vehicleModel,
        'vehicleColor': citation.vehicleColor,
        
        // Violation information
        'violationCode': citation.violationCode,
        'violationDescription': citation.violationDescription,
        'location': citation.location,
        'speed': citation.speed,
        'speedLimit': citation.speedLimit,
        
        // Officer information (you might want to add these to your citation model)
        'officerName': 'Officer Smith', // TODO: Get from user preferences
        'officerBadge': '12345', // TODO: Get from user preferences
        'department': 'California Highway Patrol', // TODO: Get from configuration
      };

      // Generate the PDF
      final File? pdfFile = await PDFService.populateCitationForm(citationData);

      if (pdfFile != null) {
        state = state.copyWith(
          status: PDFStatus.success,
          message: 'Citation PDF generated successfully',
          generatedPDF: pdfFile,
        );
      } else {
        state = state.copyWith(
          status: PDFStatus.error,
          message: 'Failed to generate PDF',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PDFStatus.error,
        message: 'Error generating PDF: ${e.toString()}',
      );
    }
  }

  /// Analyze the PDF form structure for debugging
  Future<void> analyzeFormStructure() async {
    state = state.copyWith(
      status: PDFStatus.generating,
      message: 'Analyzing PDF form structure...',
    );

    try {
      final Map<String, String> formFields = await PDFService.analyzeFormStructure();
      
      state = state.copyWith(
        status: PDFStatus.success,
        message: 'Form structure analyzed successfully',
        formFields: formFields,
      );
    } catch (e) {
      state = state.copyWith(
        status: PDFStatus.error,
        message: 'Error analyzing form: ${e.toString()}',
      );
    }
  }

  /// Reset the PDF generator state
  void reset() {
    state = const PDFState();
  }
}
