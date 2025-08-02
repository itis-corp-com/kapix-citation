import 'package:blinkid_flutter/blinkid_flutter.dart';

class BlinkIdResultBuilder {
  static String getIdResultString(BlinkIdScanningResult result) {
    String resultString = 'BlinkID Scanning Result:\n\n';
    
    // Add basic result information
    if (result.firstName?.value?.isNotEmpty == true) {
      resultString += 'First Name: ${result.firstName!.value}\n';
    }
    if (result.lastName?.value?.isNotEmpty == true) {
      resultString += 'Last Name: ${result.lastName!.value}\n';
    }
    if (result.fullName?.value?.isNotEmpty == true) {
      resultString += 'Full Name: ${result.fullName!.value}\n';
    }
    if (result.address?.value?.isNotEmpty == true) {
      resultString += 'Address: ${result.address!.value}\n';
    }
    if (result.documentNumber?.value?.isNotEmpty == true) {
      resultString += 'Document Number: ${result.documentNumber!.value}\n';
    }
    if (result.dateOfBirth?.date != null) {
      final dob = result.dateOfBirth!.date!;
      resultString += 'Date of Birth: ${dob.day}/${dob.month}/${dob.year}\n';
    }
    if (result.dateOfExpiry?.date != null) {
      final expiry = result.dateOfExpiry!.date!;
      resultString += 'Date of Expiry: ${expiry.day}/${expiry.month}/${expiry.year}\n';
    }
    
    return resultString;
  }
}
