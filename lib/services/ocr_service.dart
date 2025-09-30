import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:convert';

class OCRService {
  static final _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  static Future<Map<String, dynamic>> processVehicleRegistration(
      File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    // Read image file and convert to base64
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // Extract vehicle registration data
    Map<String, dynamic> vehicleData = {
      'licensePlate': null,
      'vin': null,
      'year': null,
      'make': null,
      'model': null,
      'color': null,
      'ownerName': null,
      'registrationExpiry': null,
      
      // Add image data
      'documentImage': base64Image,
      'hasImage': true,
    };

    // Common patterns for vehicle data
    final vinPattern = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b');
    final platePattern = RegExp(r'\b[A-Z0-9]{1,3}[\s-]?[A-Z0-9]{1,4}\b');
    final yearPattern = RegExp(r'\b(19|20)\d{2}\b');

    String fullText = recognizedText.text.toUpperCase();

    // Extract VIN
    final vinMatch = vinPattern.firstMatch(fullText);
    if (vinMatch != null) {
      vehicleData['vin'] = vinMatch.group(0);
    }

    // Extract license plate
    final plateMatch = platePattern.firstMatch(fullText);
    if (plateMatch != null) {
      vehicleData['licensePlate'] = plateMatch.group(0);
    }

    // Extract year
    final yearMatch = yearPattern.firstMatch(fullText);
    if (yearMatch != null) {
      vehicleData['year'] = yearMatch.group(0);
    }

    // Look for make/model (common patterns)
    for (TextBlock block in recognizedText.blocks) {
      String blockText = block.text.toUpperCase();

      // Common car makes
      List<String> makes = [
        'FORD',
        'CHEVROLET',
        'TOYOTA',
        'HONDA',
        'NISSAN',
        'BMW',
        'MERCEDES',
        'AUDI',
        'VOLKSWAGEN',
        'SUBARU',
        'MAZDA',
        'HYUNDAI',
        'KIA',
        'DODGE',
        'RAM',
        'GMC'
      ];

      for (String make in makes) {
        if (blockText.contains(make)) {
          vehicleData['make'] = make;
          // Try to find model on same line or next line
          List<String> lines = block.text.split('\n');
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].toUpperCase().contains(make)) {
              // Check same line for model
              String sameLine =
                  lines[i].toUpperCase().replaceAll(make, '').trim();
              if (sameLine.isNotEmpty && sameLine.length > 2) {
                vehicleData['model'] = sameLine.split(' ').first;
              }
              // Check next line if available
              else if (i + 1 < lines.length) {
                vehicleData['model'] = lines[i + 1].trim().split(' ').first;
              }
              break;
            }
          }
          break;
        }
      }

      // Look for color
      List<String> colors = [
        'BLACK',
        'WHITE',
        'SILVER',
        'GRAY',
        'GREY',
        'RED',
        'BLUE',
        'GREEN',
        'YELLOW',
        'BROWN',
        'TAN',
        'GOLD'
      ];
      for (String color in colors) {
        if (blockText.contains(color)) {
          vehicleData['color'] = color;
          break;
        }
      }
    }

    return vehicleData;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
