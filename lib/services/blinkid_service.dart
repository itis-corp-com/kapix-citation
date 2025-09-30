import 'package:flutter/services.dart';
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'dart:io';
import '../config/config.dart';

class BlinkIdService {
  final BlinkidFlutter _blinkIdPlugin = BlinkidFlutter();

  Future<BlinkIdScanningResult?> scanDriverLicense() async {
    try {
      final licenseKey = Platform.isIOS
          ? Config.blinkIdLicenseKeyIOS
          : Config.blinkIdLicenseKeyAndroid;

      // SDK Settings
      final sdkSettings = BlinkIdSdkSettings(licenseKey);
      sdkSettings.downloadResources = true;

      // Session Settings
      final sessionSettings = BlinkIdSessionSettings();
      sessionSettings.scanningMode = ScanningMode.single;

      // Scanning Settings
      final scanningSettings = BlinkIdScanningSettings();
      scanningSettings.anonymizationMode = AnonymizationMode.fullResult;
      scanningSettings.glareDetectionLevel = DetectionLevel.mid;
      scanningSettings.blurDetectionLevel = DetectionLevel.mid;

      // Single-side scanning configuration
      // Note: These properties may not be available in current BlinkID version
      // scanningSettings.scanBothSides = false;
      // scanningSettings.returnFullDocumentImage = true;
      // scanningSettings.returnFaceImage = false;
      // scanningSettings.returnSignatureImage = false;
      // scanningSettings.documentDataMatchLevel = MatchLevel.disabled;

      // Image Settings
      final imageSettings = CroppedImageSettings();
      imageSettings.returnDocumentImage = true;
      imageSettings.returnSignatureImage = false;
      imageSettings.returnFaceImage = false;

      scanningSettings.croppedImageSettings = imageSettings;
      sessionSettings.scanningSettings = scanningSettings;

      // UI Settings
      final uiSettings = BlinkIdUiSettings();
      uiSettings.showHelpButton = true;
      uiSettings.showOnboardingDialog = false;
      // uiSettings.showSuccessFrame = false; // May not be available in current version

      // Perform scan
      final result = await _blinkIdPlugin.performScan(
        sdkSettings,
        sessionSettings,
        uiSettings,
      );

      return result;
    } catch (e) {
      if (e is PlatformException) {
        throw BlinkIdException(e.message ?? 'Unknown BlinkID error');
      }
      throw BlinkIdException('Failed to scan driver license: $e');
    }
  }

  Map<String, dynamic> extractDriverData(BlinkIdScanningResult result) {
    final data = {
      'firstName': result.firstName?.value,
      // 'middleName': result.middleName?.value, // May not be available
      'lastName': result.lastName?.value,
      'fullName': result.fullName?.value,
      'dlNumber': result.documentNumber?.value,
      'dlState': result.issuingAuthority?.value,
      'address': result.address?.value,
      'dateOfBirth': result.dateOfBirth?.date != null
          ? DateTime(
              result.dateOfBirth!.date!.year!,
              result.dateOfBirth!.date!.month!,
              result.dateOfBirth!.date!.day!,
            )
          : null,
      'expiryDate': result.dateOfExpiry?.date != null
          ? DateTime(
              result.dateOfExpiry!.date!.year!,
              result.dateOfExpiry!.date!.month!,
              result.dateOfExpiry!.date!.day!,
            )
          : null,
      'sex': result.sex?.value,
      // 'height': result.height?.value, // May not be available
      // 'weight': result.weight?.value, // May not be available
      // 'eyeColor': result.eyeColor?.value, // May not be available
      // 'hairColor': result.hairColor?.value, // May not be available
      // 'documentType': result.documentType?.name, // May not be available
      
      // Add image data
      'documentImage': result.firstDocumentImage ?? result.firstInputImage,
      'hasImage': (result.firstDocumentImage ?? result.firstInputImage) != null,
    };
    
    // Debug logging to see what data was extracted
    print('BlinkID extracted data: ${data.keys.toList()}');
    print('Has image: ${data['hasImage']}');
    return data;
  }

  String formatDriverLicenseInfo(Map<String, dynamic> data) {
    final buffer = StringBuffer('Driver License Information:\n\n');

    if (data['firstName'] != null) {
      buffer.writeln('• First Name: ${data['firstName']}');
    }
    if (data['lastName'] != null) {
      buffer.writeln('• Last Name: ${data['lastName']}');
    }
    if (data['address'] != null) {
      buffer.writeln('• Address: ${data['address']}');
    }
    if (data['dlNumber'] != null) {
      buffer.writeln('• License Number: ${data['dlNumber']}');
    }
    if (data['dateOfBirth'] != null) {
      final dob = data['dateOfBirth'] as DateTime;
      buffer.writeln('• Date of Birth: ${dob.month}/${dob.day}/${dob.year}');
    }
    if (data['expiryDate'] != null) {
      final exp = data['expiryDate'] as DateTime;
      buffer.writeln('• Expiry Date: ${exp.month}/${exp.day}/${exp.year}');
    }

    return buffer.toString();
  }
}

class BlinkIdException implements Exception {
  final String message;
  BlinkIdException(this.message);

  @override
  String toString() => message;
}
