import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/citation_model.dart';
import '../providers/citation_provider.dart';

// Current citation being worked on
@riverpod
class CurrentCitation extends _$CurrentCitation {
  @override
  Citation build() => const Citation();

  void updateField(String field, dynamic value) {
    // This is a simplified version - you'd implement proper field updates
    state = const Citation(); // Update with actual field changes
  }

  void updateFromOCR(Map<String, dynamic> ocrData) {
    state = state.copyWith(
      firstName: ocrData['firstName'],
      lastName: ocrData['lastName'],
      dlNumber: ocrData['dlNumber'],
      // ... map other fields
    );
  }

  void reset() {
    state = const Citation();
  }
}
