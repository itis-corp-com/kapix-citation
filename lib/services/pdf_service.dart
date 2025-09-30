import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFService {
  static const String _templatePath = 'assets/templates/california/tr130.pdf';

  /// Load the PDF template from assets
  static Future<PdfDocument> _loadTemplate() async {
    final ByteData data = await rootBundle.load(_templatePath);
    final Uint8List bytes = data.buffer.asUint8List();
    return PdfDocument(inputBytes: bytes);
  }

  /// Populate the PDF form with citation data
  static Future<File?> populateCitationForm(Map<String, dynamic> citationData) async {
    try {
      // Load the PDF template
      final PdfDocument document = await _loadTemplate();
      
      // Get the form from the document
      final PdfForm form = document.form;
      
      // Populate driver information fields
      _populateDriverInfo(form, citationData);
      
      // Populate vehicle information fields
      _populateVehicleInfo(form, citationData);
      
      // Populate violation information fields
      _populateViolationInfo(form, citationData);
      
      // Populate officer and citation details
      _populateOfficerInfo(form, citationData);
      
      // Save the populated PDF
      final File populatedPdf = await _savePDF(document, 'citation_${DateTime.now().millisecondsSinceEpoch}.pdf');
      
      // Dispose the document
      document.dispose();
      
      return populatedPdf;
    } catch (e) {
      print('Error populating PDF form: $e');
      return null;
    }
  }

  /// Populate driver information fields
  static void _populateDriverInfo(PdfForm form, Map<String, dynamic> data) {
    // Driver's license information
    _setFieldValue(form, 'driver_first_name', data['firstName']);
    _setFieldValue(form, 'driver_last_name', data['lastName']);
    _setFieldValue(form, 'driver_full_name', data['fullName']);
    _setFieldValue(form, 'dl_number', data['dlNumber']);
    _setFieldValue(form, 'dl_state', data['dlState']);
    _setFieldValue(form, 'driver_address', data['address']);
    _setFieldValue(form, 'driver_city', data['city']);
    _setFieldValue(form, 'driver_state', data['state']);
    _setFieldValue(form, 'driver_zip', data['zip']);
    _setFieldValue(form, 'driver_sex', data['sex']);
    
    // Format and set date of birth
    if (data['dateOfBirth'] != null && data['dateOfBirth'] is DateTime) {
      final DateTime dob = data['dateOfBirth'];
      _setFieldValue(form, 'driver_dob', '${dob.month.toString().padLeft(2, '0')}/${dob.day.toString().padLeft(2, '0')}/${dob.year}');
    }
  }

  /// Populate vehicle information fields
  static void _populateVehicleInfo(PdfForm form, Map<String, dynamic> data) {
    _setFieldValue(form, 'vehicle_license', data['vehicleLicense']);
    _setFieldValue(form, 'vehicle_state', data['vehicleState']);
    _setFieldValue(form, 'vehicle_vin', data['vin']);
    _setFieldValue(form, 'vehicle_year', data['vehicleYear']);
    _setFieldValue(form, 'vehicle_make', data['vehicleMake']);
    _setFieldValue(form, 'vehicle_model', data['vehicleModel']);
    _setFieldValue(form, 'vehicle_color', data['vehicleColor']);
  }

  /// Populate violation information fields
  static void _populateViolationInfo(PdfForm form, Map<String, dynamic> data) {
    _setFieldValue(form, 'violation_code', data['violationCode']);
    _setFieldValue(form, 'violation_description', data['violationDescription']);
    _setFieldValue(form, 'violation_location', data['location']);
    _setFieldValue(form, 'violation_speed', data['speed']);
    _setFieldValue(form, 'violation_speed_limit', data['speedLimit']);
    
    // Set current date and time for citation
    final DateTime now = DateTime.now();
    _setFieldValue(form, 'citation_date', '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}');
    _setFieldValue(form, 'citation_time', '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
  }

  /// Populate officer information fields
  static void _populateOfficerInfo(PdfForm form, Map<String, dynamic> data) {
    _setFieldValue(form, 'officer_name', data['officerName'] ?? 'Officer');
    _setFieldValue(form, 'officer_badge', data['officerBadge'] ?? '');
    _setFieldValue(form, 'officer_department', data['department'] ?? 'Police Department');
    _setFieldValue(form, 'citation_number', data['citationNumber'] ?? _generateCitationNumber());
  }

  /// Helper method to set field value safely
  static void _setFieldValue(PdfForm form, String fieldName, dynamic value) {
    if (value != null && value.toString().isNotEmpty) {
      try {
        // Find field by name
        PdfField? field;
        for (int i = 0; i < form.fields.count; i++) {
          final currentField = form.fields[i];
          if (currentField.name == fieldName) {
            field = currentField;
            break;
          }
        }
        
        if (field != null) {
          if (field is PdfTextBoxField) {
            field.text = value.toString();
          } else if (field is PdfCheckBoxField) {
            field.isChecked = value == true || value.toString().toLowerCase() == 'true';
          } else if (field is PdfComboBoxField) {
            field.selectedValue = value.toString();
          }
        } else {
          print('Field not found: $fieldName');
        }
      } catch (e) {
        print('Error setting field $fieldName: $e');
      }
    }
  }

  /// Save the PDF document to a file
  static Future<File> _savePDF(PdfDocument document, String filename) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = '${appDocDir.path}/$filename';
    final File file = File(path);
    
    final List<int> bytes = await document.save();
    await file.writeAsBytes(bytes);
    
    return file;
  }

  /// Generate a unique citation number
  static String _generateCitationNumber() {
    final DateTime now = DateTime.now();
    return 'CT${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  /// Get list of all form field names (for debugging)
  static Future<List<String>> getFormFieldNames() async {
    try {
      final PdfDocument document = await _loadTemplate();
      final PdfForm form = document.form;
      
      final List<String> fieldNames = [];
      for (int i = 0; i < form.fields.count; i++) {
        final PdfField field = form.fields[i];
        fieldNames.add(field.name ?? 'unnamed_field_$i');
      }
      
      document.dispose();
      return fieldNames;
    } catch (e) {
      print('Error getting form field names: $e');
      return [];
    }
  }

  /// Preview/validate the PDF form structure
  static Future<Map<String, String>> analyzeFormStructure() async {
    try {
      final PdfDocument document = await _loadTemplate();
      final PdfForm form = document.form;
      
      final Map<String, String> fieldInfo = {};
      for (int i = 0; i < form.fields.count; i++) {
        final PdfField field = form.fields[i];
        String fieldType = 'Unknown';
        
        if (field is PdfTextBoxField) {
          fieldType = 'TextBox';
        } else if (field is PdfCheckBoxField) {
          fieldType = 'CheckBox';
        } else if (field is PdfComboBoxField) {
          fieldType = 'ComboBox';
        } else if (field is PdfRadioButtonListField) {
          fieldType = 'RadioButton';
        }
        
        fieldInfo[field.name ?? 'unnamed_field_$i'] = fieldType;
      }
      
      document.dispose();
      return fieldInfo;
    } catch (e) {
      print('Error analyzing form structure: $e');
      return {};
    }
  }
}
