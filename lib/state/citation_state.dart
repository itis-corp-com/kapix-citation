import 'package:flutter/foundation.dart';

/// Represents a single field within a citation along with a confidence
/// score.  A confidence of 0.0 means the field has not yet been
/// captured.  Consumers should check the confidence to determine
/// whether to prompt the user for confirmation or re‑capture.
class CitationField<T> {
  T? value;
  double confidence;

  CitationField({this.value, this.confidence = 0.0});

  bool get isEmpty => value == null || (value is String && (value as String).isEmpty);
  bool get isHighConfidence => confidence >= 0.85;
  bool get isMediumConfidence => confidence >= 0.60 && confidence < 0.85;
  bool get isLowConfidence => confidence < 0.60;
}

/// Holds all of the structured data we need to assemble a citation.
/// Each field exposes both the underlying value and a confidence
/// measure.  Confidence values are used by the state machine and
/// prompt service to decide what to ask the officer next.
@immutable
class CitationState {
  final CitationField<String> firstName;
  final CitationField<String> lastName;
  /// Date of birth extracted from the driver's license.
  final CitationField<String> dob;
  /// Driver's license number.
  final CitationField<String> dlNumber;
  /// State in which the driver's license was issued.
  final CitationField<String> dlState;

  // Vehicle info from registration
  final CitationField<String> plate;
  final CitationField<String> plateState;
  final CitationField<String> registrationVin;

  // VIN from dedicated VIN capture
  final CitationField<String> vin;

  // Insurance
  final CitationField<String> insurer;
  final CitationField<String> policy;

  // Contact information (phone or email; one is sufficient)
  final CitationField<String> phone;
  final CitationField<String> email;

  const CitationState({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.dlNumber,
    required this.dlState,
    required this.plate,
    required this.plateState,
    required this.registrationVin,
    required this.vin,
    required this.insurer,
    required this.policy,
    required this.phone,
    required this.email,
  });

  /// Convenience constructor for an empty citation state with all
  /// confidences set to zero.
  factory CitationState.initial() {
    return CitationState(
      firstName: CitationField<String>(),
      lastName: CitationField<String>(),
      dob: CitationField<String>(),
      dlNumber: CitationField<String>(),
      dlState: CitationField<String>(),
      plate: CitationField<String>(),
      plateState: CitationField<String>(),
      registrationVin: CitationField<String>(),
      vin: CitationField<String>(),
      insurer: CitationField<String>(),
      policy: CitationField<String>(),
      phone: CitationField<String>(),
      email: CitationField<String>(),
    );
  }

  /// Returns a copy of this state with the provided fields replaced.
  CitationState copyWith({
    CitationField<String>? firstName,
    CitationField<String>? lastName,
    CitationField<String>? dob,
    CitationField<String>? dlNumber,
    CitationField<String>? dlState,
    CitationField<String>? plate,
    CitationField<String>? plateState,
    CitationField<String>? registrationVin,
    CitationField<String>? vin,
    CitationField<String>? insurer,
    CitationField<String>? policy,
    CitationField<String>? phone,
    CitationField<String>? email,
  }) {
    return CitationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      dlNumber: dlNumber ?? this.dlNumber,
      dlState: dlState ?? this.dlState,
      plate: plate ?? this.plate,
      plateState: plateState ?? this.plateState,
      registrationVin: registrationVin ?? this.registrationVin,
      vin: vin ?? this.vin,
      insurer: insurer ?? this.insurer,
      policy: policy ?? this.policy,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  /// Utility to determine whether all required fields are populated with
  /// high confidence.  Used by the state machine to decide when the
  /// citation is ready for review.
  bool get isComplete {
    return firstName.value != null && lastName.value != null && dlNumber.value != null &&
        plate.value != null && plateState.value != null &&
        (vin.value != null || registrationVin.value != null) &&
        insurer.value != null && policy.value != null &&
        (phone.value != null || email.value != null);
  }
}